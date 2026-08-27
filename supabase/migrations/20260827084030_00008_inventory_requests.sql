/*
# Create inventory_requests and request_items tables

1. New Tables
- `inventory_requests`
  - `id` (uuid, PK)
  - `requested_by` (uuid FK → auth.users ON DELETE CASCADE, NOT NULL)
  - `status` (text, CHECK pending/approved/fulfilled/declined, default 'pending')
  - `reason` (text)
  - `project_reference` (text)
  - `reviewed_by` (uuid FK → auth.users ON DELETE SET NULL)
  - `reviewed_at` (timestamptz)
  - `created_at` (timestamptz, default now())
  - `updated_at` (timestamptz, auto-updated via trigger)

- `request_items`
  - `id` (uuid, PK)
  - `request_id` (uuid FK → inventory_requests ON DELETE CASCADE, NOT NULL)
  - `item_id` (uuid FK → items ON DELETE RESTRICT, NOT NULL)
  - `quantity` (integer, NOT NULL)

2. Indexes
- inventory_requests: requested_by, status
- request_items: request_id, item_id

3. Security (RLS)
- inventory_requests: requestors read own + insert own; admin+manager read all + update.
- request_items: readable if parent request visible; insert only for own requests.
*/

CREATE TABLE IF NOT EXISTS public.inventory_requests (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requested_by      uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status            text NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'approved', 'fulfilled', 'declined')),
  reason            text,
  project_reference text,
  reviewed_by       uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  reviewed_at       timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS inventory_requests_updated_at ON public.inventory_requests;
CREATE TRIGGER inventory_requests_updated_at
  BEFORE UPDATE ON public.inventory_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_inventory_requests_requested_by ON public.inventory_requests(requested_by);
CREATE INDEX IF NOT EXISTS idx_inventory_requests_status ON public.inventory_requests(status);

ALTER TABLE public.inventory_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own requests" ON public.inventory_requests;
CREATE POLICY "Users can read own requests"
  ON public.inventory_requests FOR SELECT TO authenticated
  USING (requested_by = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'));

DROP POLICY IF EXISTS "Authenticated can insert requests" ON public.inventory_requests;
CREATE POLICY "Authenticated can insert requests"
  ON public.inventory_requests FOR INSERT TO authenticated
  WITH CHECK (requested_by = auth.uid());

DROP POLICY IF EXISTS "Admin and manager can update requests" ON public.inventory_requests;
CREATE POLICY "Admin and manager can update requests"
  ON public.inventory_requests FOR UPDATE TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'))
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'));

-- ─── Request Items ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.request_items (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL REFERENCES public.inventory_requests(id) ON DELETE CASCADE,
  item_id    uuid NOT NULL REFERENCES public.items(id) ON DELETE RESTRICT,
  quantity   integer NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_request_items_request_id ON public.request_items(request_id);
CREATE INDEX IF NOT EXISTS idx_request_items_item_id ON public.request_items(item_id);

ALTER TABLE public.request_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own request items" ON public.request_items;
CREATE POLICY "Users can read own request items"
  ON public.request_items FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.inventory_requests r WHERE r.id = request_id AND (r.requested_by = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'))));

DROP POLICY IF EXISTS "Users can insert own request items" ON public.request_items;
CREATE POLICY "Users can insert own request items"
  ON public.request_items FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.inventory_requests r WHERE r.id = request_id AND r.requested_by = auth.uid()));