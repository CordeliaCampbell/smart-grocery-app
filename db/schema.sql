-- Smart Grocery App — MySQL Schema
-- Run: mysql -u root -p < db/schema.sql

CREATE DATABASE IF NOT EXISTS smart_grocery
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE smart_grocery;

-- ─────────────────────────────────────────
-- Users
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(255)        NOT NULL,
  email      VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────
-- Categories
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  name                VARCHAR(100) NOT NULL UNIQUE,
  default_runout_days INT          NOT NULL DEFAULT 14,
  icon                VARCHAR(50)
);

-- ─────────────────────────────────────────
-- Items
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS items (
  id                   INT AUTO_INCREMENT PRIMARY KEY,
  user_id              INT,
  category_id          INT,
  name                 VARCHAR(255) NOT NULL,
  quantity             INT          NOT NULL DEFAULT 1,
  unit                 VARCHAR(50)  NOT NULL DEFAULT 'unit',
  date_added           DATE         NOT NULL DEFAULT (CURRENT_DATE),
  predicted_runout_date DATE,
  reminder_enabled     BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at           TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)     REFERENCES users(id)      ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- ─────────────────────────────────────────
-- Lists
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lists (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  user_id    INT,
  name       VARCHAR(255) NOT NULL,
  list_type  VARCHAR(100) NOT NULL DEFAULT 'custom',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
-- List Items
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS list_items (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  list_id    INT          NOT NULL,
  item_name  VARCHAR(255) NOT NULL,
  quantity   INT          NOT NULL DEFAULT 1,
  unit       VARCHAR(50)  NOT NULL DEFAULT 'unit',
  checked    BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (list_id) REFERENCES lists(id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
-- Reminders
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reminders (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  item_id        INT  NOT NULL,
  scheduled_date DATE NOT NULL,
  sent           BOOLEAN NOT NULL DEFAULT FALSE,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
-- Uploaded Images
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS uploaded_images (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  user_id         INT,
  file_path       VARCHAR(500) NOT NULL,
  vision_response JSON,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ─────────────────────────────────────────
-- Seed default categories
-- ─────────────────────────────────────────
INSERT IGNORE INTO categories (name, default_runout_days, icon) VALUES
  ('Produce',        5,  '🥦'),
  ('Dairy',          7,  '🥛'),
  ('Eggs',           12, '🥚'),
  ('Frozen',         30, '🧊'),
  ('Snacks',         14, '🍿'),
  ('Beverages',      14, '🧃'),
  ('Cleaning',       28, '🧹'),
  ('Laundry',        28, '🧺'),
  ('Paper Products', 21, '🧻'),
  ('Skincare',       45, '🧴'),
  ('Haircare',       45, '💇'),
  ('Medicine',       60, '💊'),
  ('Pet Food',       21, '🐾'),
  ('Pantry',         30, '🥫'),
  ('Other',          14, '📦');
