-- Execute uma única vez no SQL Editor do Supabase.
create table if not exists public.store_settings (
  id integer primary key check (id = 1),
  brand text not null default 'K d''praia Cangas',
  whatsapp text not null default '5585997102886',
  updated_at timestamptz not null default now()
);

alter table public.store_settings enable row level security;

create or replace function public.is_store_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admin_users
    where user_id = auth.uid()
  );
$$;

revoke all on function public.is_store_admin() from public;
grant execute on function public.is_store_admin() to authenticated;

grant select on public.store_settings to anon, authenticated;
grant insert, update on public.store_settings to authenticated;

drop policy if exists "Anyone can read store settings" on public.store_settings;
create policy "Anyone can read store settings"
on public.store_settings for select
to anon, authenticated
using (true);

drop policy if exists "Store admins can insert settings" on public.store_settings;
create policy "Store admins can insert settings"
on public.store_settings for insert
to authenticated
with check (public.is_store_admin());

drop policy if exists "Store admins can update settings" on public.store_settings;
create policy "Store admins can update settings"
on public.store_settings for update
to authenticated
using (public.is_store_admin())
with check (public.is_store_admin());

insert into public.store_settings (id, brand, whatsapp)
values (1, 'K d''praia Cangas', '5585997102886')
on conflict (id) do nothing;
