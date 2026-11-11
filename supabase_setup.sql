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
