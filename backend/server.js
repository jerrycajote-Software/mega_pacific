const express    = require('express');
const cors       = require('cors');
const bodyParser = require('body-parser');

const productsRouter = require('./routes/products');

const app  = express();
const PORT = 3000;

// ── Middleware ───────────────────────────
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// ── Routes ───────────────────────────────
app.get('/', (req, res) => {
  res.json({ message: '🏠 Mega Pacific API is running', version: '1.0.0' });
});

app.use('/products', productsRouter);

// ── 404 Handler ──────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: `Route ${req.method} ${req.url} not found` });
});

// ── Error Handler ────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err.message);
  res.status(500).json({ error: 'Internal server error' });
});

// ── Start Server ─────────────────────────
app.listen(PORT, () => {
  console.log('');
  console.log('🚀 Mega Pacific API Server');
  console.log(`   Running at: http://localhost:${PORT}`);
  console.log(`   Products:   http://localhost:${PORT}/products`);
  console.log('');
});
