const express = require('express');
const router  = express.Router();
const pool    = require('../db');
const bcrypt  = require('bcryptjs');
const jwt     = require('jsonwebtoken');

// Secret for JWT - in a real app, use an environment variable process.env.JWT_SECRET
const JWT_SECRET = process.env.JWT_SECRET || 'supersecret_mega_pacific_key';

// ─────────────────────────────────────────
// POST /auth/register — Register new user
// ─────────────────────────────────────────
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;

  // Validation
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Name, email, and password are required' });
  }

  try {
    // Check if user already exists
    const userCheck = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    // Hash password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Insert user into db
    const result = await pool.query(
      `INSERT INTO users (name, email, password, role) 
       VALUES ($1, $2, $3, 'customer') 
       RETURNING id, name, email, role, created_at`,
      [name.trim(), email.trim(), hashedPassword]
    );

    const newUser = result.rows[0];

    // Create JWT
    const token = jwt.sign(
      { id: newUser.id, role: newUser.role },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(201).json({
      message: 'Registration successful',
      token,
      user: newUser
    });
  } catch (err) {
    console.error('POST /auth/register error:', err.message);
    res.status(500).json({ error: 'Failed to register user' });
  }
});

// ─────────────────────────────────────────
// POST /auth/login — Login existing user
// ─────────────────────────────────────────
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    // Check user
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email.trim()]);
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];

    // Compare passwords
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Create JWT
    const token = jwt.sign(
      { id: user.id, role: user.role },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    // Remove password from response
    delete user.password;

    res.json({
      message: 'Login successful',
      token,
      user
    });
  } catch (err) {
    console.error('POST /auth/login error:', err.message);
    res.status(500).json({ error: 'Login failed' });
  }
});

module.exports = router;
