-- Normaliza "Servidores Privados" para dejar solo:
-- - Bronzerbeard
-- - Project Epoch - Kezan
-- - Project Epoch - Gurubashi
-- y paquetes únicamente de 100g a 1000g.
--
-- También conserva "WoW Oficial" sin modificar.

begin;

-- 1) Eliminar servidores no deseados en "Servidores Privados"
delete from public.game_servers
where game = 'Servidores Privados'
  and name not in ('Bronzerbeard', 'Project Epoch - Kezan', 'Project Epoch - Gurubashi');

-- 2) Eliminar paquetes no deseados en "Servidores Privados"
--    a) servidores no permitidos
delete from public.gold
where game = 'Servidores Privados'
  and server not in ('Bronzerbeard', 'Project Epoch - Kezan', 'Project Epoch - Gurubashi');

--    b) montos fuera del rango 100..1000
delete from public.gold
where game = 'Servidores Privados'
  and (
    amount::numeric < 100
    or amount::numeric > 1000
    or mod(amount::numeric, 100) <> 0
  );

-- 3) Asegurar los 3 servidores requeridos
with src(game, name) as (
  values
    ('Servidores Privados'::text, 'Bronzerbeard'::text),
    ('Servidores Privados', 'Project Epoch - Kezan'),
    ('Servidores Privados', 'Project Epoch - Gurubashi')
)
insert into public.game_servers (game, name)
select s.game, s.name
from src s
where not exists (
  select 1
  from public.game_servers gs
  where gs.game = s.game
    and gs.name = s.name
);

-- 4) Generar paquetes 100,200,...,1000 con precios solicitados
with rates(server, rate_per_100) as (
  values
    ('Bronzerbeard'::text, 4.50::numeric),
    ('Project Epoch - Kezan'::text, 12.00::numeric),
    ('Project Epoch - Gurubashi'::text, 13.00::numeric)
),
amounts(amount) as (
  select generate_series(100, 1000, 100)::int
),
src as (
  select
    'Servidores Privados'::text as game,
    r.server,
    a.amount,
    round((a.amount::numeric / 100.0) * r.rate_per_100, 2) as price
  from rates r
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

with rates(server, rate_per_100) as (
  values
    ('Bronzerbeard'::text, 4.50::numeric),
    ('Project Epoch - Kezan'::text, 12.00::numeric),
    ('Project Epoch - Gurubashi'::text, 13.00::numeric)
),
amounts(amount) as (
  select generate_series(100, 1000, 100)::int
),
src as (
  select
    'Servidores Privados'::text as game,
    r.server,
    a.amount,
    round((a.amount::numeric / 100.0) * r.rate_per_100, 2) as price
  from rates r
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
where game in ('Servidores Privados', 'WoW Oficial')
order by game, server, amount;
