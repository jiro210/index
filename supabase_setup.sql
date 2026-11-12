-- JFF - Jiro Financial Freedom: bảng lưu dữ liệu đồng bộ
-- Cách chạy: Supabase → SQL Editor → New query → dán toàn bộ file này → Run.
-- Chạy lại nhiều lần vẫn an toàn.

create table if not exists public.jff_data (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb       not null,
  rev        bigint      not null default 1,
  updated_at timestamptz not null default now()
);

-- Bật Row Level Security: mỗi người chỉ đọc/ghi được dòng dữ liệu của chính mình.
alter table public.jff_data enable row level security;

drop policy if exists "jff_select_own" on public.jff_data;
drop policy if exists "jff_insert_own" on public.jff_data;
drop policy if exists "jff_update_own" on public.jff_data;
drop policy if exists "jff_delete_own" on public.jff_data;

create policy "jff_select_own" on public.jff_data
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "jff_insert_own" on public.jff_data
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "jff_update_own" on public.jff_data
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "jff_delete_own" on public.jff_data
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- Người chưa đăng nhập (anon) không có quyền gì trên bảng này.
revoke all on public.jff_data from anon;
grant select, insert, update, delete on public.jff_data to authenticated;

-- ===== Các bản đã tải lên (giữ 5 bản mới nhất của mỗi tài khoản) =====
create table if not exists public.jff_backups (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  kind       text not null default 'manual' check (kind in ('manual', 'auto')),
  summary    jsonb not null default '{}'::jsonb,
  data       jsonb not null
);

create index if not exists jff_backups_user_created_idx on public.jff_backups (user_id, created_at desc);

alter table public.jff_backups enable row level security;

drop policy if exists "jff_backups_select_own" on public.jff_backups;
drop policy if exists "jff_backups_insert_own" on public.jff_backups;
drop policy if exists "jff_backups_delete_own" on public.jff_backups;

create policy "jff_backups_select_own" on public.jff_backups
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "jff_backups_insert_own" on public.jff_backups
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "jff_backups_delete_own" on public.jff_backups
  for delete to authenticated
  using ((select auth.uid()) = user_id);

revoke all on public.jff_backups from anon;
grant select, insert, delete on public.jff_backups to authenticated;

create or replace function public.jff_backups_keep_latest_5()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.jff_backups
  where user_id = new.user_id
    and id not in (
      select id from public.jff_backups
      where user_id = new.user_id
      order by created_at desc, id desc
      limit 5
    );
  return null;
end;
$$;

revoke all on function public.jff_backups_keep_latest_5() from public, anon, authenticated;

drop trigger if exists jff_backups_prune on public.jff_backups;
create trigger jff_backups_prune
  after insert on public.jff_backups
  for each row execute function public.jff_backups_keep_latest_5();
