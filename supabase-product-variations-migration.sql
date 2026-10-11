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
