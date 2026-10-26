// Servidor: rebuilds data.lua from whatever is actually in `images/`, rather than trusting
// resize.js or fetch_missing.js to have reported themselves accurately - so the table can never
// claim a file that isn't there, or miss one that is. Run this last, always, after any change to
// `images/` (including a manual one). See ADR-075.
//
// node regen_data.js
const fs = require('fs');
const path = require('path');

const IMAGES_DIR = path.join(__dirname, '..', 'images');
const OUT = path.join(__dirname, '..', 'data.lua');

const models = fs.readdirSync(IMAGES_DIR)
  .filter((f) => f.toLowerCase().endsWith('.png'))
  .map((f) => f.slice(0, -4).toLowerCase())
  .sort();

fs.writeFileSync(OUT,
  '-- Servidor: GENERATED - do not edit by hand. Every vehicle model that has a preview image in\n' +
  '-- `images/`. Consumers check membership here before building a `nui://` path, so a model the\n' +
  "-- image set doesn't cover renders no image instead of a broken one. Regenerate with\n" +
  '-- generate/regen_data.js (see docs/operations.md) whenever the image set changes.\n' +
  'VehicleImages = {\n' +
  models.map((m) => `    ['${m}'] = true,`).join('\n') +
  '\n}\n\nreturn VehicleImages\n',
  'utf8'
);

console.log(`data.lua regenerated: ${models.length} models`);
