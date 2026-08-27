/*
# Create notifications table

1. New Tables
- `notifications`
  - `id` (uuid, PK)
  - `user_id` (uuid FK → auth.users ON DELETE CASCADE, NOT NULL)
  - `type` (text, NOT NULL)
  - `title` (text, NOT NULL)
  - `message` (text)
  - `is_read` (boolean, default false)
  - `reference_id` (uuid, generic entity pointer)
  - `reference_type` (text)
  - `created_at` (timestamptz, default now())

2. Indexes
- Composite index on (user_id, is_read) for unread count queries.

3. Security (RLS)
- Users can only read/update their own notifications.
*/

CREATE TABLE IF NOT EXISTS public.notifications (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type            text NOT NULL,
  title           text NOT NULL,
  message         text,
  is_read         boolean NOT NULL DEFAULT false,
  reference_id    uuid,
  reference_type  text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON public.notifications(user_id, is_read);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own notifications" ON public.notifications;
CREATE POLICY "Users can read own notifications"
  ON public.notifications FOR SELECT TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
CREATE POLICY "Users can update own notifications"
  ON public.notifications FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());