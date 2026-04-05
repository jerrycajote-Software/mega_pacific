# 🏠 3D Roofing Visualization and Smart Ordering System

## 📌 Project Overview

This project is a **web-based and mobile-ready system** that allows customers to visualize, design, and estimate roofing materials using a **3D house model** before purchasing.

The system integrates **3D visualization, smart material calculation, and inventory management** to improve decision-making for customers and streamline operations for administrators.

📍 **Development Approach:**

* Start with **Web (Admin + Customer)**
* Mobile version will be implemented later

---

## 🎯 Objectives

* Provide interactive **3D roofing design visualization**
* Automate **material estimation and cost calculation**
* Develop an **inventory and product management system**
* Enable **smart ordering workflow**

---

# 🏗️ System Architecture

### Frontend

* Flutter (Web first, Mobile later)

### Backend

* Node.js + Express

### Database

* PostgreSQL

### 3D Visualization

* Three.js (Rendering)
* Blender (3D modeling)

---

# 🚀 Features

## 👤 Customer Side

* Browse roofing materials
* Select house model *(design feature accessed via separate button)*
* 3D roof visualization
* X-ray roof layer view
* Material selection
* Automatic cost calculation
* Order submission

---

## 🧑‍💼 Admin Side

* Inventory management
* Product management
* Order monitoring *(to be implemented later)*
* Sales tracking *(to be implemented later)*

---

# 🥽 3D Roofing Design Feature (Core Feature)

## 🔧 Workflow

1. User selects a **house model** (default templates provided).
2. System loads the **3D model**.
3. User selects a product (e.g., Hermosa Tile).
4. The system:

   * Automatically applies the selected material to the roof
   * Adjusts the size and fit based on roof dimensions
5. User can:

   * Rotate (360° view)
   * Zoom in/out
   * Enable X-ray view (see roof layers)

---

## 🏠 House Model System

* Multiple predefined house models:

  * Small residential
  * Medium residential
  * Warehouse type

* Users **cannot upload custom models** (limited to system models).

---

## 🧱 Materials Supported

### Roofing

* Pico Rib
* Hermosa Tile
* Agua Corr
* Twin Rib
* S-Rib
* 6 Ribs

### Structural

* C Purlins

### Ceiling

* Spandrel 4” / 6”

### Decking

* Webdeck
* Flatdeck

### Accessories

* Gutter
* Flashing
* Ridge Roll
* Ridge Cap
* Wall Capping

---

# ⚙️ System Modules

## 🖥️ Frontend (Flutter Web)

### Admin Module (Start Here)

* Dashboard
* Product Management (CRUD)
* Inventory Management

### Customer Module

* Product Listing
* 3D Designer Page
* Order Page

---

## ⚙️ Backend (Node.js + Express)

### API Endpoints

#### Products

* GET /products
* POST /products
* PUT /products/:id
* DELETE /products/:id

#### Orders (Phase 2)

* POST /orders
* GET /orders

#### Calculation

* POST /calculate-material

---

### Backend Functions

* Product CRUD operations
* Inventory tracking
* Material calculation logic
* Order processing

---

## 🗄️ Database (PostgreSQL)

### Tables

#### products

* id
* name
* category
* price
* stock

#### orders *(Phase 2)*

* id
* total_price
* created_at

#### order_items *(Phase 2)*

* id
* order_id
* product_id
* quantity

---

# 📂 Project Structure

roofing-system/
│
├── frontend/        # Flutter Web App
├── backend/         # Node.js API
├── 3d-module/       # Three.js 3D System
│
└── database/        # SQL files

---

# 🛠️ Installation Guide

## 1. Clone Repository

git clone https://github.com/your-repo/roofing-system.git

---

## 2. Setup Backend

cd backend
npm install
node server.js

---

## 3. Setup Database

* Install PostgreSQL
* Create database: roofing_db
* Run SQL schema

---

## 4. Setup Frontend

cd frontend
flutter pub get
flutter run -d chrome

---

## 5. Run 3D Module

Open:
3d-module/index.html

---

# 🗺️ Development Roadmap

## Phase 1 (Week 1)

* Setup environment
* Create project structure
* Initialize backend and database

---

## Phase 2 (Week 2)

* Implement Product API
* Build Admin UI (Product + Inventory)

---

## Phase 3 (Week 3)

* Create 3D house model (Blender)
* Setup Three.js viewer

---

## Phase 4 (Week 4)

* Integrate 3D viewer into Flutter (WebView)
* Add material switching

---

## Phase 5 (Week 5)

* Implement material calculation logic
* Display cost estimation

---

## Phase 6 (Week 6)

* Add order submission system
* Build customer UI

---

## Phase 7 (Week 7)

* Add Order Monitoring (Admin)
* Add Sales Tracking

---

## Phase 8 (Week 8)

* Testing and debugging
* UI improvements

---

## Phase 9 (Week 9)

* Deployment (Frontend + Backend)

---

# 🌐 Deployment

Frontend:

* Firebase Hosting / Netlify

Backend:

* Render / Railway

Database:

* Supabase / Neon

---

# 📊 System Requirements

* Internet connection
* Modern browser (Chrome recommended)
* Node.js installed
* Flutter SDK installed

---

# 🔮 Future Enhancements

* AR visualization
* AI roof measurement
* Contractor integration system

---

# 👨‍💻 Developers

* Your Name (Full Stack Developer)

---
