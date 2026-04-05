
# 🏗️ Admin Side Implementation Plan
## Backend API + Flutter Admin UI

Build the Node.js product API and the Flutter Admin UI with Dashboard, Product List, and Product Form screens.

---

## Proposed Changes

### ─────────────────────────────────────────
### 🗄️ Database

#### [NEW] `database/schema.sql`
- Creates the `products` table with columns: `id`, `name`, `category`, `price`, `stock`, `created_at`
- Run once against `roof_db` to initialize the schema

---

### ─────────────────────────────────────────
### ⚙️ Backend (Node.js + Express)

All new files inside `backend/`

#### [NEW] `backend/db.js`
- PostgreSQL connection pool using `pg`
- Reads host, user, password, database config
- Exported as a shared `pool` instance

#### [NEW] `backend/routes/products.js`
- Express Router with all 4 CRUD endpoints:
  - `GET /products` — fetch all products, ordered by id
  - `POST /products` — insert new product, validates required fields
  - `PUT /products/:id` — update product by id
  - `DELETE /products/:id` — delete product by id
- Returns JSON responses with proper HTTP status codes

#### [NEW] `backend/server.js`
- Express app setup
- CORS enabled (so Flutter Web can call the API)
- Body-parser JSON middleware
- Mounts `/products` router
- Listens on port `3000`

---

### ─────────────────────────────────────────
### 🖥️ Frontend (Flutter Web)

#### [MODIFY] `frontend/pubspec.yaml`
- Add `http: ^1.2.1` dependency for HTTP calls to the backend

#### [MODIFY] `frontend/lib/main.dart`
- Replace boilerplate counter app
- Set up `MaterialApp` with routes pointing to `AdminDashboard`

#### [NEW] `frontend/lib/services/api_service.dart`
- Centralized API service class
- Base URL set to `http://localhost:3000`
- Methods: `getProducts()`, `createProduct()`, `updateProduct()`, `deleteProduct()`

#### [NEW] `frontend/lib/models/product.dart`
- `Product` data model with: `id`, `name`, `category`, `price`, `stock`
- `fromJson()` and `toJson()` factory methods

#### [NEW] `frontend/lib/screens/admin/admin_dashboard.dart`
- Sidebar layout with navigation items: Dashboard, Products, Inventory *(placeholder)*
- **Dashboard tab**: stat cards showing:
  - Total Products
  - Total Stock Units
  - Total Inventory Value (price × stock)
  - Out of Stock count
- Stats fetched from the backend

#### [NEW] `frontend/lib/screens/admin/product_list.dart`
- Full product data table (name, category, price, stock)
- Edit and Delete action buttons per row
- Floating action button to add a new product
- Delete confirmation dialog
- Navigates to `ProductForm` for add/edit

#### [NEW] `frontend/lib/screens/admin/product_form.dart`
- Form with fields: Name, Category (dropdown), Price, Stock
- Works in both **Add** and **Edit** mode
- Form validation (required fields, numeric checks)
- Calls `api_service.dart` on save, pops back to product list on success

---

## Verification Plan

### Automated / Manual Steps
1. Run `node backend/server.js` — confirm it starts on port 3000
2. Test API with browser or Postman:
   - `GET http://localhost:3000/products` → returns `[]` initially
   - `POST` a product → verify it appears in DB and `GET`
   - `PUT` that product → verify update
   - `DELETE` it → verify removal
3. Run Flutter: `flutter run -d chrome`
   - Dashboard loads with stats
   - Product List shows table
   - Add form saves a product and it appears in the list
   - Edit form pre-fills data and saves correctly
   - Delete removes the item from the list
