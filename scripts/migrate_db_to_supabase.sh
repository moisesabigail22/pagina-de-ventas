#!/usr/bin/env bash
set -euo pipefail

if ! command -v pg_dump >/dev/null 2>&1; then
  echo "❌ pg_dump no está instalado"
  exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "❌ psql no está instalado"
  exit 1
fi

if [ -z "${SRC_DATABASE_URL:-}" ] || [ -z "${DEST_DATABASE_URL:-}" ]; then
  echo "Uso:"
  echo "  export SRC_DATABASE_URL='postgresql://...origen...'"
  echo "  export DEST_DATABASE_URL='postgresql://...supabase-destino...'"
  echo "  ./scripts/migrate_db_to_supabase.sh"
  exit 1
fi

echo "1) Exportando schema+data desde origen..."
pg_dump "$SRC_DATABASE_URL" --no-owner --no-privileges --format=plain > /tmp/catalog_migration.sql

echo "2) Importando dump a destino Supabase..."
psql "$DEST_DATABASE_URL" -v ON_ERROR_STOP=1 -f /tmp/catalog_migration.sql

echo "✅ Migración completada"
