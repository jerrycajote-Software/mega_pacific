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
