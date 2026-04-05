-- ============================================================
-- Mega Pacific Routing System
-- Migration: Customer Features (Auth & Reviews)
-- ============================================================

-- 1. Create Users Table
CREATE TABLE IF NOT EXISTS users (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(255)    NOT NULL,
  email       VARCHAR(255)    NOT NULL UNIQUE,
  password    VARCHAR(255)    NOT NULL,
  role        VARCHAR(50)     NOT NULL DEFAULT 'customer',
  created_at  TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- Insert Default Admin User (Password is: admin123)
-- Using bcrypt hash for 'admin123': $2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGGa.g/C
INSERT INTO users (name, email, password, role) 
VALUES ('System Admin', 'admin@megapacific.com', '$2b$10$K4rB9/P9k6J/7y/QO4wz/.xR0w/b7G2S5tG6XU17gT6w3yM1l/dti', 'admin')
ON CONFLICT (email) DO NOTHING;

-- 2. Alter Products Table to add Image URL support
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS image_url VARCHAR(500) NULL;

-- 3. Create Reviews Table
CREATE TABLE IF NOT EXISTS reviews (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id  INTEGER         NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  rating      INTEGER         NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment     TEXT            NULL,
  created_at  TIMESTAMP       NOT NULL DEFAULT NOW()
);
