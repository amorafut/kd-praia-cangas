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
