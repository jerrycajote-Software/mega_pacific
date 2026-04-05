implementation plan

# 🏗️ Phase 3 — 3D Roofing Visualizer
## Three.js + HTML/CSS/JS

Build the standalone `3d-module/` web viewer with Three.js.

---

## Files Created

### `3d-module/index.html`
- Full-screen layout with canvas
- Top bar: Mega Pacific branding + X-Ray / Day-Night / Reset buttons
- Left panel: material list (grouped by category, searchable)
- Right panel: selected material info + cost estimator + house model switcher
- Bottom status bar: selected material + mouse controls hint

### `3d-module/style.css`
- Dark navy glassmorphism theme (`#09131e`)
- Blurred frosted glass panels via `backdrop-filter`
- Inter font, smooth transitions, custom scrollbar
- Responsive panel layout

### `3d-module/main.js`
- Three.js r158 scene with PerspectiveCamera, OrbitControls (damping)
- Lighting: ambient + directional sun (PCF shadows) + hemisphere fill
- Environment: ground plane, grid helper, 2500-star particle field
- House builder: walls, gable roof (correct math), gable triangles, ridge cap, eave strips, windows, door, chimney
- Canvas texture generator: corrugated, twin-rib, S-rib, tile, deck patterns per product
- 16 materials from catalog with color, roughness, metalness, description
- API fetch: tries `localhost:3000/products` for live prices, falls back to catalog
- X-Ray toggle: wall wireframe mode
- Day/Night toggle: scene bg + sun color/intensity switch
- House model switcher: Small / Medium / Warehouse (rebuilds house)
- Cost estimator: live qty × price = total
- Material search filter

---

## Task Checklist

## 🏗️ Phase 3 Build Tasks
- [x] Create `3d-module/index.html`
- [x] Create `3d-module/style.css`
- [x] Create `3d-module/main.js`

## ✅ Verification
- [x] Open `3d-module/index.html` in Chrome and confirm 3D house renders
- [x] Click materials to verify roof color/texture changes
- [x] Test X-Ray, Day/Night, Reset, model switcher
- [x] Test cost estimator inputs (25 sheets × ₱450 = ₱11,250.00 ✓)

## 🔧 Fix Applied
- Switched from CDN Three.js/OrbitControls to **local files** (`three.min.js`, `OrbitControls.js`)
  - Reason: Browser ORB (Opaque Response Blocking) was preventing `THREE.OrbitControls` from loading via CDN
  - Used Three.js r145 (OrbitControls compatible with global `THREE` namespace)

