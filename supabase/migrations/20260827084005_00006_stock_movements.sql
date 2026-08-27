/*
# Create stock_movements table

1. New Tables
- `stock_movements`
  - `id` (uuid, PK)
  - `item_id` (uuid FK → items ON DELETE CASCADE, NOT NULL)
  - `quantity` (integer, NOT NULL)
  - `direction` (text, CHECK in/out, NOT NULL)
  - `movement_type` (text, CHECK received/shipped/adjusted/transferred, NOT NULL)
  - `reference_note` (text)
  - `performed_by` (uuid FK → auth.users ON DELETE SET NULL)
  - `from_location_id` (uuid FK → locations ON DELETE SET NULL)
  - `to_location_id` (uuid FK → locations ON DELETE SET NULL)
  - `resulting_quantity` (integer, NOT NULL)
  - `created_at` (timestamptz, default now())

2. Indexes
- item_id, created_at, movement_type, performed_by

3. Security (RLS)
- All authenticated can SELECT.
- Admin + manager can INSERT only.
- No UPDATE or DELETE — audit trail is immutable.
*/

CREATE TABLE IF NOT EXISTS public.stock_movements (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id            uuid NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
  quantity           integer NOT NULL,
  direction          text NOT NULL CHECK (direction IN ('in', 'out')),
  movement_type      text NOT NULL CHECK (movement_type IN ('received', 'shipped', 'adjusted', 'transferred')),
  reference_note     text,
  performed_by       uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  from_location_id   uuid REFERENCES public.locations(id) ON DELETE SET NULL,
  to_location_id     uuid REFERENCES public.locations(id) ON DELETE SET NULL,
  resulting_quantity  integer NOT NULL,
  created_at         timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stock_movements_item_id ON public.stock_movements(item_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_created_at ON public.stock_movements(created_at);
CREATE INDEX IF NOT EXISTS idx_stock_movements_type ON public.stock_movements(movement_type);
CREATE INDEX IF NOT EXISTS idx_stock_movements_performed_by ON public.stock_movements(performed_by);

ALTER TABLE public.stock_movements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated can read movements" ON public.stock_movements;
CREATE POLICY "Authenticated can read movements"
  ON public.stock_movements FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Admin and manager can insert movements" ON public.stock_movements;
CREATE POLICY "Admin and manager can insert movements"
  ON public.stock_movements FOR INSERT
  TO authenticated
  WITH CHECK (
    public.has_role(auth.uid(), 'admin')
    OR public.has_role(auth.uid(), 'manager')
  );