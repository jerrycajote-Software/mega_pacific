const express = require('express');
const router  = express.Router();
const pool    = require('../db');

// ─────────────────────────────────────────
// GET /reviews/product/:id — Get reviews for a product
// ─────────────────────────────────────────
router.get('/product/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT r.id, r.rating, r.comment, r.created_at, u.name as user_name 
       FROM reviews r
       JOIN users u ON r.user_id = u.id
       WHERE r.product_id = $1
       ORDER BY r.created_at DESC`,
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('GET /reviews/product/:id error:', err.message);
    res.status(500).json({ error: 'Failed to fetch reviews' });
  }
});

// ─────────────────────────────────────────
// POST /reviews — Add a new review
// ─────────────────────────────────────────
// Optionally, this could use a JWT auth middleware to enforce user login.
router.post('/', async (req, res) => {
  const { user_id, product_id, rating, comment } = req.body;

  if (!user_id || !product_id || rating === undefined) {
    return res.status(400).json({ error: 'user_id, product_id, and rating are required' });
  }

  if (rating < 1 || rating > 5) {
    return res.status(400).json({ error: 'rating must be between 1 and 5' });
  }

  try {
    // Check if user already reviewed this product? (Optional policy, omitting for simplicity)

    const result = await pool.query(
      `INSERT INTO reviews (user_id, product_id, rating, comment)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [user_id, product_id, rating, comment || null]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('POST /reviews error:', err.message);
    res.status(500).json({ error: 'Failed to submit review' });
  }
});

module.exports = router;
