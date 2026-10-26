// Server: extracted from Input.tsx's own inline stepping logic (kept there unchanged, since it
// is still used for the drawable fallback and every other screen's steppers) so TextureControl.tsx
// can share the exact same wrap-around + blacklist-skip behavior without drifting from it. See
// ADR-078.
export function stepValue(value: number, factor: number, min: number, max: number, blacklisted: number[] = []): number {
  const isBlacklisted = (v: number) => blacklisted.includes(v);
  const normalize = (v: number) => (v < min ? max : v > max ? min : v);

  let next = value;
  if (factor === 0) {
    if (!isBlacklisted(next)) return normalize(next);
    factor = 1;
  }

  do {
    next = normalize(next + factor);
  } while (isBlacklisted(next));

  return next;
}
