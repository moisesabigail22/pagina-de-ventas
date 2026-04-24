-- Schema: Servidores Privados + WoW TBC con imágenes y paquetes 100..1000
-- Ajusta estas URLs si quieres usar otras:
--   private_servers_image_url: imagen de "Private Servers"
--   wow_tbc_green_image_url: imagen verde de "WoW TBC"

begin;

-- 1) Crear/actualizar categorías con imágenes
insert into public.gold_categories (name, game, description, image)
select
  'Servidores Privados',
  'Servidores Privados',
  'Oro para servidores privados (paquetes de 100g a 1000g).',
  'https://example.com/private-servers.jpg'
where not exists (
  select 1 from public.gold_categories gc where gc.game = 'Servidores Privados'
);

update public.gold_categories
set
  name = 'Servidores Privados',
  description = 'Oro para servidores privados (paquetes de 100g a 1000g).',
  image = 'https://example.com/private-servers.jpg'
where game = 'Servidores Privados';

insert into public.gold_categories (name, game, description, image)
select
  'WoW TBC',
  'WoW TBC',
  'World of Warcraft: The Burning Crusade (imagen verde).',
  'https://example.com/wow-tbc-green.jpg'
where not exists (
  select 1 from public.gold_categories gc where gc.game = 'WoW TBC'
);

update public.gold_categories
set
  name = 'WoW TBC',
  description = 'World of Warcraft: The Burning Crusade (imagen verde).',
  image = 'https://example.com/wow-tbc-green.jpg'
where game = 'WoW TBC';

-- 2) Asegurar servidores en "Servidores Privados"
with private_servers as (
  select unnest(array[
    'Bronzerbeard'::text,
    'Project Epoch - Kezan'::text,
    'Project Epoch - Gurubashi'::text
  ]) as server_name
)
insert into public.game_servers (game, name)
select 'Servidores Privados', ps.server_name
from private_servers ps
where not exists (
  select 1
  from public.game_servers gs
  where gs.game = 'Servidores Privados'
    and gs.name = ps.server_name
);

-- 3) Limpiar paquetes fuera de 100..1000 para estos servidores
with private_servers as (
  select unnest(array[
    'Bronzerbeard'::text,
    'Project Epoch - Kezan'::text,
    'Project Epoch - Gurubashi'::text
  ]) as server_name
)
delete from public.gold g
using private_servers ps
where g.game = 'Servidores Privados'
  and g.server = ps.server_name
  and (
    g.amount::numeric < 100
    or g.amount::numeric > 1000
    or mod(g.amount::numeric, 100) <> 0
  );

-- 4) Upsert de paquetes 100..1000 con misma lógica de precio que WoW Oficial (2.50 / 100g)
with private_servers as (
  select unnest(array[
    'Bronzerbeard'::text,
    'Project Epoch - Kezan'::text,
    'Project Epoch - Gurubashi'::text
  ]) as server_name
),
src as (
  select
    'Servidores Privados'::text as game,
    ps.server_name::text as server,
    p.amount::int as amount,
    round((p.amount::numeric / 100.0) * 2.50::numeric, 2) as price
  from private_servers ps
  cross join generate_series(100, 1000, 100) p(amount)
)
update public.gold g
set
  price = src.price,
  updated_at = now()
from src
where g.game = src.game
  and g.server = src.server
  and g.amount::text = src.amount::text;

with private_servers as (
  select unnest(array[
    'Bronzerbeard'::text,
    'Project Epoch - Kezan'::text,
    'Project Epoch - Gurubashi'::text
  ]) as server_name
),
src as (
  select
    'Servidores Privados'::text as game,
    ps.server_name::text as server,
    p.amount::int as amount,
    round((p.amount::numeric / 100.0) * 2.50::numeric, 2) as price
  from private_servers ps
  cross join generate_series(100, 1000, 100) p(amount)
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
where game = 'Servidores Privados'
  and server in ('Bronzerbeard', 'Project Epoch - Kezan', 'Project Epoch - Gurubashi')
order by server, amount;
