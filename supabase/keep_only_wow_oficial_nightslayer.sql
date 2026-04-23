-- Limpieza y normalización para dejar solo WoW Oficial con Nightslayer A/H
-- y paquetes desde 100g hasta 1000g.
--
-- También elimina:
-- - categoría WoW TBC y sus datos
-- - servidores/paquetes de Bronzerbeard y Project Epoch

begin;

-- 1) Eliminar categoría y datos de WoW TBC
delete from public.gold where game = 'WoW TBC';
delete from public.game_servers where game = 'WoW TBC';
delete from public.gold_categories where game = 'WoW TBC' or name = 'WoW TBC';

-- 2) Eliminar paquetes/servidores de Private que no deseas
delete from public.gold
where game = 'Servidores Privados'
  and server in ('Bronzerbeard', 'Project Epoch - Kezan', 'Project Epoch - Gurubashi');

delete from public.game_servers
where game = 'Servidores Privados'
  and name in ('Bronzerbeard', 'Project Epoch - Kezan', 'Project Epoch - Gurubashi');

-- 3) Asegurar categoría WoW Oficial
insert into public.gold_categories (name, game, description, image)
select
  'WoW Oficial'::text,
  'WoW Oficial'::text,
  'Oro para WoW Oficial - servidor Nightslayer A/H.'::text,
  'https://i.imgur.com/ynvAS9B.png'::text
where not exists (
  select 1
  from public.gold_categories gc
  where gc.game = 'WoW Oficial'
);

-- 4) Asegurar servidor Nightslayer A/H
insert into public.game_servers (game, name)
select 'WoW Oficial'::text, 'Nightslayer A/H'::text
where not exists (
  select 1
  from public.game_servers gs
  where gs.game = 'WoW Oficial'
    and gs.name = 'Nightslayer A/H'
);

-- 5) Limpiar paquetes de WoW Oficial fuera de 100..1000 (múltiplos de 100)
delete from public.gold
where game = 'WoW Oficial'
  and server = 'Nightslayer A/H'
  and (
    amount::numeric < 100
    or amount::numeric > 1000
    or mod(amount::numeric, 100) <> 0
  );

-- 6) Crear/actualizar paquetes 100,200,...,1000 (2.50 USD por cada 100g)
with src as (
  select
    'WoW Oficial'::text as game,
    'Nightslayer A/H'::text as server,
    gs.amount::int as amount,
    round((gs.amount::numeric / 100.0) * 2.50::numeric, 2) as price
  from generate_series(100, 1000, 100) gs(amount)
)
update public.gold g
set
  price = src.price,
  updated_at = now()
from src
where g.game = src.game
  and g.server = src.server
  and g.amount::text = src.amount::text;

with src as (
  select
    'WoW Oficial'::text as game,
    'Nightslayer A/H'::text as server,
    gs.amount::int as amount,
    round((gs.amount::numeric / 100.0) * 2.50::numeric, 2) as price
  from generate_series(100, 1000, 100) gs(amount)
)
insert into public.gold (game, server, amount, price)
select src.game, src.server, src.amount, src.price
from src
where not exists (
  select 1
  from public.gold g
  where g.game = src.game
    and g.server = src.server
    and g.amount::text = src.amount::text
);

commit;

-- Verificación rápida
select game, server, amount, price
from public.gold
where game = 'WoW Oficial'
  and server = 'Nightslayer A/H'
order by amount;
