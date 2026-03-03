# Supabase SIN backend (solo tu página)

Perfecto: lo dejamos **sin backend**.

## Qué significa “sin backend”
- Tu web se conecta directo a Supabase con:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- **No necesitas** API propia ni servidor adicional.

## Lo que ya te deja `supabase/setup.sql`
1. Base creada (accounts, gold, settings, references, etc.).
2. Lectura pública para que cualquier visitante vea paquetes y datos.
3. `admin_users` protegida (no visible para público).

## Paso 1: ejecutar SQL
En Supabase > SQL Editor ejecuta completo:
- `supabase/setup.sql`

## Paso 2: validar que quedó bien
```sql
select count(*) as cuentas from public.accounts;
select count(*) as paquetes_oro from public.gold;
select count(*) as referencias from public.references;
select * from public.settings limit 1;
```

## Paso 3: variables en Vercel (solo frontend)
Si no vas a usar backend, solo necesitas en frontend:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

> `SUPABASE_SERVICE_ROLE_KEY` NO se usa en frontend.

## Importante para que no quede “pelada”
Ahora mismo tu `index.html` usa `localStorage` como fuente principal.
Para que se vea global para todos, hay que cambiar la carga de datos a Supabase.

## Modo sin backend recomendado
- Lectura global: desde Supabase (público).
- Cambios de datos: por Table Editor de Supabase o luego con login real (Supabase Auth) para admin.

Así evitas montar backend y sigues teniendo datos globales para toda la web.
