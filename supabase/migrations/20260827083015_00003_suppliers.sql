/*
# Create suppliers table

1. New Tables
- `suppliers`
  - `id` (uuid, PK)
  - `name` (text, not null)
  - `contact_person` (text)
  - `email` (text)
  - `phone` (text)
  - `address` (text)
  - `notes` (text)
  - `payment_terms` (text)
  - `lead_time_days` (integer)
  - `min_order_qty` (integer)
  - `created_at` (timestamptz, default now())
  - `updated_at` (timestamptz, auto-updated via trigger)

2. Indexes
- `idx_suppliers_name` on `name` for search.

3. Triggers
- `suppliers_updated_at` — BEFORE UPDATE trigger calling update_updated_at_column().

4. Security (RLS)
- All authenticated users can SELECT.
- Admin + manager can INSERT/UPDATE/DELETE.
*/

CREATE TABLE IF NOT EXISTS public.suppliers (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name           text NOT NULL,
  contact_person text,
  email          text,
  phone          text,
  address        text,
  notes          text,
  payment_terms  text,
  lead_time_days integer,
  min_order_qty  integer,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS suppliers_updated_at ON public.suppliers;
CREATE TRIGGER suppliers_updated_at
  BEFORE UPDATE ON public.suppliers
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_suppliers_name ON public.suppliers(name);

-- ─── RLS ─────────────────────────────────────────────────
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated can read suppliers" ON public.suppliers;
CREATE POLICY "Authenticated can read suppliers"
  ON public.suppliers FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Admin and manager can insert suppliers" ON public.suppliers;
CREATE POLICY "Admin and manager can insert suppliers"
  ON public.suppliers FOR INSERT
  TO authenticated
  WITH CHECK (
    public.has_role(auth.uid(), 'admin')
    OR public.has_role(auth.uid(), 'manager')
  );

DROP POLICY IF EXISTS "Admin and manager can update suppliers" ON public.suppliers;
CREATE POLICY "Admin and manager can update suppliers"
  ON public.suppliers FOR UPDATE
  TO authenticated
  USING (
    public.has_role(auth.uid(), 'admin')
    OR public.has_role(auth.uid(), 'manager')
  )
  WITH CHECK (
    public.has_role(auth.uid(), 'admin')
    OR public.has_role(auth.uid(), 'manager')
  );

DROP POLICY IF EXISTS "Admin and manager can delete suppliers" ON public.suppliers;
CREATE POLICY "Admin and manager can delete suppliers"
  ON public.suppliers FOR DELETE
  TO authenticated
  USING (
    public.has_role(auth.uid(), 'admin')
    OR public.has_role(auth.uid(), 'manager')
  );