// Servidor: fills whatever gap `resize.js` (or the last time this ran) left, by comparing
// qbx_core's own vehicle list against what's already in `images/` and downloading only the
// difference. Source is FiveM's official docs backend (WebP), converted to the same 256px PNG
// `resize.js` produces - no manual "which models are missing" list to maintain. See ADR-075.
//
// Not a project dependency - `npm install sharp` wherever you run this, then:
//   node fetch_missing.js
// Always finish a regeneration run with `node regen_data.js` (see that script).
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const IMAGES_DIR = path.join(__dirname, '..', 'images');
const VEHICLES_LUA = path.join(
  __dirname, '..', '..', '..', '[qbx]', 'qbx_core', 'shared', 'vehicles.lua'
);

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function knownModels() {
  const src = fs.readFileSync(VEHICLES_LUA, 'utf8');
  const re = /^\s{4}([a-zA-Z0-9_]+)\s*=\s*\{/gm;
  const models = new Set();
  let m;
  while ((m = re.exec(src))) models.add(m[1].toLowerCase());
  return models;
}

function haveModels() {
  return new Set(
    fs.readdirSync(IMAGES_DIR)
      .filter((f) => f.toLowerCase().endsWith('.png'))
      .map((f) => f.slice(0, -4).toLowerCase())
  );
}

(async () => {
  const known = knownModels();
  const have = haveModels();
  const missing = [...known].filter((m) => !have.has(m)).sort();

  if (missing.length === 0) {
    console.log('nothing missing - every qbx_core model already has an image.');
    return;
  }

  console.log(`missing: ${missing.length} (${missing.join(', ')})\n`);

  const ok = [];
  const failed = [];
  let bytes = 0;

  for (const model of missing) {
    try {
      const res = await fetch(`https://docs-backend.fivem.net/vehicles/${model}.webp`);
      if (!res.ok) { failed.push(`${model} (HTTP ${res.status})`); await sleep(150); continue; }

      const buf = Buffer.from(await res.arrayBuffer());
      const png = await sharp(buf)
        .resize({ width: 256, withoutEnlargement: true })
        .png({ compressionLevel: 9, palette: true })
        .toBuffer();

      fs.writeFileSync(path.join(IMAGES_DIR, `${model}.png`), png);
      bytes += png.length;
      ok.push(model);
    } catch (err) {
      failed.push(`${model} (${err.message})`);
    }
    await sleep(150); // be a polite client, this is someone else's server
  }

  console.log(`fetched: ${ok.length}/${missing.length}`);
  console.log(`added: ${(bytes / 1024 / 1024).toFixed(2)} MB`);
  if (failed.length) console.log(`\nFAILED (${failed.length}):\n  ` + failed.join('\n  '));
  console.log('\nNow run: node regen_data.js');
})();
