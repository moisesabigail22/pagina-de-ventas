-- Limpieza: elimina todo lo creado para "WoW TBC" en catálogo de oro.
-- Úsalo en Supabase SQL Editor si no quieres que aparezca WoW TBC
-- ni sus paquetes/servidores en el panel.

begin;

-- 1) Eliminar paquetes de oro para WoW TBC
delete from public.gold
where game = 'WoW TBC';

-- 2) Eliminar servidores de WoW TBC
delete from public.game_servers
where game = 'WoW TBC';

-- 3) Eliminar categoría de WoW TBC
delete from public.gold_categories
where game = 'WoW TBC'
   or name = 'WoW TBC';

commit;

-- Verificación rápida (debe devolver 0 en las tres filas)
select 'gold' as table_name, count(*) as total
from public.gold
where game = 'WoW TBC'
union all
select 'game_servers', count(*)
from public.game_servers
where game = 'WoW TBC'
union all
select 'gold_categories', count(*)
from public.gold_categories
where game = 'WoW TBC' or name = 'WoW TBC';
