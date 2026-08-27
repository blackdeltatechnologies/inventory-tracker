/*
# Create purchase_orders and purchase_order_items tables

1. New Tables
- `purchase_orders`
  - `id` (uuid, PK)
  - `supplier_id` (uuid FK → suppliers ON DELETE RESTRICT, NOT NULL)
  - `status` (text, CHECK draft/submitted/partial/received/cancelled, default 'draft')
  - `expected_delivery_date` (date)
  - `notes` (text)
  - `created_by` (uuid FK → auth.users ON DELETE SET NULL)
  - `created_at` (timestamptz, default now())
  - `updated_at` (timestamptz, auto-updated via trigger)

- `purchase_order_items`
  - `id` (uuid, PK)
  - `purchase_order_id` (uuid FK → purchase_orders ON DELETE CASCADE, NOT NULL)
  - `item_id` (uuid FK → items ON DELETE RESTRICT, NOT NULL)
  - `quantity_ordered` (integer, NOT NULL)
  - `quantity_received` (integer, default 0)
  - `unit_cost` (numeric(10,2))

2. Indexes
- purchase_orders: supplier_id, status, created_by
- purchase_order_items: purchase_order_id, item_id

3. Triggers
- `purchase_orders_updated_at` — BEFORE UPDATE trigger.

4. Security (RLS)
- Both tables: all authenticated can SELECT; admin + manager can INSERT/UPDATE/DELETE.
*/

CREATE TABLE IF NOT EXISTS public.purchase_orders (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id            uuid NOT NULL REFERENCES public.suppliers(id) ON DELETE RESTRICT,
  status                 text NOT NULL DEFAULT 'draft'
                         CHECK (status IN ('draft', 'submitted', 'partial', 'received', 'cancelled')),
  expected_delivery_date date,
  notes                  text,
  created_by             uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS purchase_orders_updated_at ON public.purchase_orders;
CREATE TRIGGER purchase_orders_updated_at
  BEFORE UPDATE ON public.purchase_orders
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_purchase_orders_supplier_id ON public.purchase_orders(supplier_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_status ON public.purchase_orders(status);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_created_by ON public.purchase_orders(created_by);

ALTER TABLE public.purchase_orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated can read purchase_orders" ON public.purchase_orders;
CREATE POLICY "Authenticated can read purchase_orders"
  ON public.purchase_orders FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Admin and manager can insert purchase_orders" ON public.purchase_orders;
CREATE POLICY "Admin and manager can insert purchase_orders"
  ON public.purchase_orders FOR INSERT TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'));

DROP POLICY IF EXISTS "Admin and manager can update purchase_orders" ON public.purchase_orders;
CREATE POLICY "Admin and manager can update purchase_orders"
  ON public.purchase_orders FOR UPDATE TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'))
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'));

DROP POLICY IF EXISTS "Admin and manager can delete purchase_orders" ON public.purchase_orders;
CREATE POLICY "Admin and manager can delete purchase_orders"
  ON public.purchase_orders FOR DELETE TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'));

-- ─── Line Items ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.purchase_order_items (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_order_id uuid NOT NULL REFERENCES public.purchase_orders(id) ON DELETE CASCADE,
  item_id           uuid NOT NULL REFERENCES public.items(id) ON DELETE RESTRICT,
  quantity_ordered  integer NOT NULL,
  quantity_received integer NOT NULL DEFAULT 0,
  unit_cost         numeric(10,2)
);

CREATE INDEX IF NOT EXISTS idx_po_items_purchase_order_id ON public.purchase_order_items(purchase_order_id);
CREATE INDEX IF NOT EXISTS idx_po_items_item_id ON public.purchase_order_items(item_id);

ALTER TABLE public.purchase_order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated can read purchase_order_items" ON public.purchase_order_items;
CREATE POLICY "Authenticated can read purchase_order_items"
  ON public.purchase_order_items FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Admin and manager can insert purchase_order_items" ON public.purchase_order_items;
CREATE POLICY "Admin and manager can insert purchase_order_items"
  ON public.purchase_order_items FOR INSERT TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'));

DROP POLICY IF EXISTS "Admin and manager can update purchase_order_items" ON public.purchase_order_items;
CREATE POLICY "Admin and manager can update purchase_order_items"
  ON public.purchase_order_items FOR UPDATE TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'))
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'));

DROP POLICY IF EXISTS "Admin and manager can delete purchase_order_items" ON public.purchase_order_items;
CREATE POLICY "Admin and manager can delete purchase_order_items"
  ON public.purchase_order_items FOR DELETE TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'manager'));