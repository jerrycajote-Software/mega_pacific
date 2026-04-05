# Implementing Customer UI, Authentication, and Product Reviews

This plan covers the transition to the **Customer Module**, focusing on an E-Commerce style Home UI (similar to Lazada/Shopee), User Authentication (Login/Register), and a Product Review system.

## Proposed Changes

### Database Updates
We need new tables to support authentication and reviews, and an update to the products table for images.

#### [NEW] database/migrate_customer_features.sql
- Create `users` table (`id`, `name`, `email`, `password`, `created_at`).
- Create `reviews` table (`id`, `user_id`, `product_id`, `rating`, `comment`, `created_at`) to store 1-5 star reviews.
- Alter `products` table to add an `image_url` column. (You mentioned admins will upload photos later, so this will be empty `NULL` for now).

### Backend Changes

#### [MODIFY] backend/package.json
- Add `bcrypt` (for password hashing) and `jsonwebtoken` (for JWT auth).

#### [NEW] backend/routes/auth.js
- Implement `POST /api/auth/register` and `POST /api/auth/login`.

#### [NEW] backend/routes/reviews.js
- Implement `POST /api/reviews` (to add a review) and `GET /api/reviews/product/:id` (to list reviews for a product).

#### [MODIFY] backend/routes/products.js
- Update `POST` and `PUT` operations to accept the `image_url` field, so the admin has the capability to attach images in the future.
- Update `GET /products` to include the `image_url` so the frontend knows when to show a photo or an empty placeholder.

#### [MODIFY] backend/server.js
- Register the new `/auth` and `/reviews` routes.

---

### Frontend (Flutter Web) Changes

In order to support user sessions, we'll install the `shared_preferences` flutter package to store JWT tokens securely.

#### [NEW] frontend/lib/screens/auth/login_screen.dart & register_screen.dart
- Create dynamic and polished login/registration forms.

#### [NEW] frontend/lib/screens/customer/customer_home_screen.dart
- Create an e-commerce style landing page.
- Add an imitation banner (Shopee/Lazada style), promotional widgets, and a **Grid View of available Products**.
- The product cards will display an Empty Image View placeholder, Product Title, Price, and average rating.

#### [NEW] frontend/lib/screens/customer/product_details_screen.dart
- A dedicated page when a user clicks on a product from the home screen.
- Layout: Large image placeholder block, details, description.
- Review Section: Form to submit a star rating (1-5) and comment, along with a list of other users' reviews.
- "Add to Cart" and "Proceed to checkout" buttons (disabled for now).

#### [MODIFY] frontend/lib/main.dart
- Currently the app immediately launches the `AdminShell`. We will restructure it so the **LoginScreen** is the initial route. After logging in, the user will be routed to the **CustomerHomeScreen**. (We will keep a dedicated button or route to access the Admin Console).

#### [MODIFY] frontend/lib/services/api_service.dart
- Add methods for `login`, `register`, `fetchReviews`, and `submitReview`.
- Automatically attach the JWT token in authorization headers if the user is logged in.

## User Review Required
> [!IMPORTANT]
> **App Routing Impact:** Since we are introducing authentication, I'll update `main.dart` to open the **Login Page** first. After logging in, it will redirect to the new Customer UI. I will also leave an "Admin Login" toggle or separate admin route so you don't lose access to the Admin Dashboard.
>
> **Does this routing strategy sound good to you? Once you approve this plan, I'll start generating the database scripts and building out the backend auth.**
