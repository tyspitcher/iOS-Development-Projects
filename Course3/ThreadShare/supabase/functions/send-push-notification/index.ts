// ThreadShare APNs push sender.
//
// Invoke with a service-role caller after creating an in-app notification record:
// { "notification_id": "uuid" }

type PushRequest = {
  notification_id?: string
}

type NotificationRow = {
  id: string
  recipient_id: string
  kind: string
  title: string
  body: string
}

type NotificationPreferencesRow = {
  friend_new_item_alerts_enabled: boolean
  push_notifications_enabled: boolean
  push_borrow_requests_enabled: boolean
  push_comments_enabled: boolean
  push_messages_enabled: boolean
  push_friend_new_items_enabled: boolean
  push_return_reminders_enabled: boolean
}

type DeviceTokenRow = {
  token: string
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    const payload = await request.json() as PushRequest
    if (!payload.notification_id) {
      return json({ error: "notification_id is required" }, 400)
    }

    const config = readConfig()
    const notification = await fetchNotification(config, payload.notification_id)
    const preferences = await fetchNotificationPreferences(config, notification.recipient_id)
    if (!shouldSendForPreferences(notification.kind, preferences)) {
      return json({ sent: 0, skipped: "notification_preferences_disabled" })
    }
    const tokens = await fetchEnabledDeviceTokens(config, notification.recipient_id)

    if (tokens.length === 0) {
      return json({ sent: 0, skipped: "no_enabled_tokens" })
    }

    const jwt = await makeApnsJWT(config)
    const results = []
    for (const token of tokens) {
      results.push(await sendApns(config, jwt, token.token, notification))
    }

    return json({ sent: results.filter((result) => result.ok).length, results })
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : String(error) }, 500)
  }
})

function readConfig() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")
  const teamId = Deno.env.get("APNS_TEAM_ID")
  const keyId = Deno.env.get("APNS_KEY_ID")
  const bundleId = Deno.env.get("APNS_BUNDLE_ID")
  const privateKey = Deno.env.get("APNS_AUTH_KEY_P8")
  const apnsEnvironment = Deno.env.get("APNS_ENVIRONMENT") ?? "sandbox"

  if (!supabaseUrl || !serviceRoleKey || !teamId || !keyId || !bundleId || !privateKey) {
    throw new Error("Missing Supabase or APNs secrets")
  }

  return { supabaseUrl, serviceRoleKey, teamId, keyId, bundleId, privateKey, apnsEnvironment }
}

async function fetchNotification(config: ReturnType<typeof readConfig>, notificationId: string): Promise<NotificationRow> {
  const response = await fetch(
    `${config.supabaseUrl}/rest/v1/notifications?select=*&id=eq.${notificationId}&limit=1`,
    { headers: serviceHeaders(config) },
  )
  const rows = await response.json() as NotificationRow[]
  if (!response.ok || rows.length === 0) {
    throw new Error("Notification not found")
  }
  return rows[0]
}

async function fetchEnabledDeviceTokens(config: ReturnType<typeof readConfig>, userId: string): Promise<DeviceTokenRow[]> {
  const response = await fetch(
    `${config.supabaseUrl}/rest/v1/push_device_tokens?select=token&enabled=eq.true&user_id=eq.${userId}`,
    { headers: serviceHeaders(config) },
  )
  if (!response.ok) {
    throw new Error("Could not fetch device tokens")
  }
  return await response.json() as DeviceTokenRow[]
}

async function fetchNotificationPreferences(
  config: ReturnType<typeof readConfig>,
  userId: string,
): Promise<NotificationPreferencesRow | null> {
  const response = await fetch(
    `${config.supabaseUrl}/rest/v1/notification_preferences?select=*&user_id=eq.${userId}&limit=1`,
    { headers: serviceHeaders(config) },
  )
  if (!response.ok) {
    throw new Error("Could not fetch notification preferences")
  }

  const rows = await response.json() as NotificationPreferencesRow[]
  return rows[0] ?? null
}

function shouldSendForPreferences(kind: string, preferences: NotificationPreferencesRow | null) {
  if (!preferences) {
    return false
  }

  if (!preferences.push_notifications_enabled) {
    return false
  }

  switch (kind) {
    case "item_like":
    case "item_comment":
      return preferences.push_comments_enabled
    case "direct_message":
      return preferences.push_messages_enabled
    case "borrow_request":
    case "borrow_request_status":
      return preferences.push_borrow_requests_enabled
    case "return_reminder":
    case "item_returned":
    case "item_needs_return":
      return preferences.push_return_reminders_enabled
    case "friend_recently_added":
      return preferences.friend_new_item_alerts_enabled && preferences.push_friend_new_items_enabled
    default:
      return true
  }
}

async function sendApns(
  config: ReturnType<typeof readConfig>,
  jwt: string,
  token: string,
  notification: NotificationRow,
) {
  const host = config.apnsEnvironment === "production"
    ? "https://api.push.apple.com"
    : "https://api.sandbox.push.apple.com"

  const response = await fetch(`${host}/3/device/${token}`, {
    method: "POST",
    headers: {
      "authorization": `bearer ${jwt}`,
      "apns-topic": config.bundleId,
      "apns-push-type": "alert",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      aps: {
        alert: {
          title: notification.title,
          body: notification.body,
        },
        sound: "default",
      },
      notification_id: notification.id,
      kind: notification.kind,
    }),
  })

  return { token, ok: response.ok, status: response.status, body: await response.text() }
}

async function makeApnsJWT(config: ReturnType<typeof readConfig>) {
  const header = base64URL(JSON.stringify({ alg: "ES256", kid: config.keyId }))
  const claims = base64URL(JSON.stringify({ iss: config.teamId, iat: Math.floor(Date.now() / 1000) }))
  const signingInput = `${header}.${claims}`
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(config.privateKey),
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"],
  )
  const signature = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    key,
    new TextEncoder().encode(signingInput),
  )
  return `${signingInput}.${base64URL(new Uint8Array(signature))}`
}

function serviceHeaders(config: ReturnType<typeof readConfig>) {
  return {
    "apikey": config.serviceRoleKey,
    "authorization": `Bearer ${config.serviceRoleKey}`,
  }
}

function pemToArrayBuffer(pem: string) {
  const base64 = pem.replace(/-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----|\s/g, "")
  const binary = atob(base64)
  return Uint8Array.from(binary, (char) => char.charCodeAt(0)).buffer
}

function base64URL(input: string | Uint8Array) {
  const bytes = typeof input === "string" ? new TextEncoder().encode(input) : input
  let binary = ""
  for (const byte of bytes) {
    binary += String.fromCharCode(byte)
  }
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "")
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  })
}
