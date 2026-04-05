-- ============================================================
-- Mega Pacific Roofing System
-- Database Schema
-- ============================================================

-- Drop table if it already exists (for clean re-run)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;

-- ============================================================
-- PRODUCTS TABLE
-- ============================================================
CREATE TABLE products (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(255)    NOT NULL,
  category    VARCHAR(100)    NOT NULL,
  price       DECIMAL(10, 2)  NOT NULL DEFAULT 0.00,
  stock       INTEGER         NOT NULL DEFAULT 0,
  created_at  TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ORDERS TABLE (Phase 2)
-- ============================================================
CREATE TABLE orders (
  id          SERIAL PRIMARY KEY,
  total_price DECIMAL(10, 2)  NOT NULL DEFAULT 0.00,
  created_at  TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ORDER ITEMS TABLE (Phase 2)
-- ============================================================
CREATE TABLE order_items (
  id          SERIAL PRIMARY KEY,
  order_id    INTEGER         NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id  INTEGER         NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity    INTEGER         NOT NULL DEFAULT 1
);

-- ============================================================
-- SAMPLE DATA (optional — remove if not needed)
-- ============================================================
INSERT INTO products (name, category, price, stock) VALUES
  ('Pico Rib',       'Roofing',     450.00,  200),
  ('Hermosa Tile',   'Roofing',     620.00,  150),
  ('Agua Corr',      'Roofing',     390.00,  180),
  ('Twin Rib',       'Roofing',     480.00,  120),
  ('S-Rib',          'Roofing',     410.00,   80),
  ('6 Ribs',         'Roofing',     500.00,   60),
  ('C Purlins',      'Structural',  750.00,  100),
  ('Spandrel 4"',    'Ceiling',     310.00,  200),
  ('Spandrel 6"',    'Ceiling',     360.00,  150),
  ('Webdeck',        'Decking',     890.00,   40),
  ('Flatdeck',       'Decking',     820.00,   35),
  ('Gutter',         'Accessories', 280.00,   90),
  ('Flashing',       'Accessories', 195.00,  110),
  ('Ridge Roll',     'Accessories', 240.00,   70),
  ('Ridge Cap',      'Accessories', 260.00,   55),
  ('Wall Capping',   'Accessories', 215.00,   45);
