-- Stackwise setup: paste into Supabase > SQL Editor and click Run.
create table if not exists public.workspaces (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references auth.users(id) on delete cascade,
  name text not null default 'My workspace',
  plan text not null default 'growth',
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

grant select, insert, update, delete on public.workspaces to authenticated;
grant all on public.workspaces to service_role;

alter table public.workspaces enable row level security;

drop policy if exists "Owners read workspace" on public.workspaces;
create policy "Owners read workspace" on public.workspaces
  for select to authenticated using (auth.uid() = owner_id);
drop policy if exists "Owners create workspace" on public.workspaces;
create policy "Owners create workspace" on public.workspaces
  for insert to authenticated with check (auth.uid() = owner_id);
drop policy if exists "Owners update workspace" on public.workspaces;
create policy "Owners update workspace" on public.workspaces
  for update to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
drop policy if exists "Owners delete workspace" on public.workspaces;
create policy "Owners delete workspace" on public.workspaces
  for delete to authenticated using (auth.uid() = owner_id);
