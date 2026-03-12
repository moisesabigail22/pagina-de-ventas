-- Esquema/seed para catálogo de oro y servicios solicitado.
-- Compatible con tablas existentes: gold_categories, game_servers, gold, services.

begin;

-- 1) Categorías de juegos para oro
insert into public.gold_categories (game, server, description, image)
values
  ('WoW Turtle', null, 'Oro para Turtle WoW', 'https://i.imgur.com/ynvAS9B.png'),
  ('Servidores Privados', null, 'Oro para servidores privados de WoW', 'https://i.imgur.com/ynvAS9B.png'),
  ('WoW Oficial', null, 'Oro para servidores oficiales de WoW', 'https://i.imgur.com/ynvAS9B.png')
on conflict (game, server) do update
set description = excluded.description,
    image = excluded.image,
    updated_at = now();

-- 2) Servidores por juego
insert into public.game_servers (game, name)
values
  ('WoW Turtle', 'Ambershire'),
  ('WoW Turtle', 'Nordanaar'),
  ('WoW Turtle', 'Telabim'),
  ('Servidores Privados', 'Bronzebeard'),
  ('Servidores Privados', 'South Sea'),
  ('Servidores Privados', 'Warmane Onyxia'),
  ('Servidores Privados', 'Project Epoch - Kezan'),
  ('Servidores Privados', 'Project Epoch - Gurubashi'),
  ('WoW Oficial', 'Nightslayer A/H')
on conflict (game, name) do nothing;

-- 3) Paquetes de oro
insert into public.gold (game, server, amount, price, delivery, stock)
values
  ('WoW Turtle', 'Ambershire', 100, 3.00, '5-30 minutos', 'available'),
  ('WoW Turtle', 'Nordanaar', 100, 2.90, '5-30 minutos', 'available'),
  ('WoW Turtle', 'Telabim', 100, 4.50, '5-30 minutos', 'available'),

  ('Servidores Privados', 'Bronzebeard', 100, 3.50, '5-30 minutos', 'available'),
  ('Servidores Privados', 'South Sea', 100, 4.50, '5-30 minutos', 'available'),
  ('Servidores Privados', 'Warmane Onyxia', 1000, 2.00, '5-30 minutos', 'available'),
  ('Servidores Privados', 'Project Epoch - Kezan', 100, 4.00, '5-30 minutos', 'available'),
  ('Servidores Privados', 'Project Epoch - Gurubashi', 100, 3.00, '5-30 minutos', 'available')
on conflict (game, server, amount) do update
set price = excluded.price,
    delivery = excluded.delivery,
    stock = excluded.stock,
    updated_at = now();

-- 4) Servicios adicionales
insert into public.services (category, game, name, description, price)
values
  ('oro', 'WoW Oficial', 'Nightslayer A/H', 'Precio base publicado', 58.00),

  ('boosteo', 'WoW Privado', 'Boosteo cualquier clase', 'Boosteo completo en servidor privado', 280.00),
  ('boosteo', 'WoW Privado', 'PVP Rank Boosting por rango', 'Boosting por rango PVP', 15.00),

  ('profesiones', 'WoW', 'Herboristería / Minería', 'Subida de profesión', 30.00),
  ('profesiones', 'WoW', 'Sastrería', 'Subida de profesión', 40.00),
  ('profesiones', 'WoW', 'Cocina', 'Subida de profesión', 30.00),
  ('profesiones', 'WoW', 'Pesca', 'Subida de profesión', 40.00),
  ('profesiones', 'WoW', 'Peletería', 'Subida de profesión', 40.00),
  ('profesiones', 'WoW', 'Encantamiento', 'Subida de profesión', 40.00),
  ('profesiones', 'WoW', 'Herrería', 'Subida de profesión', 50.00),
  ('profesiones', 'WoW', 'Ingeniería', 'Subida de profesión', 55.00),
  ('profesiones', 'WoW', 'Alquimia', 'Subida de profesión', 40.00),
  ('profesiones', 'WoW', 'Inscription / Crasting', 'Subida de profesión', 50.00),
  ('profesiones', 'WoW', 'Desuello', 'Subida de profesión', 30.00)
on conflict (category, game, name) do update
set description = excluded.description,
    price = excluded.price,
    updated_at = now();

commit;
