/* ==============================================
   Mega Pacific — 3D Roofing Visualizer
   main.js  (Three.js r158)
   ============================================== */

// ── Material Catalog (fallback if API is down) ───────────
const CATALOG = [
  { name: 'Pico Rib',      category: 'Roofing',     price: 450, hex: '#8fa8b4', roughness: 0.4, metalness: 0.65, desc: 'Lightweight corrugated roofing sheet with narrow rib profile.' },
  { name: 'Hermosa Tile',  category: 'Roofing',     price: 620, hex: '#b85c38', roughness: 0.82, metalness: 0.05, desc: 'Classic clay-style painted steel roofing tile.' },
  { name: 'Agua Corr',     category: 'Roofing',     price: 390, hex: '#6b8fa3', roughness: 0.42, metalness: 0.62, desc: 'Water-resistant corrugated galvanized sheet.' },
  { name: 'Twin Rib',      category: 'Roofing',     price: 480, hex: '#4a7a3d', roughness: 0.45, metalness: 0.55, desc: 'Dual-rib structural roofing for extra strength.' },
  { name: 'S-Rib',         category: 'Roofing',     price: 410, hex: '#c0c8cc', roughness: 0.35, metalness: 0.72, desc: 'S-profile galvanized steel with high reflectivity.' },
  { name: '6 Ribs',        category: 'Roofing',     price: 500, hex: '#5b7b9a', roughness: 0.40, metalness: 0.65, desc: 'Six-rib reinforced roofing for wide-span structures.' },
  { name: 'C Purlins',     category: 'Structural',  price: 750, hex: '#78909c', roughness: 0.55, metalness: 0.80, desc: 'C-section structural purlins for roof framing.' },
  { name: 'Spandrel 4"',   category: 'Ceiling',     price: 310, hex: '#f0ece4', roughness: 0.92, metalness: 0.02, desc: '4-inch spandrel ceiling board, smooth finish.' },
  { name: 'Spandrel 6"',   category: 'Ceiling',     price: 360, hex: '#e8e4dc', roughness: 0.92, metalness: 0.02, desc: '6-inch spandrel ceiling board, smooth finish.' },
  { name: 'Webdeck',       category: 'Decking',     price: 890, hex: '#6e7f8d', roughness: 0.52, metalness: 0.70, desc: 'High-load composite deck panel for concrete floors.' },
  { name: 'Flatdeck',      category: 'Decking',     price: 820, hex: '#607d8b', roughness: 0.55, metalness: 0.65, desc: 'Flat structural deck panel, wide coverage.' },
  { name: 'Gutter',        category: 'Accessories', price: 280, hex: '#a0adb5', roughness: 0.45, metalness: 0.62, desc: 'Steel rain gutter for drainage management.' },
  { name: 'Flashing',      category: 'Accessories', price: 195, hex: '#b8bec2', roughness: 0.40, metalness: 0.65, desc: 'Waterproof flashing strip for joints and edges.' },
  { name: 'Ridge Roll',    category: 'Accessories', price: 240, hex: '#9ba8b0', roughness: 0.45, metalness: 0.60, desc: 'Ridge roll cap cover for the roof apex.' },
  { name: 'Ridge Cap',     category: 'Accessories', price: 260, hex: '#8d9ba3', roughness: 0.45, metalness: 0.60, desc: 'Formed ridge cap for the roof peak.' },
  { name: 'Wall Capping',  category: 'Accessories', price: 215, hex: '#95a3ab', roughness: 0.42, metalness: 0.60, desc: 'Wall edge capping strip for a clean finish.' },
];

const CAT_COLORS = {
  Roofing:     '#1565C0',
  Structural:  '#6D4C41',
  Ceiling:     '#2E7D32',
  Decking:     '#5E35B1',
  Accessories: '#F57C00',
};

const HOUSE_CONFIGS = {
  small:     { wallW: 8,  wallH: 3,   wallD: 6,  ridgeH: 2.5, label: 'Small residential house • 8×6 m' },
  medium:    { wallW: 12, wallH: 4,   wallD: 8,  ridgeH: 3.5, label: 'Medium residential house • 12×8 m' },
  warehouse: { wallW: 16, wallH: 5,   wallD: 20, ridgeH: 2.0, label: 'Warehouse / commercial • 16×20 m' },
};

// Plain objects — THREE.Vector3 created lazily inside functions
const CAM_POSITIONS = {
  small:     { x: 14, y: 10, z: 18 },
  medium:    { x: 18, y: 13, z: 22 },
  warehouse: { x: 24, y: 16, z: 30 },
};

// ── Scene State ──────────────────────────────────────────
let scene, camera, renderer, controls;
let houseGroup = null;
let roofMeshes = [];
let roofMat = null;
let currentModelKey = 'small';
let selectedProduct = null;
let isNight = false;
let isXray = false;
let sunLight = null;
let wallMeshes = [];
let products = CATALOG;

// ── Texture Generator ────────────────────────────────────
function makeTexture(product) {
  const c = document.createElement('canvas');
  c.width = 512; c.height = 512;
  const ctx = c.getContext('2d');

  ctx.fillStyle = product.hex;
  ctx.fillRect(0, 0, 512, 512);

  const name = product.name;

  if (['Pico Rib', 'Agua Corr', '6 Ribs'].includes(name)) {
    // Narrow vertical ribs
    for (let x = 0; x < 512; x += 28) {
      const g = ctx.createLinearGradient(x, 0, x + 28, 0);
      g.addColorStop(0,    'rgba(0,0,0,0.18)');
      g.addColorStop(0.25, 'rgba(255,255,255,0.08)');
      g.addColorStop(0.75, 'rgba(255,255,255,0.08)');
      g.addColorStop(1,    'rgba(0,0,0,0.18)');
      ctx.fillStyle = g;
      ctx.fillRect(x, 0, 28, 512);
    }
  } else if (name === 'Twin Rib') {
    // Pairs of ribs
    for (let x = 0; x < 512; x += 60) {
      [x + 8, x + 22].forEach(rx => {
        const g = ctx.createLinearGradient(rx, 0, rx + 14, 0);
        g.addColorStop(0,   'rgba(0,0,0,0.2)');
        g.addColorStop(0.5, 'rgba(255,255,255,0.1)');
        g.addColorStop(1,   'rgba(0,0,0,0.2)');
        ctx.fillStyle = g;
        ctx.fillRect(rx, 0, 14, 512);
      });
    }
  } else if (name === 'S-Rib') {
    // Wide S ribs
    for (let x = 0; x < 512; x += 48) {
      const g = ctx.createLinearGradient(x, 0, x + 48, 0);
      g.addColorStop(0,    'rgba(0,0,0,0.12)');
      g.addColorStop(0.4,  'rgba(255,255,255,0.12)');
      g.addColorStop(0.6,  'rgba(255,255,255,0.12)');
      g.addColorStop(1,    'rgba(0,0,0,0.12)');
      ctx.fillStyle = g;
      ctx.fillRect(x, 0, 48, 512);
    }
  } else if (name === 'Hermosa Tile') {
    // Tile grid
    ctx.strokeStyle = 'rgba(0,0,0,0.3)';
    ctx.lineWidth = 4;
    for (let row = 0; row < 8; row++) {
      for (let col = 0; col < 8; col++) {
        const ox = (row % 2 === 0 ? 0 : 32) + col * 64;
        const oy = row * 64;
        ctx.beginPath();
        ctx.arc(ox + 32, oy + 58, 26, Math.PI, 0);
        ctx.stroke();
        ctx.strokeRect(ox + 6, oy + 4, 52, 56);
      }
    }
  } else if (['Webdeck', 'Flatdeck'].includes(name)) {
    // Trapezoidal deck profile
    for (let x = 0; x < 512; x += 64) {
      ctx.fillStyle = 'rgba(0,0,0,0.15)';
      ctx.fillRect(x, 0, 8, 512);
      ctx.fillRect(x + 56, 0, 8, 512);
      ctx.fillStyle = 'rgba(255,255,255,0.06)';
      ctx.fillRect(x + 8, 0, 48, 512);
    }
  } else {
    // Generic horizontal lines for others
    ctx.strokeStyle = 'rgba(0,0,0,0.1)';
    ctx.lineWidth = 2;
    for (let y = 40; y < 512; y += 40) {
      ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(512, y); ctx.stroke();
    }
  }

  const tex = new THREE.CanvasTexture(c);
  tex.wrapS = tex.wrapT = THREE.RepeatWrapping;
  tex.repeat.set(4, 8);
  return tex;
}

// ── Scene Setup ──────────────────────────────────────────
function setupScene() {
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x0d1b2a);
  scene.fog = new THREE.FogExp2(0x0d1b2a, 0.012);

  renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.toneMappingExposure = 1.15;
  document.getElementById('canvas-container').appendChild(renderer.domElement);

  camera = new THREE.PerspectiveCamera(48, window.innerWidth / window.innerHeight, 0.1, 500);
  const cp = CAM_POSITIONS.small;
  camera.position.set(cp.x, cp.y, cp.z);
  camera.lookAt(0, 2, 0);

  controls = new THREE.OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.dampingFactor = 0.06;
  controls.minDistance = 6;
  controls.maxDistance = 80;
  controls.maxPolarAngle = Math.PI / 2 - 0.04;
  controls.target.set(0, 2, 0);

  window.addEventListener('resize', onResize);
}

function setupLights() {
  scene.add(new THREE.AmbientLight(0x4a6fa5, 0.5));

  sunLight = new THREE.DirectionalLight(0xfff4e0, 2.2);
  sunLight.position.set(15, 22, 12);
  sunLight.castShadow = true;
  sunLight.shadow.mapSize.setScalar(2048);
  sunLight.shadow.camera.near = 0.5;
  sunLight.shadow.camera.far = 120;
  sunLight.shadow.camera.left = sunLight.shadow.camera.bottom = -25;
  sunLight.shadow.camera.right = sunLight.shadow.camera.top = 25;
  sunLight.shadow.bias = -0.001;
  scene.add(sunLight);

  const fill = new THREE.DirectionalLight(0x7baacc, 0.6);
  fill.position.set(-12, 10, -10);
  scene.add(fill);

  scene.add(new THREE.HemisphereLight(0x4a6fa5, 0x1a2f1a, 0.35));
}

function setupEnvironment() {
  // Ground
  const ground = new THREE.Mesh(
    new THREE.PlaneGeometry(200, 200),
    new THREE.MeshStandardMaterial({ color: 0x132030, roughness: 0.95, metalness: 0 })
  );
  ground.rotation.x = -Math.PI / 2;
  ground.receiveShadow = true;
  scene.add(ground);

  // Grid
  const grid = new THREE.GridHelper(120, 60, 0x1a3a50, 0x1a3a50);
  grid.material.opacity = 0.35;
  grid.material.transparent = true;
  scene.add(grid);

  // Stars
  const starGeo = new THREE.BufferGeometry();
  const pos = [];
  for (let i = 0; i < 2500; i++) {
    pos.push(
      (Math.random() - 0.5) * 300,
      Math.random() * 100 + 30,
      (Math.random() - 0.5) * 300
    );
  }
  starGeo.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
  scene.add(new THREE.Points(starGeo, new THREE.PointsMaterial({ color: 0xffffff, size: 0.18, transparent: true, opacity: 0.55 })));
}

// ── House Builder ─────────────────────────────────────────
function buildHouse(modelKey) {
  if (houseGroup) scene.remove(houseGroup);
  houseGroup = new THREE.Group();
  roofMeshes = [];
  wallMeshes = [];

  const cfg = HOUSE_CONFIGS[modelKey];
  const { wallW, wallH, wallD, ridgeH } = cfg;

  // Wall material
  const wallMatStd = new THREE.MeshStandardMaterial({ color: 0xddd5c0, roughness: 0.88, metalness: 0 });

  // Main walls box
  const walls = new THREE.Mesh(new THREE.BoxGeometry(wallW, wallH, wallD), wallMatStd);
  walls.position.y = wallH / 2;
  walls.castShadow = walls.receiveShadow = true;
  houseGroup.add(walls);
  wallMeshes.push(walls);

  // Gable triangles (front & back)
  const gShape = new THREE.Shape();
  gShape.moveTo(-wallW / 2, 0);
  gShape.lineTo(0, ridgeH);
  gShape.lineTo(wallW / 2, 0);
  gShape.closePath();
  const gableGeo = new THREE.ShapeGeometry(gShape);

  const fg = new THREE.Mesh(gableGeo, wallMatStd.clone());
  fg.position.set(0, wallH, wallD / 2 + 0.01);
  fg.castShadow = true;
  houseGroup.add(fg);
  wallMeshes.push(fg);

  const bg = new THREE.Mesh(gableGeo, wallMatStd.clone());
  bg.position.set(0, wallH, -wallD / 2 - 0.01);
  bg.rotation.y = Math.PI;
  bg.castShadow = true;
  houseGroup.add(bg);
  wallMeshes.push(bg);

  // Roof panels
  const slopeLen = Math.sqrt((wallW / 2) ** 2 + ridgeH ** 2);
  const slopeAng = Math.atan2(ridgeH, wallW / 2);
  const cx = wallW / 4;
  const cy = wallH + ridgeH / 2;

  roofMat = new THREE.MeshStandardMaterial({
    color: selectedProduct ? new THREE.Color(selectedProduct.hex) : new THREE.Color(0x8fa8b4),
    roughness: selectedProduct ? selectedProduct.roughness : 0.4,
    metalness: selectedProduct ? selectedProduct.metalness : 0.65,
    map: selectedProduct ? makeTexture(selectedProduct) : null,
  });

  const mkPanel = (xPos, rotZ) => {
    const m = new THREE.Mesh(new THREE.BoxGeometry(slopeLen + 0.5, 0.08, wallD + 0.5), roofMat);
    m.position.set(xPos, cy, 0);
    m.rotation.z = rotZ;
    m.castShadow = m.receiveShadow = true;
    houseGroup.add(m);
    roofMeshes.push(m);
  };
  mkPanel(-cx,  slopeAng);
  mkPanel( cx, -slopeAng);

  // Ridge cap
  const ridge = new THREE.Mesh(
    new THREE.BoxGeometry(0.25, 0.22, wallD + 0.5),
    new THREE.MeshStandardMaterial({ color: 0x5a6e78, roughness: 0.55, metalness: 0.45 })
  );
  ridge.position.set(0, wallH + ridgeH + 0.05, 0);
  ridge.castShadow = true;
  houseGroup.add(ridge);

  // Eave overhang strips
  const eaveMat = new THREE.MeshStandardMaterial({ color: 0xc8b89a, roughness: 0.9, metalness: 0 });
  const eaveH = 0.12, eaveD = wallD + 0.5;
  [-wallW / 2 - 0.2, wallW / 2 + 0.2].forEach((ex, i) => {
    const e = new THREE.Mesh(new THREE.BoxGeometry(0.4, eaveH, eaveD), eaveMat);
    e.position.set(ex * (i === 0 ? -1 : 1) * 0 + (i === 0 ? -wallW / 2 - 0.2 : wallW / 2 + 0.2), wallH - eaveH / 2, 0);
    houseGroup.add(e);
  });

  // Windows
  const winMat = new THREE.MeshStandardMaterial({
    color: 0x9ecef5, roughness: 0.05, metalness: 0, transparent: true,
    opacity: 0.7, emissive: 0x2255aa, emissiveIntensity: isNight ? 0.8 : 0.2,
  });
  const addWin = (x, y, z, ry = 0) => {
    const w = new THREE.Mesh(new THREE.BoxGeometry(1.1, 0.9, 0.06), winMat);
    w.position.set(x, y, z); w.rotation.y = ry; houseGroup.add(w);
  };
  addWin(-wallW * 0.27, wallH * 0.58,  wallD / 2 + 0.04);
  addWin( wallW * 0.27, wallH * 0.58,  wallD / 2 + 0.04);
  addWin(-wallW * 0.27, wallH * 0.58, -wallD / 2 - 0.04, Math.PI);
  addWin( wallW * 0.27, wallH * 0.58, -wallD / 2 - 0.04, Math.PI);
  if (wallW >= 12) {
    addWin(wallW / 2 + 0.04, wallH * 0.58, -wallD * 0.25, Math.PI / 2);
    addWin(wallW / 2 + 0.04, wallH * 0.58,  wallD * 0.25, Math.PI / 2);
  }

  // Door
  const door = new THREE.Mesh(
    new THREE.BoxGeometry(1.0, 1.9, 0.07),
    new THREE.MeshStandardMaterial({ color: 0x5d4037, roughness: 0.85, metalness: 0.1 })
  );
  door.position.set(0, 0.95, wallD / 2 + 0.04);
  houseGroup.add(door);

  // Chimney
  const chimney = new THREE.Mesh(
    new THREE.BoxGeometry(0.7, ridgeH * 0.7 + 0.6, 0.7),
    new THREE.MeshStandardMaterial({ color: 0x8d6e63, roughness: 0.92, metalness: 0 })
  );
  chimney.position.set(wallW * 0.22, wallH + ridgeH * 0.36, wallD * 0.18);
  chimney.castShadow = true;
  houseGroup.add(chimney);

  scene.add(houseGroup);
}

// ── UI Builder ────────────────────────────────────────────
function buildMaterialPanel() {
  const list = document.getElementById('material-list');
  list.innerHTML = '';

  const categories = [...new Set(products.map(p => p.category))];
  document.getElementById('mat-count').textContent = products.length;

  categories.forEach(cat => {
    const items = products.filter(p => p.category === cat);
    const group = document.createElement('div');
    group.className = 'cat-group';

    const label = document.createElement('div');
    label.className = 'cat-label';
    label.innerHTML = `<span class="cat-dot" style="background:${CAT_COLORS[cat] || '#607D8B'}"></span>${cat}`;
    group.appendChild(label);

    items.forEach(p => {
      const card = document.createElement('div');
      card.className = 'mat-card';
      card.dataset.name = p.name;
      card.innerHTML = `
        <div class="mat-swatch" style="background:${p.hex}"></div>
        <div class="mat-info">
          <div class="mat-name">${p.name}</div>
          <div class="mat-price">₱${p.price.toLocaleString()}/sheet</div>
        </div>`;
      card.addEventListener('click', () => selectMaterial(p));
      group.appendChild(card);
    });

    list.appendChild(group);
  });
}

function selectMaterial(product) {
  selectedProduct = product;

  // Update roof material
  if (roofMat) {
    roofMat.color.set(product.hex);
    roofMat.roughness = product.roughness;
    roofMat.metalness = product.metalness;
    roofMat.map = makeTexture(product);
    roofMat.needsUpdate = true;
  }

  // Highlight selected card
  document.querySelectorAll('.mat-card').forEach(c => c.classList.remove('selected'));
  const card = document.querySelector(`.mat-card[data-name="${product.name}"]`);
  if (card) card.classList.add('selected');

  // Update info panel
  const info = document.getElementById('material-info');
  info.innerHTML = `
    <div class="mat-detail-swatch" style="background:${product.hex};"></div>
    <div class="mat-detail-name">${product.name}</div>
    <div class="mat-detail-cat" style="color:${CAT_COLORS[product.category] || '#aaa'}">${product.category}</div>
    <div class="mat-detail-desc">${product.desc}</div>
    <div class="mat-detail-price">₱${product.price.toLocaleString()} <span>per sheet</span></div>`;

  // Status bar
  document.getElementById('status-text').textContent =
    `✅ Viewing: ${product.name} — ₱${product.price.toLocaleString()}/sheet`;

  updateEstimator();
}

function updateEstimator() {
  if (!selectedProduct) return;
  const qty  = parseFloat(document.getElementById('sheet-qty').value)  || 0;
  const area = parseFloat(document.getElementById('roof-area').value)   || 0;
  const total = selectedProduct.price * qty;
  document.getElementById('est-value').textContent = `₱ ${total.toLocaleString('en-PH', { minimumFractionDigits: 2 })}`;
}

// ── Controls ──────────────────────────────────────────────
function toggleXray() {
  isXray = !isXray;
  wallMeshes.forEach(m => {
    m.material.transparent = isXray;
    m.material.opacity = isXray ? 0.15 : 1.0;
    m.material.wireframe = isXray;
    m.material.needsUpdate = true;
  });
  document.getElementById('btn-xray').classList.toggle('active-btn', isXray);
}

function toggleLighting() {
  isNight = !isNight;
  if (isNight) {
    scene.background = new THREE.Color(0x030810);
    scene.fog = new THREE.FogExp2(0x030810, 0.012);
    sunLight.intensity = 0.3;
    sunLight.color.set(0x8899cc);
  } else {
    scene.background = new THREE.Color(0x0d1b2a);
    scene.fog = new THREE.FogExp2(0x0d1b2a, 0.012);
    sunLight.intensity = 2.2;
    sunLight.color.set(0xfff4e0);
  }
  document.getElementById('btn-lighting').classList.toggle('active-btn', isNight);
}

function resetCamera() {
  const cp = CAM_POSITIONS[currentModelKey];
  camera.position.set(cp.x, cp.y, cp.z);
  controls.target.set(0, 2, 0);
  controls.update();
}

function switchModel(key) {
  currentModelKey = key;
  buildHouse(key);
  resetCamera();
  document.getElementById('model-desc').textContent = HOUSE_CONFIGS[key].label;
  document.querySelectorAll('.model-btn').forEach(b => b.classList.toggle('active', b.dataset.model === key));
}

// ── Search ────────────────────────────────────────────────
function filterMaterials(query) {
  document.querySelectorAll('.mat-card').forEach(card => {
    const name = card.dataset.name.toLowerCase();
    card.style.display = name.includes(query.toLowerCase()) ? '' : 'none';
  });
  document.querySelectorAll('.cat-group').forEach(group => {
    const visible = [...group.querySelectorAll('.mat-card')].some(c => c.style.display !== 'none');
    group.style.display = visible ? '' : 'none';
  });
}

// ── Animation Loop ────────────────────────────────────────
function animate() {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
}

function onResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}

// ── API Fetch ─────────────────────────────────────────────
async function fetchProducts() {
  // Manual timeout — compatible with all browsers
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 3000);
  try {
    const res = await fetch('http://localhost:3000/products', { signal: controller.signal });
    clearTimeout(timer);
    if (!res.ok) return;
    const data = await res.json();
    products = CATALOG.map(local => {
      const api = data.find(p => p.name === local.name);
      return api ? { ...local, price: parseFloat(api.price), stock: api.stock } : local;
    });
  } catch (_) {
    clearTimeout(timer);
    // API not available — use fallback catalog silently
  }
}

// ── Helper: hide loading screen ───────────────────────────
function hideLoader() {
  const overlay = document.getElementById('loading-overlay');
  if (!overlay) return;
  overlay.classList.add('hidden');
  setTimeout(() => { if (overlay.parentNode) overlay.remove(); }, 600);
}

// Safety net: if anything crashes before main() finishes, still hide the loader
window.addEventListener('error', () => hideLoader());

// ── Init ──────────────────────────────────────────────────
async function main() {
  try {
    setupScene();
    setupLights();
    setupEnvironment();
    buildHouse('small');

    await fetchProducts();
    buildMaterialPanel();

    // Event listeners
    document.getElementById('btn-xray').addEventListener('click', toggleXray);
    document.getElementById('btn-lighting').addEventListener('click', toggleLighting);
    document.getElementById('btn-reset').addEventListener('click', resetCamera);
    document.getElementById('mat-search').addEventListener('input', e => filterMaterials(e.target.value));
    document.getElementById('roof-area').addEventListener('input', updateEstimator);
    document.getElementById('sheet-qty').addEventListener('input', updateEstimator);
    document.querySelectorAll('.model-btn').forEach(btn =>
      btn.addEventListener('click', () => switchModel(btn.dataset.model))
    );

    animate();
  } catch (err) {
    console.error('3D Viewer error:', err);
  } finally {
    // Always hide loader — whether success or error
    setTimeout(hideLoader, 500);
  }
}

main();
