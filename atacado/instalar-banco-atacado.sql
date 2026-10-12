-- BANCO EXCLUSIVO DA K D'PRAIA CANGAS — ATACADO
-- Execute em um NOVO projeto Supabase criado só para o atacado.
-- Não execute no banco do varejo. Este script não copia produtos ou pedidos.


-- ===== Arquivo original: supabase-schema.sql =====

-- K d'praia Cangas: esquema inicial Supabase
-- Execute no SQL Editor do projeto Supabase.
create table if not exists public.products (
  id bigint primary key,
  name text not null,
  category text not null check (category in ('Canga','Bolsa de praia')),
  price numeric(10,2) not null check (price >= 0),
  old_price numeric(10,2),
  tag text,
  description text default '',
  image_url text default '',
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;
alter table public.admin_users enable row level security;

-- Permissões SQL base; as políticas RLS abaixo continuam controlando o acesso às linhas.
grant usage on schema public to anon, authenticated;
grant select on public.products to anon, authenticated;
grant insert, update, delete on public.products to authenticated;
grant select on public.admin_users to authenticated;

drop policy if exists "Anyone can view active products" on public.products;
create policy "Anyone can view active products" on public.products for select using (active = true);
drop policy if exists "Admins can manage products" on public.products;
create policy "Admins can manage products" on public.products for all to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = auth.uid()))
with check (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));
drop policy if exists "Admins can read own admin record" on public.admin_users;
create policy "Admins can read own admin record" on public.admin_users for select to authenticated using (user_id = auth.uid());

insert into storage.buckets (id, name, public) values ('product-images','product-images',true) on conflict (id) do nothing;
drop policy if exists "Public can view product images" on storage.objects;
create policy "Public can view product images" on storage.objects for select using (bucket_id = 'product-images');
drop policy if exists "Admins can upload product images" on storage.objects;
create policy "Admins can upload product images" on storage.objects for insert to authenticated
with check (bucket_id = 'product-images' and exists (select 1 from public.admin_users a where a.user_id = auth.uid()));
drop policy if exists "Admins can update product images" on storage.objects;
create policy "Admins can update product images" on storage.objects for update to authenticated
using (bucket_id = 'product-images' and exists (select 1 from public.admin_users a where a.user_id = auth.uid()))
with check (bucket_id = 'product-images' and exists (select 1 from public.admin_users a where a.user_id = auth.uid()));
drop policy if exists "Admins can delete product images" on storage.objects;
create policy "Admins can delete product images" on storage.objects for delete to authenticated
using (bucket_id = 'product-images' and exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

-- Depois de criar o usuário administrador em Authentication > Users, copie o UUID dele e execute:
-- insert into public.admin_users (user_id) values ('COLE-AQUI-O-UUID-DO-USUARIO');


-- ===== Arquivo original: supabase-settings-migration.sql =====

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


-- ===== Arquivo original: supabase-order-tracking-migration.sql =====

-- Acompanhamento de pedidos da K d'praia Cangas
-- Execute este arquivo UMA VEZ no SQL Editor do Supabase.
alter table public.orders
  add column if not exists customer_email text not null default '',
  add column if not exists tracking_code text not null default '';

grant update on public.orders to authenticated;

-- Clientes podem consultar somente os campos necessários, informando número do pedido e e-mail.
-- A função não expõe endereço, observações privadas ou dados administrativos.
create or replace function public.track_customer_order(p_order_number text, p_email text)
returns table (
  order_number text,
  customer_name text,
  status text,
  items jsonb,
  subtotal numeric,
  shipping_cost numeric,
  total numeric,
  tracking_code text,
  created_at timestamptz,
  updated_at timestamptz
)
language sql
security definer
set search_path = public
stable
as $$
  select o.order_number, o.customer_name, o.status, o.items, o.subtotal,
         o.shipping_cost, o.total, o.tracking_code, o.created_at, o.updated_at
  from public.orders o
  where lower(trim(o.order_number)) = lower(trim(p_order_number))
    and lower(trim(o.customer_email)) = lower(trim(p_email))
  limit 1;
$$;

revoke all on function public.track_customer_order(text,text) from public;
grant execute on function public.track_customer_order(text,text) to anon, authenticated;

-- Admin-only RLS policy already governs updates to orders. Do not add public SELECT access.


-- Histórico completo por e-mail, ordenado do pedido mais recente ao mais antigo.
create or replace function public.track_customer_orders(p_email text)
returns table (
  order_number text,
  customer_name text,
  status text,
  items jsonb,
  subtotal numeric,
  shipping_cost numeric,
  total numeric,
  tracking_code text,
  created_at timestamptz,
  updated_at timestamptz
)
language sql
security definer
set search_path = public
stable
as $$
  select o.order_number, o.customer_name, o.status, o.items, o.subtotal,
         o.shipping_cost, o.total, o.tracking_code, o.created_at, o.updated_at
  from public.orders o
  where lower(trim(o.customer_email)) = lower(trim(p_email))
    and coalesce(trim(p_email), '') <> ''
  order by o.created_at desc;
$$;

revoke all on function public.track_customer_orders(text) from public;
grant execute on function public.track_customer_orders(text) to anon, authenticated;


-- ===== Arquivo original: supabase-product-variations-migration.sql =====

-- Galeria de fotos, acabamento e tamanho único para produtos da K d'praia Cangas
-- Execute uma vez no SQL Editor do Supabase.
alter table public.products
  add column if not exists images jsonb not null default '[]'::jsonb,
  add column if not exists finishes jsonb not null default '[]'::jsonb,
  add column if not exists size_label text not null default 'Tamanho único';

update public.products
set images = case
  when coalesce(image_url, '') <> '' then jsonb_build_array(image_url)
  else '[]'::jsonb
end
where images = '[]'::jsonb and coalesce(image_url, '') <> '';

notify pgrst, 'reload schema';


-- ===== Arquivo original: supabase-product-sku-migration.sql =====

-- SKU automático e exclusivo para todos os produtos da K d'praia Cangas.
-- Execute UMA VEZ no SQL Editor do Supabase.
alter table public.products
  add column if not exists sku text;

create sequence if not exists public.products_sku_seq start with 1001;

update public.products
set sku = 'KDP-' || lpad(nextval('public.products_sku_seq')::text, 5, '0')
where sku is null or trim(sku) = '';

create unique index if not exists products_sku_unique_idx
  on public.products (sku);

create or replace function public.assign_product_sku()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.sku is null or trim(new.sku) = '' then
    new.sku := 'KDP-' || lpad(nextval('public.products_sku_seq')::text, 5, '0');
  end if;
  return new;
end;
$$;

drop trigger if exists products_assign_sku on public.products;
create trigger products_assign_sku
before insert or update of sku on public.products
for each row execute function public.assign_product_sku();

notify pgrst, 'reload schema';


-- ===== Arquivo original: supabase-discount-migration.sql =====

-- Campos de desconto dos pedidos da K d'praia Cangas
-- Execute este arquivo uma única vez no SQL Editor do Supabase.
alter table public.orders
  add column if not exists discount_type text not null default 'fixed',
  add column if not exists discount_amount numeric(10,2) not null default 0;

alter table public.orders
  drop constraint if exists orders_discount_type_check;

alter table public.orders
  add constraint orders_discount_type_check
  check (discount_type in ('fixed', 'percent'));

alter table public.orders
  drop constraint if exists orders_discount_amount_nonnegative_check;

alter table public.orders
  add constraint orders_discount_amount_nonnegative_check
  check (discount_amount >= 0);

-- Solicita ao PostgREST/Supabase atualizar o cache de schema após criar as colunas.
notify pgrst, 'reload schema';


-- Atualiza o cache do Supabase/PostgREST.
notify pgrst, 'reload schema';
