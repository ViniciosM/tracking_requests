const jsonServer = require('json-server');
const jwt = require('jsonwebtoken');

const PORT = process.env.PORT || 3000;
const SECRET = process.env.JWT_SECRET || 'dev-secret-not-for-production';
const LATENCY_MS = parseInt(process.env.LATENCY_MS || '600', 10);
const FAIL_RATE = parseFloat(process.env.FAIL_RATE || '0');

const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();

server.use(middlewares);
server.use(jsonServer.bodyParser);


server.use((req, res, next) => setTimeout(next, LATENCY_MS));


server.use((req, res, next) => {
  const isWrite = ['POST', 'PATCH', 'PUT', 'DELETE'].includes(req.method);
  const forced = req.headers['x-mock-fail'] === 'true';
  if (isWrite && req.path !== '/login' && (forced || Math.random() < FAIL_RATE)) {
    return res.status(500).json({ message: 'Simulated server failure' });
  }
  next();
});

server.post('/login', (req, res) => {
  const { email, password } = req.body || {};
  const user = router.db.get('users').find({ email, password }).value();
  if (!user) {
    return res.status(401).json({ message: 'E-mail ou senha inválidos.' });
  }
  const token = jwt.sign({ sub: user.id, email: user.email }, SECRET, {
    expiresIn: '7d',
  });
  return res.json({
    token,
    user: { id: String(user.id), name: user.name, email: user.email },
  });
});

server.use((req, res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ message: 'Token ausente.' });
  try {
    jwt.verify(token, SECRET);
    return next();
  } catch (_) {
    return res.status(401).json({ message: 'Token inválido.' });
  }
});

server.use(router);
server.listen(PORT, () => {
  console.log(`Mock API running on http://localhost:${PORT}`);
  console.log(`Latency: ${LATENCY_MS}ms | Write fail rate: ${FAIL_RATE}`);
});
