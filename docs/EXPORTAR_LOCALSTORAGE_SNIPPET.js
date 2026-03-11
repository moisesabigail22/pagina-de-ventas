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
