-- Trading day map: one row per user holding their journal data
-- (uploaded statements, Day view fills and rules, same shape as the backup file).
-- Paste this whole file into Supabase > SQL Editor > New query, then press Run.

create table if not exists public.journal (
  user_id    uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Row level security: every signed-in user can read and write only their own row.
alter table public.journal enable row level security;

drop policy if exists "journal: read own row"   on public.journal;
drop policy if exists "journal: insert own row" on public.journal;
drop policy if exists "journal: update own row" on public.journal;
drop policy if exists "journal: delete own row" on public.journal;

create policy "journal: read own row" on public.journal
  for select to authenticated using ((select auth.uid()) = user_id);

create policy "journal: insert own row" on public.journal
  for insert to authenticated with check ((select auth.uid()) = user_id);

create policy "journal: update own row" on public.journal
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy "journal: delete own row" on public.journal
  for delete to authenticated using ((select auth.uid()) = user_id);

-- Signed-out visitors get no access at all.
revoke all on public.journal from anon;
grant select, insert, update, delete on public.journal to authenticated;
