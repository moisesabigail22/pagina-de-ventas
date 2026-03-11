const jwt = require('jsonwebtoken');

function readCredentials(req) {
  if (req.method === 'GET') {
    return {
      username: req.query && req.query.username,
      password: req.query && req.query.password
    };
  }

  return req.body || {};
}

module.exports = async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  if (req.method !== 'POST' && req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed', allowed_methods: ['GET', 'POST'] });
  }

  const { username, password } = readCredentials(req);
  const adminUser = process.env.ADMIN_USER || 'admin';
  const adminPass = process.env.ADMIN_PASSWORD || 'admin123';
  const jwtSecret = process.env.ADMIN_JWT_SECRET || 'admin123';

  if (!username || !password) {
    return res.status(400).json({
      error: 'username and password are required',
      usage: {
        post: {
          url: '/api/admin/login',
          json: { username: 'admin', password: 'admin123' }
        },
        get: '/api/admin/login?username=admin&password=admin123'
      }
    });
  }

  if (username !== adminUser || password !== adminPass) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const token = jwt.sign({ role: 'admin', username: adminUser }, jwtSecret, {
    expiresIn: '12h'
  });

  return res.status(200).json({ token });
};
