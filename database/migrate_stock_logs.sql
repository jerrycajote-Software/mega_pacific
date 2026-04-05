-- ============================================================
-- Mega Pacific — Stock Logs Migration
-- Run this ONCE against roof_db to add inventory tracking
-- ============================================================

CREATE TABLE IF NOT EXISTS stock_logs (
  id          SERIAL PRIMARY KEY,
  product_id  INTEGER       NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  action      VARCHAR(10)   NOT NULL CHECK (action IN ('add', 'deduct')),
  quantity    INTEGER       NOT NULL CHECK (quantity > 0),
  note        VARCHAR(255),
  created_at  TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- Index for fast lookups by product
CREATE INDEX IF NOT EXISTS idx_stock_logs_product ON stock_logs(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_logs_created ON stock_logs(created_at DESC);
