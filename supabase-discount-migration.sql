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