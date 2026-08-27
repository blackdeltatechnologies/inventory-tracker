/*
# Create categories table

1. New Tables
- `categories`
  - `id` (uuid, PK, default gen_random_uuid())
  - `name` (text, not null)
  - `parent_id` (uuid, self-referencing FK ON DELETE SET NULL for hierarchy)
  - `description` (text)
  - `created_at` (timestamptz, default now())

2. Indexes
- `idx_categories_parent_id` on `parent_id` for hierarchy queries.

3. Security (RLS)
- All authenticated users can SELECT.
- Only admins can INSERT/UPDATE/DELETE (via has_role check).
*/

CREATE TABLE IF NOT EXISTS public.categories (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  parent_id   uuid REFERENCES public.categories(id) ON DELETE SET NULL,
  description text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON public.categories(parent_id);

-- ─── RLS ─────────────────────────────────────────────────
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated can read categories" ON public.categories;
CREATE POLICY "Authenticated can read categories"
  ON public.categories FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Admins can insert categories" ON public.categories;
CREATE POLICY "Admins can insert categories"
  ON public.categories FOR INSERT
  TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Admins can update categories" ON public.categories;
CREATE POLICY "Admins can update categories"
  ON public.categories FOR UPDATE
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Admins can delete categories" ON public.categories;
CREATE POLICY "Admins can delete categories"
  ON public.categories FOR DELETE
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));