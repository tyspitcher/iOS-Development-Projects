// ThreadShare return reminder processor.
//
// This function should be called by Supabase Cron. It:
// 1) finds due enabled return reminders
// 2) creates an in-app notification for each
// 3) invokes send-push-notification for each notification
// 4) advances daily reminders or disables one-time reminders

type DueReminder = {
  id: string
  user_id: string
  borrow_request_id: string
  cadence: "one_time" | "daily"
  next_reminder_at: string
  last_sent_at: string | null
  borrow_requests: {
    id: string
    owner_id: string
    requester_id: string
    item_id: string
    status: string
    requested_end_date: string
    thread_items: {
      title: string
    } | null
  } | null
}

type NotificationInsert = {
  recipient_id: string
  actor_id: string | null
  kind: string
  title: string
  body: string
  item_id: string | null
  borrow_request_id: string | null
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
    const config = readConfig()
    const dueReminders = await fetchDueReminders(config)
    if (dueReminders.length === 0) {
      return json({ processed: 0, created_notifications: 0, pushed: 0 })
    }

    let createdNotifications = 0
    let pushed = 0
    const results: Array<Record<string, unknown>> = []

    for (const reminder of dueReminders) {
      const requestRow = reminder.borrow_requests
      if (!requestRow) {
        await disableReminder(config, reminder.id, "missing_borrow_request")
        results.push({ reminder_id: reminder.id, status: "disabled_missing_request" })
        continue
      }

      if (requestRow.status !== "approved") {
        await disableReminder(config, reminder.id, "borrow_request_not_approved")
        results.push({ reminder_id: reminder.id, status: "disabled_request_not_approved" })
        continue
      }

      const notificationBody = makeReminderBody(requestRow.thread_items?.title, requestRow.requested_end_date)
      const notificationID = await insertNotification(config, {
        recipient_id: reminder.user_id,
        actor_id: requestRow.owner_id,
        kind: "return_reminder",
        title: "Return reminder",
        body: notificationBody,
        item_id: requestRow.item_id,
        borrow_request_id: requestRow.id,
      })
      createdNotifications += 1

      const pushResult = await dispatchPush(config, notificationID)
      if (pushResult.ok) {
        pushed += 1
      }

      await advanceReminder(config, reminder)
      results.push({
        reminder_id: reminder.id,
        notification_id: notificationID,
        push_ok: pushResult.ok,
      })
    }

    return json({
      processed: dueReminders.length,
      created_notifications: createdNotifications,
      pushed,
      results,
    })
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : String(error) }, 500)
  }
})

function readConfig() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")
  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY")
  }
  return { supabaseUrl, serviceRoleKey }
}

function serviceHeaders(config: ReturnType<typeof readConfig>) {
  return {
    "apikey": config.serviceRoleKey,
    "authorization": `Bearer ${config.serviceRoleKey}`,
    "content-type": "application/json",
  }
}

async function fetchDueReminders(config: ReturnType<typeof readConfig>): Promise<DueReminder[]> {
  const nowISO = new Date().toISOString()
  const url = new URL(`${config.supabaseUrl}/rest/v1/return_reminders`)
  url.searchParams.set(
    "select",
    "id,user_id,borrow_request_id,cadence,next_reminder_at,last_sent_at,borrow_requests!inner(id,owner_id,requester_id,item_id,status,requested_end_date,thread_items(title))",
  )
  url.searchParams.set("is_enabled", "eq.true")
  url.searchParams.set("next_reminder_at", `lte.${nowISO}`)
  url.searchParams.set("order", "next_reminder_at.asc")
  url.searchParams.set("limit", "100")

  const response = await fetch(url, { headers: serviceHeaders(config) })
  if (!response.ok) {
    throw new Error(`Could not fetch due return reminders: ${response.status}`)
  }

  return await response.json() as DueReminder[]
}

function makeReminderBody(itemTitle: string | undefined, requestedEndDate: string) {
  const safeTitle = itemTitle && itemTitle.trim().length > 0 ? itemTitle : "your borrowed item"
  const dueDate = new Date(requestedEndDate).toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
    timeZone: "UTC",
  })
  return `Remember to return ${safeTitle} by ${dueDate}.`
}

async function insertNotification(config: ReturnType<typeof readConfig>, row: NotificationInsert): Promise<string> {
  const response = await fetch(`${config.supabaseUrl}/rest/v1/notifications`, {
    method: "POST",
    headers: {
      ...serviceHeaders(config),
      "prefer": "return=representation",
    },
    body: JSON.stringify(row),
  })
  if (!response.ok) {
    const body = await response.text()
    throw new Error(`Failed to create reminder notification: ${response.status} ${body}`)
  }

  const created = await response.json() as Array<{ id: string }>
  const id = created[0]?.id
  if (!id) {
    throw new Error("Notification insert succeeded but returned no id")
  }
  return id
}

async function dispatchPush(config: ReturnType<typeof readConfig>, notificationID: string): Promise<{ ok: boolean; status: number }> {
  const response = await fetch(`${config.supabaseUrl}/functions/v1/send-push-notification`, {
    method: "POST",
    headers: serviceHeaders(config),
    body: JSON.stringify({ notification_id: notificationID }),
  })
  return { ok: response.ok, status: response.status }
}

async function advanceReminder(config: ReturnType<typeof readConfig>, reminder: DueReminder) {
  const nowISO = new Date().toISOString()
  let patch: Record<string, unknown>

  if (reminder.cadence === "daily") {
    const next = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
    patch = {
      last_sent_at: nowISO,
      next_reminder_at: next,
      updated_at: nowISO,
      is_enabled: true,
    }
  } else {
    patch = {
      last_sent_at: nowISO,
      is_enabled: false,
      updated_at: nowISO,
    }
  }

  const response = await fetch(
    `${config.supabaseUrl}/rest/v1/return_reminders?id=eq.${reminder.id}`,
    {
      method: "PATCH",
      headers: serviceHeaders(config),
      body: JSON.stringify(patch),
    },
  )
  if (!response.ok) {
    const body = await response.text()
    throw new Error(`Failed to update reminder ${reminder.id}: ${response.status} ${body}`)
  }
}

async function disableReminder(config: ReturnType<typeof readConfig>, reminderID: string, reason: string) {
  const response = await fetch(
    `${config.supabaseUrl}/rest/v1/return_reminders?id=eq.${reminderID}`,
    {
      method: "PATCH",
      headers: serviceHeaders(config),
      body: JSON.stringify({
        is_enabled: false,
        updated_at: new Date().toISOString(),
      }),
    },
  )
  if (!response.ok) {
    const body = await response.text()
    throw new Error(`Failed to disable reminder ${reminderID} (${reason}): ${response.status} ${body}`)
  }
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  })
}
