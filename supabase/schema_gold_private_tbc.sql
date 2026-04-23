-- Schema específico: categorías de oro para "Servidores Privados" y "WoW TBC"
-- con precios por cada 100g para Bronzebear, Kezan y Gurubashi.
--
-- Tarifas solicitadas:
-- - Bronzebear: 4.5 USD por cada 100g
-- - Kezan:      12 USD por cada 100g
-- - Gurubashi:  13 USD por cada 100g
--
-- Este script genera paquetes de 100g, 200g, 300g... hasta 5000g.
-- Si quieres más o menos, cambia max_amount en el CTE "config".

begin;

-- 1) Asegurar categorías de juego (oro)
insert into public.gold_categories (name, game, description, image)
select *
from (
  values
    (
      'Servidores Privados'::text,
      'Servidores Privados'::text,
      'Oro para servidores privados (Bronzebear, Kezan y Gurubashi).'::text,
      'https://i.imgur.com/ynvAS9B.png'::text
    ),
    (
      'WoW TBC'::text,
      'WoW TBC'::text,
      'Oro para WoW TBC (Bronzebear, Kezan y Gurubashi).'::text,
      'https://i.imgur.com/ynvAS9B.png'::text
    )
) as src(name, game, description, image)
where not exists (
  select 1
  from public.gold_categories gc
  where gc.game = src.game
);

-- 2) Asegurar servidores de cada categoría
with src(game, name) as (
  values
    ('Servidores Privados'::text, 'Bronzebear'::text),
    ('Servidores Privados', 'Kezan'),
    ('Servidores Privados', 'Gurubashi'),
    ('WoW TBC', 'Bronzebear'),
    ('WoW TBC', 'Kezan'),
    ('WoW TBC', 'Gurubashi')
)
insert into public.game_servers (game, name)
select src.game, src.name
from src
where not exists (
  select 1
  from public.game_servers gs
  where gs.game = src.game
    and gs.name = src.name
);

-- 3) Crear/actualizar paquetes de oro por tramos de 100g
with
config as (
  select 5000::int as max_amount, 100::int as step_amount
),
rates(server, rate_per_100) as (
  values
    ('Bronzebear'::text, 4.50::numeric),
    ('Kezan'::text,      12.00::numeric),
    ('Gurubashi'::text,  13.00::numeric)
),
games(game) as (
  values
    ('Servidores Privados'::text),
    ('WoW TBC'::text)
),
amounts(amount) as (
  select generate_series(
    (select step_amount from config),
    (select max_amount from config),
    (select step_amount from config)
  )::int
),
src as (
  select
    g.game,
    r.server,
    a.amount,
    round((a.amount::numeric / 100.0) * r.rate_per_100, 2) as price
  from games g
  cross join rates r
  cross join amounts a
)
update public.gold g
set
  price = src.price,
  updated_at = now()
from src
where g.game = src.game
  and g.server = src.server
  and g.amount::text = src.amount::text;

with
config as (
  select 5000::int as max_amount, 100::int as step_amount
),
rates(server, rate_per_100) as (
  values
    ('Bronzebear'::text, 4.50::numeric),
    ('Kezan'::text,      12.00::numeric),
    ('Gurubashi'::text,  13.00::numeric)
),
games(game) as (
  values
    ('Servidores Privados'::text),
    ('WoW TBC'::text)
),
amounts(amount) as (
  select generate_series(
    (select step_amount from config),
    (select max_amount from config),
    (select step_amount from config)
  )::int
),
src as (
  select
    g.game,
    r.server,
    a.amount,
    round((a.amount::numeric / 100.0) * r.rate_per_100, 2) as price
  from games g
  cross join rates r
  cross join amounts a
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
where game in ('Servidores Privados', 'WoW TBC')
  and server in ('Bronzebear', 'Kezan', 'Gurubashi')
order by game, server, amount
limit 30;
