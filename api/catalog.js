const TABLES = ['accounts', 'gold', 'gold_categories', 'game_servers', 'references'];

function getEnv(name) {
  return process.env[name] || '';
}

async function queryTable({ supabaseUrl, apiKey, table }) {
  const url = `${supabaseUrl}/rest/v1/${table}?select=*&order=id.asc`;
  const response = await fetch(url, {
    headers: {
      apikey: apiKey,
      Authorization: `Bearer ${apiKey}`,
      Accept: 'application/json'
    }
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Error leyendo ${table}: ${response.status} ${errorBody}`);
  }

  return response.json();
}

async function querySettings({ supabaseUrl, apiKey }) {
  const url = `${supabaseUrl}/rest/v1/settings?select=key,value`;
  const response = await fetch(url, {
    headers: {
      apikey: apiKey,
      Authorization: `Bearer ${apiKey}`,
      Accept: 'application/json'
    }
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Error leyendo settings: ${response.status} ${errorBody}`);
  }

  const rows = await response.json();
  return rows.reduce((acc, row) => {
    if (row?.key) acc[row.key] = row.value;
    return acc;
  }, {});
}

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const supabaseUrl = getEnv(sb_publishable_d8czXDE3zG8BiVgah6NilA_MuHAyp25);
  const apiKey = getEnv(sb_secret__nzzXtrNNV2HwzUo4HB8cA_7H3vYboS) || getEnv('SUPABASE_SERVICE_ROLE_KEY');

  if (!supabaseUrl || !apiKey) {
    return res.status(500).json({
      error: 'Faltan variables de entorno SUPABASE_URL y SUPABASE_ANON_KEY (o SUPABASE_SERVICE_ROLE_KEY).'
    });
  }

  try {
    const tablePromises = TABLES.map((table) => queryTable({ supabaseUrl, apiKey, table }));
    const [accounts, gold, goldCategories, gameServers, references, settings] = await Promise.all([
      ...tablePromises,
      querySettings({ supabaseUrl, apiKey })
    ]);

    res.setHeader('Cache-Control', 's-maxage=30, stale-while-revalidate=300');

    return res.status(200).json({
      accounts,
      gold,
      gold_categories: goldCategories,
      game_servers: gameServers,
      references,
      settings,
      categories: Array.from(new Set(accounts.map((item) => item.category).filter(Boolean))).sort()
    });
  } catch (error) {
    return res.status(500).json({
      error: 'No se pudo obtener el catálogo desde Supabase.',
      details: error instanceof Error ? error.message : String(error)
    });
  }
}
