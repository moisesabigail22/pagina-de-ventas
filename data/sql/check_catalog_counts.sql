-- Revisa si hay datos en las tablas del catálogo
select
  (select count(*) from gold) as gold,
  (select count(*) from services) as services,
  (select count(*) from gold_categories) as gold_categories,
  (select count(*) from game_servers) as game_servers,
  (select count(*) from accounts) as accounts,
  (select count(*) from customer_references) as customer_references,
  (select count(*) from settings) as settings;
