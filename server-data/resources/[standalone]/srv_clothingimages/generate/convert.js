// Servidor: converts a source pack of clothing preview images into this resource's own `images/`.
// The pack is organized as `<slot>/<Male|Female>/M(<drawable>).jpg` or `F(<drawable>).jpg`, one
// image per drawable (textures of the same drawable share a look, so this is not per-texture).
// `<slot>` is a bare GTA V component id (1, 3, 4, 5, 6, 7, 8, 9, 11) or a prop id prefixed with
// `p` (p0, p1, p2, p6, p7) - the standard component/prop numbering, not something this project
// invented.
//
// The source files are all named `.jpg` but are actually WebP (confirmed via magic bytes, not
// assumed) - converted to PNG here for the same reason ADR-075 chose PNG for vehicle images:
// nothing in this project has verified serving `.webp` to NUI, and these are tiny already
// (~2KB, 83x120) so there is no size cost to being conservative.
//
// Output filenames: `c<component>_<m|f>_<drawable>.png` or `p<prop>_<m|f>_<drawable>.png` - the
// exact scheme `clothingImage()` in the forked UI (src/utils/misc.ts) builds when requesting an
// image, so a resize/rename here and a matching read there must stay in sync by hand.
//
// Not a project dependency - `npm install sharp` wherever you run this, then:
//   node convert.js <path-to-source-pack-folder>
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const SRC = process.argv[2];
const DEST = path.join(__dirname, '..', 'images');

if (!SRC) {
  console.error('Usage: node convert.js <path-to-source-pack-folder>');
  process.exit(1);
}

const SLOT_DIRS = fs.readdirSync(SRC).filter((d) => fs.statSync(path.join(SRC, d)).isDirectory());

(async () => {
  let converted = 0;
  let bytesIn = 0;
  let bytesOut = 0;
  const failed = [];

  for (const slot of SLOT_DIRS) {
    const isProp = slot.startsWith('p');
    const slotId = isProp ? slot.slice(1) : slot;
    const prefix = isProp ? 'p' : 'c';

    for (const [genderDir, genderChar] of [['Male', 'm'], ['Female', 'f']]) {
      const dir = path.join(SRC, slot, genderDir);
      if (!fs.existsSync(dir)) continue;

      for (const file of fs.readdirSync(dir)) {
        const match = file.match(/^[MF]\((\d+)\)\.jpg$/i);
        if (!match) {
          failed.push(`${slot}/${genderDir}/${file}: unrecognized filename`);
          continue;
        }
        const drawable = match[1];
        const srcPath = path.join(dir, file);
        const destName = `${prefix}${slotId}_${genderChar}_${drawable}.png`;

        try {
          bytesIn += fs.statSync(srcPath).size;
          const buf = await sharp(srcPath).png({ compressionLevel: 9, palette: true }).toBuffer();
          fs.writeFileSync(path.join(DEST, destName), buf);
          bytesOut += buf.length;
          converted++;
        } catch (err) {
          failed.push(`${slot}/${genderDir}/${file}: ${err.message}`);
        }
      }
    }
  }

  console.log(`converted: ${converted}`);
  console.log(`before: ${(bytesIn / 1024 / 1024).toFixed(1)} MB`);
  console.log(`after:  ${(bytesOut / 1024 / 1024).toFixed(1)} MB`);
  if (failed.length) console.log('FAILED:\n  ' + failed.join('\n  '));
})();
