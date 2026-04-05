# 🏠 Blender Guide — House Model + Product Materials
### For Mega Pacific 3D Roofing Visualizer

> This guide takes you from zero to a fully export-ready house model with real roofing product materials, ready to load in your Three.js viewer.

---

## 📋 What You'll Need

| Tool | Purpose | Download |
|---|---|---|
| **Blender 4.x** | 3D modeling + materials | [blender.org](https://www.blender.org/download/) |
| **Your product photos** | Real texture source (shoot the actual sheet) | Phone camera |
| **Three.js r145** | Already in your project | ✅ Done |

---

## PART 1 — Modeling the House

### Step 1: Set Up the Scene

1. Open Blender → delete the default cube (`X` → Delete)
2. Set units: **Properties panel → Scene tab → Units → Metric, Unit Scale = 1.0**
3. Press `Numpad 5` to toggle **Orthographic view**

---

### Step 2: Build the Walls (Box)

```
Main wall footprint:
  Small house  →  8m wide × 6m deep × 3m tall
  Medium house → 12m wide × 8m deep × 4m tall
```

1. `Shift + A` → Mesh → Cube
2. Press `S` → type `4` → Enter *(scales to 8m width)*
3. Press `S Y` → type `3` → Enter *(6m depth)*
4. Press `S Z` → type `1.5` → Enter *(3m height)*
5. `G Z` → type `1.5` → Enter *(lift it so it sits on the ground)*
6. In **Object Properties**, rename it: `Walls`

---

### Step 3: Build the Gable Roof

1. `Shift + A` → Mesh → **Cylinder** → change Vertices to **4** in the bottom-left popup
   - This creates a diamond/square shape rotated 45° — perfect for a roof cross-section
2. `S` to match the wall width, `R X 90` to rotate
3. Switch to **Edit Mode** (`Tab`)
4. Select the top vertex → `G Z` to raise it to the ridge height (~2.5m)
5. Scale the bottom edge to match wall width exactly
6. Extrude (`E Y`) along Y-axis to the full wall depth

> **Shortcut tip:** You can also use the **Roof Generator** add-on (free, built-in) under Edit → Preferences → Add-ons → search "Archimesh"

---

### Step 4: Add Gable Triangles (Front & Back Walls)

1. In Edit Mode on the wall box, select the top front/back edges
2. Use `F` to fill a face, then manually shape it as a triangle to close the gable ends
3. Or model them as separate flat plane objects positioned in front/behind

---

### Step 5: Add Windows and Door

**Windows:**
1. `Shift + A` → Mesh → Plane → scale to `1.1m × 0.9m`
2. Position on the wall face (`G`, `R`)
3. In Object Properties → name it `Window_Front_L`
4. Duplicate (`Shift + D`) for each window

**Door:**
1. `Shift + A` → Mesh → Plane → scale to `1m × 2m`
2. Position centered on the front wall at ground level

> **Pro tip:** Use the **Bool Tool** add-on to cut actual holes in the wall mesh for a more realistic result.

---

### Step 6: Add Chimney

1. `Shift + A` → Mesh → Cube
2. Scale to `0.7m × 0.7m × 1.5m tall`
3. Position it on the roof slope near the ridge

---

### Step 7: Organize with Collections

In the **Outliner** panel (top right):
- Create a Collection called `House`
- Sub-collections: `Roof`, `Walls`, `Details`
- Drag your objects into the right collection

---

## PART 2 — UV Unwrapping (Required for Textures)

UV unwrapping tells Blender how to "unfold" the 3D surface so a 2D texture can be painted on it correctly.

### Roof Panel Unwrap

1. Select the roof mesh → go to **Edit Mode** (`Tab`)
2. Select all faces (`A`)
3. On roof slope faces: `U` → **Project from View** (This makes corrugated ribs run parallel to the slope)
4. For the full mesh: `U` → **Smart UV Project** → Accept defaults
5. Open the **UV Editor** workspace (top tabs) to see the unwrap

### Wall Unwrap

1. Select wall mesh → Edit Mode
2. Mark seams at corners: select edge → `Ctrl + E` → **Mark Seam** (mark all 4 vertical corners)
3. `A` to select all → `U` → **Unwrap**
4. In UV Editor, scale and position the UV islands so they fill most of the space

---

## PART 3 — Creating Real Product Materials

This is where Blender shines. You'll create materials that match the actual Mega Pacific products.

### Setting Up the Material Workspace

1. Switch to the **Shading** workspace (top tabs)
2. Select your roof mesh
3. In the material panel, click **+ New**
4. Name it: `MP_Pico_Rib` (or whatever product)

### The Node Setup for Corrugated Metal (Pico Rib, Agua Corr, 6 Ribs)

In the Shader Editor at the bottom:

```
[Texture Coordinate] → [Mapping]
        ↓
[Image Texture]  ←── your product photo or generated texture
        ↓ Color
[Bump Map]
        ↓ Normal
[Principled BSDF]
   - Base Color: from Image Texture
   - Metallic: 0.7
   - Roughness: 0.4
   - Normal: from Bump
        ↓
[Material Output]
```

**Step by step in Blender:**
1. Press `Shift + A` in Shader Editor → Texture → Image Texture
2. Click **Open** → browse to your product photo
3. `Shift + A` → Vector → Mapping (connect Texture Coordinate UV → Mapping → Image Texture Vector)
4. In Mapping node: Scale X = 8, Scale Y = 4 (makes the rib pattern repeat realistically)
5. `Shift + A` → Vector → Bump
6. Connect: Image Texture (Color) → Bump (Height), Bump (Normal) → Principled BSDF (Normal)
7. Set **Principled BSDF**:
   - Metallic = 0.65 → 0.75
   - Roughness = 0.35 → 0.45
   - IOR = 1.5

### The Node Setup for Hermosa Tile

Same setup but:
- Use a tile photo or a generated Voronoi texture for the tile pattern
- Metallic = 0.05 (it's painted steel, not bare metal)
- Roughness = 0.82
- Add a color overlay: `Shift + A` → Color → Hue/Saturation to tint the base color

### The Node Setup for Bare Metal (S-Rib, Ridge Cap)

```
[Noise Texture] → [ColorRamp] → Principled BSDF Base Color
[Noise Texture] → Roughness  (adds surface variation)
Metallic = 0.75
Roughness = 0.30
```

This simulates the micro-variations in galvanized steel without needing a photo.

---

## PART 4 — Taking Real Product Photos (for Textures)

> **This is the "real product to digital world" step your project requires.**

### Photography Setup

| Setting | Value |
|---|---|
| **Lighting** | Overcast day / diffused light (no harsh shadows) |
| **Angle** | Shoot straight down, parallel to the ribs |
| **Distance** | Close enough to see the rib profile detail |
| **Format** | JPG or PNG, at least 2048×2048 px |

### What to Photograph

For each roofing product:
1. **Top-down flat shot** — this becomes the diffuse/albedo texture
2. **Angled shot** — shows the rib height, helps you judge the bump strength
3. **Color chip** — accurate color under neutral light

### Processing the Photo in Blender

After importing your photo:
1. Go to **Texture Paint** workspace
2. Use **Clone Brush** to make the texture tileable (removes seams at edges)
3. Or use the free website **[Seamless Textures - Poly Haven](https://polyhaven.com/textures)** as a starting base and add your color tint

---

## PART 5 — Exporting for Three.js

### Export as .glb (Recommended)

1. File → Export → **glTF 2.0 (.glb/.gltf)**
2. Settings:
   - Format: **glTF Binary (.glb)**
   - ✅ Include: Selected Objects
   - ✅ Mesh: Apply Modifiers
   - ✅ Materials: Export
   - ✅ Texture: Automatically Export Textures
   - Compression: Draco (smaller file, Three.js supports it)
3. Save as: `3d-module/models/house_small.glb`

---

## PART 6 — Loading Your .glb in Three.js

Replace the current procedural house builder in `main.js` with a GLTFLoader:

```javascript
// Add this script to index.html BEFORE main.js:
// <script src="https://unpkg.com/three@0.145.0/examples/js/loaders/GLTFLoader.js"></script>
// <script src="https://unpkg.com/three@0.145.0/examples/js/loaders/DRACOLoader.js"></script>

function loadHouseModel(modelPath) {
  // Remove old house
  if (houseGroup) scene.remove(houseGroup);

  const loader = new THREE.GLTFLoader();
  
  // Optional: Draco decompression for smaller files
  const dracoLoader = new THREE.DRACOLoader();
  dracoLoader.setDecoderPath('https://www.gstatic.com/draco/versioned/decoders/1.5.6/');
  loader.setDRACOLoader(dracoLoader);

  loader.load(
    modelPath,
    (gltf) => {
      houseGroup = gltf.scene;
      
      // Scale to match your scene units (1 Blender unit = 1 meter)
      houseGroup.scale.set(1, 1, 1);
      houseGroup.position.set(0, 0, 0);
      
      // Collect roof meshes for material switching
      houseGroup.traverse((child) => {
        if (child.isMesh) {
          child.castShadow = true;
          child.receiveShadow = true;
          // Tag roof meshes by name (name them "Roof" in Blender)
          if (child.name.toLowerCase().includes('roof')) {
            roofMeshes.push(child);
            child.material = roofMat; // apply current selected material
          }
          // Tag wall meshes
          if (child.name.toLowerCase().includes('wall')) {
            wallMeshes.push(child);
          }
        }
      });

      scene.add(houseGroup);
    },
    (progress) => {
      const pct = Math.round((progress.loaded / progress.total) * 100);
      document.getElementById('status-text').textContent = `Loading model… ${pct}%`;
    },
    (error) => {
      console.error('Model load error:', error);
    }
  );
}

// Call it instead of buildHouse():
loadHouseModel('./models/house_small.glb');
```

### Naming Convention in Blender (Important!)

Name your Blender objects exactly like this so the Three.js code above can find them:

| Blender Object Name | Three.js picks it up as |
|---|---|
| `Roof_Left` | roofMesh ✅ |
| `Roof_Right` | roofMesh ✅ |
| `Wall_Front` | wallMesh ✅ |
| `Wall_Back` | wallMesh ✅ |
| `Window_01` | skipped (neither) |
| `Door_01` | skipped |
| `Chimney` | skipped |

---

## PART 7 — Applying Material Switching to the glTF Model

When the user clicks a material in your viewer, update the roof mesh's material:

```javascript
function selectMaterial(product) {
  selectedProduct = product;

  // Build a new Three.js material from the selected catalog entry
  roofMat = new THREE.MeshStandardMaterial({
    color: new THREE.Color(product.hex),
    roughness: product.roughness,
    metalness: product.metalness,
    map: makeTexture(product),  // your canvas texture generator still works!
  });

  // Apply to all roof meshes in the loaded glTF model
  roofMeshes.forEach(mesh => {
    mesh.material = roofMat;
  });

  // ... rest of your existing selectMaterial() code
}
```

> **Advanced:** Load the actual product photo texture instead of the canvas-generated one:
> ```javascript
> const loader = new THREE.TextureLoader();
> loader.load(`./textures/${product.name.replace(/ /g,'_')}.jpg`, (tex) => {
>   tex.wrapS = tex.wrapT = THREE.RepeatWrapping;
>   tex.repeat.set(4, 8);
>   roofMat.map = tex;
>   roofMat.needsUpdate = true;
> });
> ```

---

## ✅ Project Checklist

- [ ] Install Blender 4.x
- [ ] Model house (walls, gable, windows, door, chimney)
- [ ] UV unwrap roof and wall surfaces
- [ ] Photograph each roofing product (flat, diffuse light)
- [ ] Create PBR materials in Blender for each product
- [ ] Export as `.glb` → save to `3d-module/models/`
- [ ] Download `GLTFLoader.js` and `DRACOLoader.js` locally (same pattern as OrbitControls)
- [ ] Replace `buildHouse()` in `main.js` with `loadHouseModel()`
- [ ] Name Blender objects with `Roof_` prefix so material switching works
- [ ] Test in browser — click material → roof updates on glTF model

---

## 💡 Tips for Beginners

| Shortcut | What it does |
|---|---|
| `G` | Grab/move object |
| `S` | Scale |
| `R` | Rotate |
| `G X / G Y / G Z` | Move along one axis |
| `Numpad 1/3/7` | Front/Side/Top view |
| `Tab` | Toggle Edit/Object mode |
| `Ctrl + Z` | Undo |
| `Shift + A` | Add object/node |
| `Numpad 0` | Camera view |
| `F12` | Render |

> 🎬 **Recommended Blender tutorial channels:**
> - **Blender Guru** (youtube) — "Donut Tutorial" for absolute beginners
> - **Grant Abbitt** — architectural modeling
> - **CG Cookie** — texturing and PBR materials
