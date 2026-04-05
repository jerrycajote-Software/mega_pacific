const express = require('express');
const router  = express.Router();
const pool    = require('../db');

// ─────────────────────────────────────────
// GET /products — Fetch all products
// ─────────────────────────────────────────
router.get('/', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM products ORDER BY id ASC'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('GET /products error:', err.message);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// ─────────────────────────────────────────
// GET /products/:id — Fetch single product
// ─────────────────────────────────────────
router.get('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'SELECT * FROM products WHERE id = $1',
      [id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('GET /products/:id error:', err.message);
    res.status(500).json({ error: 'Failed to fetch product' });
  }
});

// ─────────────────────────────────────────
// POST /products — Create new product
// ─────────────────────────────────────────
router.post('/', async (req, res) => {
  const { name, category, price, stock } = req.body;

  // Validation
  if (!name || !category || price === undefined || stock === undefined) {
    return res.status(400).json({ error: 'All fields (name, category, price, stock) are required' });
  }
  if (isNaN(parseFloat(price)) || parseFloat(price) < 0) {
    return res.status(400).json({ error: 'Price must be a non-negative number' });
  }
  if (!Number.isInteger(Number(stock)) || Number(stock) < 0) {
    return res.status(400).json({ error: 'Stock must be a non-negative integer' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO products (name, category, price, stock) VALUES ($1, $2, $3, $4) RETURNING *',
      [name.trim(), category.trim(), parseFloat(price), parseInt(stock)]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('POST /products error:', err.message);
    res.status(500).json({ error: 'Failed to create product' });
  }
});

// ─────────────────────────────────────────
// PUT /products/:id — Update product
// ─────────────────────────────────────────
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { name, category, price, stock } = req.body;

  // Validation
  if (!name || !category || price === undefined || stock === undefined) {
    return res.status(400).json({ error: 'All fields (name, category, price, stock) are required' });
  }
  if (isNaN(parseFloat(price)) || parseFloat(price) < 0) {
    return res.status(400).json({ error: 'Price must be a non-negative number' });
  }
  if (!Number.isInteger(Number(stock)) || Number(stock) < 0) {
    return res.status(400).json({ error: 'Stock must be a non-negative integer' });
  }

  try {
    const result = await pool.query(
      `UPDATE products
       SET name = $1, category = $2, price = $3, stock = $4
       WHERE id = $5
       RETURNING *`,
      [name.trim(), category.trim(), parseFloat(price), parseInt(stock), id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('PUT /products/:id error:', err.message);
    res.status(500).json({ error: 'Failed to update product' });
  }
});

// ─────────────────────────────────────────
// PATCH /products/:id/stock — Adjust stock
// Body: { action: 'add'|'deduct', quantity, note? }
// ─────────────────────────────────────────
router.patch('/:id/stock', async (req, res) => {
  const { id } = req.params;
  const { action, quantity, note } = req.body;

  // Validation
  if (!action || !['add', 'deduct'].includes(action)) {
    return res.status(400).json({ error: 'action must be "add" or "deduct"' });
  }
  const qty = parseInt(quantity);
  if (isNaN(qty) || qty <= 0) {
    return res.status(400).json({ error: 'quantity must be a positive integer' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Fetch current stock
    const current = await client.query('SELECT * FROM products WHERE id = $1 FOR UPDATE', [id]);
    if (current.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Product not found' });
    }

    const currentStock = current.rows[0].stock;
    if (action === 'deduct' && qty > currentStock) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        error: `Cannot deduct ${qty} — only ${currentStock} in stock`,
      });
    }

    const newStock = action === 'add' ? currentStock + qty : currentStock - qty;

    // Update product stock
    const updated = await client.query(
      'UPDATE products SET stock = $1 WHERE id = $2 RETURNING *',
      [newStock, id]
    );

    // Record movement in stock_logs
    await client.query(
      'INSERT INTO stock_logs (product_id, action, quantity, note) VALUES ($1, $2, $3, $4)',
      [id, action, qty, note || null]
    );

    await client.query('COMMIT');
    res.json(updated.rows[0]);
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('PATCH /products/:id/stock error:', err.message);
    res.status(500).json({ error: 'Failed to adjust stock' });
  } finally {
    client.release();
  }
});

// ─────────────────────────────────────────
// DELETE /products/:id — Delete product
// ─────────────────────────────────────────
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'DELETE FROM products WHERE id = $1 RETURNING *',
      [id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json({ message: `Product "${result.rows[0].name}" deleted successfully` });
  } catch (err) {
    console.error('DELETE /products/:id error:', err.message);
    res.status(500).json({ error: 'Failed to delete product' });
  }
});

module.exports = router;
