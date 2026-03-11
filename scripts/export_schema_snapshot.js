#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

async function main() {
  if (!process.env.DATABASE_URL) {
    throw new Error('Missing DATABASE_URL');
  }

  const outputArg = process.argv[2] || 'data/sql/schema_snapshot.sql';
  const outputPath = path.resolve(process.cwd(), outputArg);
  const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });

  const client = await pool.connect();
  try {
    const dbMeta = await client.query(
      `select current_database() as database, current_user as user_name, now() as exported_at`
    );

    const tables = await client.query(
      `select table_name
       from information_schema.tables
       where table_schema = 'public' and table_type='BASE TABLE'
       order by table_name`
    );

    let sql = '';
    sql += '-- Snapshot básico de esquema (public)\n';
    sql += `-- database: ${dbMeta.rows[0].database}\n`;
    sql += `-- user: ${dbMeta.rows[0].user_name}\n`;
    sql += `-- exported_at: ${dbMeta.rows[0].exported_at}\n\n`;

    for (const t of tables.rows) {
      const table = t.table_name;
      const columns = await client.query(
        `select
           column_name,
           data_type,
           udt_name,
           is_nullable,
           column_default,
           character_maximum_length,
           numeric_precision,
           numeric_scale
         from information_schema.columns
         where table_schema='public' and table_name=$1
         order by ordinal_position`,
        [table]
      );

      sql += `-- Table: public.${table}\n`;
      sql += `create table if not exists public.${table} (\n`;

      const lines = columns.rows.map((c) => {
        let type = c.data_type;
        if (c.data_type === 'USER-DEFINED') type = c.udt_name;
        if (c.data_type === 'character varying' && c.character_maximum_length) {
          type = `varchar(${c.character_maximum_length})`;
        }
        if (c.data_type === 'numeric' && c.numeric_precision) {
          type = `numeric(${c.numeric_precision}${c.numeric_scale !== null ? `,${c.numeric_scale}` : ''})`;
        }
        const nullable = c.is_nullable === 'NO' ? ' not null' : '';
        const def = c.column_default ? ` default ${c.column_default}` : '';
        return `  ${c.column_name} ${type}${def}${nullable}`;
      });

      sql += `${lines.join(',\n')}\n);\n\n`;
    }

    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, sql, 'utf8');
    console.log(`Schema snapshot written to ${outputPath}`);
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
