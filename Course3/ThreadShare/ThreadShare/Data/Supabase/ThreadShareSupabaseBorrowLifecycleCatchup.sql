-- ThreadShare borrow lifecycle catch-up migration
-- Adds borrower-return handoff support for owner confirmation workflow.

alter table public.borrow_requests
    add column if not exists borrower_marked_returned_at timestamptz;
