-- Borra TODO el catálogo (incluye oro, servicios y tablas relacionadas)
-- Compatible con Supabase Postgres

begin;

truncate table
  services,
  customer_references,
  accounts,
  gold,
  game_servers,
  gold_categories,
  settings
restart identity cascade;

commit;
