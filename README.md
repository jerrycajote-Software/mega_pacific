# 🏠 3D Roofing Visualization and Smart Ordering System

## 📌 Project Overview

This project is a **web-based and mobile-ready system** that allows customers to visualize, design, and estimate roofing materials using a **3D house model** before purchasing.

The system integrates **3D visualization, smart material calculation, and inventory management** to improve decision-making for customers and streamline operations for administrators.

📍 **Development Approach:**

- Start with **Web (Admin + Customer)**
- Mobile version will be implemented later

---

## 🎯 Objectives

- Provide interactive **3D roofing design visualization**
- Automate **material estimation and cost calculation**
- Develop an **inventory and product management system**
- Enable **smart ordering workflow**

---

# 🏗️ System Architecture

| Layer | Technology |
|---|---|
| **Frontend** | Flutter (Web first, Mobile later) |
| **Backend** | Node.js + Express |
| **Database** | PostgreSQL |
| **3D Rendering** | Three.js |
| **3D Modeling** | Blender |

---

# 🚀 Features

## 👤 Customer Side

- Browse roofing materials
- Select house model *(design feature accessed via separate button)*
- 3D roof visualization
- X-ray roof layer view
- Material selection
- Automatic cost calculation
- Order submission

---

## 🧑‍💼 Admin Side

- Inventory management
- Product management
- Order monitoring *(Phase 2)*
- Sales tracking *(Phase 2)*

---

# 🥽 3D Roofing Design Feature (Core Feature)

## 🔧 Workflow

1. User selects a **house model** (default templates provided).
2. System loads the **3D model**.
3. User selects a product (e.g., Hermosa Tile).
4. The system:
   - Automatically applies the selected material to the roof
   - Adjusts the size and fit based on roof dimensions
5. User can:
   - Rotate (360° view)
   - Zoom in/out
   - Enable X-ray view (see roof layers)

---

## 🏠 House Model System

Multiple predefined house models:

- Small residential
- Medium residential
- Warehouse type

> **Note:** Users **cannot upload custom models** — limited to system-provided templates.

---

## 🧱 Materials Supported

### Roofing
- Pico Rib
- Hermosa Tile
- Agua Corr
- Twin Rib
- S-Rib
- 6 Ribs

### Structural
- C Purlins

### Ceiling
- Spandrel 4" / 6"

### Decking
- Webdeck
- Flatdeck

### Accessories
- Gutter
- Flashing
- Ridge Roll
- Ridge Cap
- Wall Capping

---

# ⚙️ System Modules

## 🖥️ Frontend (Flutter Web)

### Admin Module *(Start Here)*
- Dashboard
- Product Management (CRUD)
- Inventory Management

### Customer Module
- Product Listing
- 3D Designer Page
- Order Page

---

## ⚙️ Backend (Node.js + Express)

### API Endpoints

#### Products
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/products` | Fetch all products |
| `POST` | `/products` | Create a new product |
| `PUT` | `/products/:id` | Update a product |
| `DELETE` | `/products/:id` | Delete a product |

#### Orders *(Phase 2)*
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/orders` | Submit an order |
| `GET` | `/orders` | Fetch all orders |

#### Calculation
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/calculate-material` | Compute material quantities and cost |

### Backend Functions
- Product CRUD operations
- Inventory tracking
- Material calculation logic
- Order processing

---

## 🗄️ Database (PostgreSQL)

### Tables

#### `products`
| Column | Type |
|---|---|
| id | SERIAL PRIMARY KEY |
| name | VARCHAR |
| category | VARCHAR |
| price | DECIMAL |
| stock | INTEGER |

#### `orders` *(Phase 2)*
| Column | Type |
|---|---|
| id | SERIAL PRIMARY KEY |
| total_price | DECIMAL |
| created_at | TIMESTAMP |

#### `order_items` *(Phase 2)*
| Column | Type |
|---|---|
| id | SERIAL PRIMARY KEY |
| order_id | INTEGER (FK) |
| product_id | INTEGER (FK) |
| quantity | INTEGER |

---

# 📂 Project Structure

```
mega_pacific/
│
├── frontend/        # Flutter Web App
├── backend/         # Node.js API
├── 3d-module/       # Three.js 3D System
│
└── database/        # SQL schema files
```

---

# 🛠️ Installation Guide

## 1. Clone the Repository

```bash
git clone <repository-url>
cd mega_pacific
```

---

## 2. Setup Backend

```bash
cd backend       # ✅ Done
npm install      # ✅ Done
node server.js
```

---

## 3. Setup Database

- Install PostgreSQL ✅ Done
- Create database: `roof_db` ✅ Done
- Run SQL schema:

```bash
psql -U postgres -d roof_db -f database/schema.sql
```

---

## 4. Setup Frontend ✅ Done

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

---

## 5. Run 3D Module

> The `3d-module/` folder is already created.

Simply open the file in a browser:

```
3d-module/index.html
```

---

# 🗺️ Development Roadmap

| Phase | Week | Milestone |
|---|---|---|
| **Phase 1** | Week 1 | Setup environment, create project structure, initialize backend and database |
| **Phase 2** | Week 2 | Implement Product API, build Admin UI (Product + Inventory) |
| **Phase 3** | Week 3 | Create 3D house model (Blender), setup Three.js viewer |
| **Phase 4** | Week 4 | Integrate 3D viewer into Flutter (WebView), add material switching |
| **Phase 5** | Week 5 | Implement material calculation logic, display cost estimation |
| **Phase 6** | Week 6 | Add order submission system, build customer UI |
| **Phase 7** | Week 7 | Add Order Monitoring (Admin), add Sales Tracking |
| **Phase 8** | Week 8 | Testing, debugging, and UI improvements |

---

> 📝 *This README is a mock-up plan and will be updated as development progresses.*
