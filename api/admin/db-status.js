const { query } = require('../_lib/db');
const { verifyAdminToken } = require('../_lib/auth');

module.exports = async function handler(req, res) {
  const auth = verifyAdminToken(req);
  if (!auth.ok) {
    return res.status(401).json({ error: auth.error });
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const conn = process.env.DATABASE_URL || '';
    let host = null;
    let port = null;
    let databaseFromUrl = null;
    try {
      const parsed = new URL(conn);
      host = parsed.hostname || null;
      port = parsed.port || null;
      databaseFromUrl = (parsed.pathname || '').replace(/^\//, '') || null;
    } catch {}

    const [dbInfo, counts] = await Promise.all([
      query('select current_database() as database, current_user as user_name'),
      query(`
        select
          (select count(*) from gold) as gold,
          (select count(*) from services) as services,
          (select count(*) from gold_categories) as gold_categories,
          (select count(*) from game_servers) as game_servers,
          (select count(*) from accounts) as accounts,
          (select count(*) from customer_references) as customer_references,
          (select count(*) from settings) as settings
      `)
    ]);

    return res.status(200).json({
      ok: true,
      connection: {
        host,
        port,
        database_from_url: databaseFromUrl
      },
      database: dbInfo.rows[0]?.database || null,
      user: dbInfo.rows[0]?.user_name || null,
      counts: counts.rows[0] || {}
    });
  } catch (error) {
    return res.status(500).json({ error: 'Database status check failed', detail: error.message });
  }
};
