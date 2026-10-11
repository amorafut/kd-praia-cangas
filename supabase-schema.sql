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
