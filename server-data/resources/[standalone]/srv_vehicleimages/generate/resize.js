// Servidor: bulk-converts a local folder of vehicle preview PNGs (named by spawn model, e.g.
// `adder.png`) into this resource's own `images/` - 256px wide because that is exactly ox_lib's
// context-menu hover-card `maxWidth` (ContextButton.tsx's `dropdown` style), so it is the
// largest size anything actually renders. PNG, not WebP: nothing in this project serves a
// `.webp` to NUI and that support has not been verified in-game - PNG at this size is still a
// ~93% cut over the source pack and carries no such open question. See ADR-075.
//
// Not a project dependency - `npm install sharp` wherever you run this, then:
//   node resize.js <path-to-source-folder-of-pngs>
// Always finish a regeneration run with `node regen_data.js` (see that script) - this one only
// touches `images/`, never `data.lua`.
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const SRC = process.argv[2];
const DEST = path.join(__dirname, '..', 'images');

if (!SRC) {
  console.error('Usage: node resize.js <path-to-source-folder-of-pngs>');
  process.exit(1);
}

(async () => {
  const files = fs.readdirSync(SRC).filter((f) => f.toLowerCase().endsWith('.png'));
  const models = [];
  let bytesIn = 0, bytesOut = 0;
  const failed = [];

  for (const file of files) {
    const model = path.basename(file, '.png').toLowerCase();
    try {
      bytesIn += fs.statSync(path.join(SRC, file)).size;
      const buf = await sharp(path.join(SRC, file))
        .resize({ width: 256, withoutEnlargement: true })
        .png({ compressionLevel: 9, palette: true })
        .toBuffer();
      fs.writeFileSync(path.join(DEST, `${model}.png`), buf);
      bytesOut += buf.length;
      models.push(model);
    } catch (err) {
      failed.push(`${file}: ${err.message}`);
    }
  }

  console.log(`converted: ${models.length}/${files.length}`);
  console.log(`before: ${(bytesIn / 1024 / 1024).toFixed(1)} MB`);
  console.log(`after:  ${(bytesOut / 1024 / 1024).toFixed(1)} MB`);
  if (bytesIn > 0) console.log(`cut: ${(100 - (bytesOut / bytesIn) * 100).toFixed(1)}%`);
  if (failed.length) console.log('FAILED:\n  ' + failed.join('\n  '));
  console.log('\nNow run: node regen_data.js');
})();
