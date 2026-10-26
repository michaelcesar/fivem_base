// Servidor: generates `manifest.json` by reading what is actually in `images/`, never from what
// `convert.js` believed it wrote - same "trust the disk, not the last step" rule
// `srv_vehicleimages/generate/regen_data.js` follows. Lets the forked clothing UI's drawable
// grid (`DrawableGrid.tsx`) render only real, covered drawables instead of guessing at the full
// 0-255 range and hiding empty tiles one 404 at a time. Run after `convert.js`, or any time
// `images/` changes by hand:
//   node manifest.js
const fs = require('fs');
const path = require('path');

const IMAGES_DIR = path.join(__dirname, '..', 'images');
const OUT_FILE = path.join(__dirname, '..', 'manifest.json');

const manifest = {};

for (const file of fs.readdirSync(IMAGES_DIR)) {
  const match = file.match(/^([cp]\d+)_([mf])_(\d+)\.png$/);
  if (!match) continue;
  const [, key, gender, drawable] = match;

  manifest[key] ??= { m: [], f: [] };
  manifest[key][gender].push(Number(drawable));
}

for (const key of Object.keys(manifest)) {
  manifest[key].m.sort((a, b) => a - b);
  manifest[key].f.sort((a, b) => a - b);
}

fs.writeFileSync(OUT_FILE, JSON.stringify(manifest));
console.log(`wrote manifest.json - ${Object.keys(manifest).length} keys`);
