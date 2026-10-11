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
