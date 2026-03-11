# Recuperar datos cuando Supabase está vacío pero la web sí muestra productos

Si la web muestra datos pero en Supabase no ves nada, normalmente esos datos están en `localStorage` del navegador.

## 1) Exportar datos del navegador que SÍ los muestra
Abre la web en el navegador donde ves los datos (PC/telefono) y abre consola del navegador.

Pega este script y presiona Enter (**solo el código**, no la palabra `js`):

```javascript
(() => {
  const keys = [
    'epicgoldshop_settings',
    'epicgoldshop_gold_categories',
    'epicgoldshop_game_servers',
    'epicgoldshop_gold',
    'epicgoldshop_accounts',
    'epicgoldshop_references',
    'epicgoldshop_categories'
  ];

  const dump = {};
  for (const k of keys) dump[k] = localStorage.getItem(k);

  const blob = new Blob([JSON.stringify(dump, null, 2)], { type: 'application/json' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'epicgoldshop-localstorage-backup.json';
  a.click();
  URL.revokeObjectURL(a.href);

  console.log('Backup descargado: epicgoldshop-localstorage-backup.json');
})();
```

Si te sale `Uncaught ReferenceError: js is not defined`, significa que pegaste la palabra `js` en consola.
Solo pega el contenido del script, desde `(() => {` hasta `})();`.

Alternativa: abre `docs/EXPORTAR_LOCALSTORAGE_SNIPPET.js` y copia ese archivo completo en la consola.

## 2) Volver a llenar Supabase rápido
En Supabase SQL Editor ejecuta en este orden:
1. `supabase/schema.sql`
2. `supabase/seed_catalog.sql`
3. `supabase/diagnostico_catalog.sql`

## 3) Si quieres recuperar tus datos exactos del navegador
Pásame el archivo `epicgoldshop-localstorage-backup.json` y te lo convierto a SQL listo para pegar en Supabase.

## 4) Evitar que vuelva a pasar
- Confirma en Vercel que `SUPABASE_URL` y `SUPABASE_ANON_KEY` apuntan al proyecto correcto.
- Trabaja en incógnito al validar para no confundir datos locales con datos DB.
