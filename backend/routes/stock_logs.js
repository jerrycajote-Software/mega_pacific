const express = require('express');
const router  = express.Router();
const pool    = require('../db');

// ─────────────────────────────────────────────────────
// GET /stock-logs — All stock movements (latest first)
// Optional query param: ?product_id=5
// ─────────────────────────────────────────────────────
router.get('/', async (req, res) => {
  const { product_id } = req.query;
  try {
    let query = `
      SELECT
        sl.id,
        sl.product_id,
        p.name  AS product_name,
        p.category,
        sl.action,
        sl.quantity,
        sl.note,
        sl.created_at
      FROM stock_logs sl
      JOIN products p ON p.id = sl.product_id
    `;
    const params = [];
    if (product_id) {
      query += ' WHERE sl.product_id = $1';
      params.push(parseInt(product_id));
    }
    query += ' ORDER BY sl.created_at DESC LIMIT 100';

    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error('GET /stock-logs error:', err.message);
    res.status(500).json({ error: 'Failed to fetch stock logs' });
  }
});

// ─────────────────────────────────────────────────────
// GET /stock-logs/:product_id — Logs for one product
// ─────────────────────────────────────────────────────
router.get('/:product_id', async (req, res) => {
  const { product_id } = req.params;
  try {
    const result = await pool.query(
      `SELECT sl.*, p.name AS product_name, p.category
       FROM stock_logs sl
       JOIN products p ON p.id = sl.product_id
       WHERE sl.product_id = $1
       ORDER BY sl.created_at DESC
       LIMIT 50`,
      [parseInt(product_id)]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('GET /stock-logs/:id error:', err.message);
    res.status(500).json({ error: 'Failed to fetch stock logs for product' });
  }
});

module.exports = router;
