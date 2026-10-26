/**
 * Server: a slot-sized rendering of an item count, plus the full number for a tooltip.
 *
 * Reported as "os labels de quantidade em números grandes quebram": a stack of 960,158,456,349,660,000
 * rendered through `toLocaleString` is 25 characters wide, which overflows the slot and lands on top
 * of the weight label beside it. The slot is ~10vh across and cannot grow.
 *
 * So the label is abbreviated and the exact value moves to the element's `title`, where hovering
 * still gives you the real number. Nothing is lost - it just stops being shouted.
 *
 * Thresholds are the SI-style suffixes players already read in games (K/M/B/T), extended past
 * trillion because item counts here are not bounded by anything sane. Two significant decimals
 * below 100 and none above, which keeps every abbreviated form at 5 characters or fewer:
 * `999`, `9.99K`, `99.9K`, `999K`, `9.99M`.
 */
const UNITS = ['', 'K', 'M', 'B', 'T', 'Q', 'Qi', 'Sx'] as const;

export function formatCount(count: number): string {
  if (!Number.isFinite(count)) return '?';
  if (Math.abs(count) < 1000) return count.toLocaleString('en-us');

  let value = count;
  let unit = 0;

  while (Math.abs(value) >= 1000 && unit < UNITS.length - 1) {
    value /= 1000;
    unit++;
  }

  // Past the last suffix the number is beyond anything a label can say usefully; the tooltip has
  // the real figure, so this admits defeat rather than printing sixty digits.
  if (Math.abs(value) >= 1000) return '∞';

  const decimals = Math.abs(value) < 10 ? 2 : Math.abs(value) < 100 ? 1 : 0;

  return `${value.toFixed(decimals)}${UNITS[unit]}`;
}

/** The exact count, for a `title` attribute. */
export function exactCount(count: number): string {
  return Number.isFinite(count) ? count.toLocaleString('en-us') : String(count);
}
