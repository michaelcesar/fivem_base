import { Slot } from '../typings';
import { fetchNui } from '../utils/fetchNui';

/**
 * Server: one at a time, always.
 *
 * This used to read the amount box, which ADR-105 removed. It is left at one rather than wired to
 * the amount dialog because giving is a click, not a drag - there is no shift to read - and because
 * handing over a quantity is what `lite_trade` is for, where both sides see what is on the table.
 * The server clamps a missing count to 1 anyway (modules/inventory/server.lua).
 */
export const onGive = (item: Slot) => {
  fetchNui('giveItem', { slot: item.slot, count: 1 });
};
