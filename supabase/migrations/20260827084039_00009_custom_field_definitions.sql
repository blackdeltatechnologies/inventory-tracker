/*
# Create custom_field_definitions table

1. New Tables
- `custom_field_definitions`
  - `id` (uuid, PK)
  - `name` (text, NOT NULL)
  - `field_type` (text, CHECK text/number/date/boolean/select, NOT NULL)
  - `options` (jsonb, for select type)
  - `category_id` (uuid FK → categories ON DELETE SET NULL, null = global)
  - `is_required` (boolean, default false)
  - `created_at` (timestamptz, default now())

2. Security (RLS)
- All authenticated can SELECT.
- Only admins can INSERT/UPDATE/DELETE.
*/

CREATE TABLE IF NOT EXISTS public.custom_field_definitions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  field_type  text NOT NULL CHECK (field_type IN ('text', 'number', 'date', 'boolean', 'select')),
  options     jsonb,
  category_id uuid REFERENCES public.categories(id) ON DELETE SET NULL,
  is_required boolean NOT NULL DEFAULT false,
  created_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.custom_field_definitions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated can read custom_field_definitions" ON public.custom_field_definitions;
CREATE POLICY "Authenticated can read custom_field_definitions"
  ON public.custom_field_definitions FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Admins can insert custom_field_definitions" ON public.custom_field_definitions;
CREATE POLICY "Admins can insert custom_field_definitions"
  ON public.custom_field_definitions FOR INSERT TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Admins can update custom_field_definitions" ON public.custom_field_definitions;
CREATE POLICY "Admins can update custom_field_definitions"
  ON public.custom_field_definitions FOR UPDATE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Admins can delete custom_field_definitions" ON public.custom_field_definitions;
CREATE POLICY "Admins can delete custom_field_definitions"
  ON public.custom_field_definitions FOR DELETE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));