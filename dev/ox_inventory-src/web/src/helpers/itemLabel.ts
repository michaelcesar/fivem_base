import { Items } from '../store/items';
import { SlotWithItem } from '../typings';

/**
 * Server: the name a player sees for a slot, resolved the same way InventorySlot resolves it -
 * the metadata label wins, then the item's own label, then the raw item name.
 *
 * Pulled out of the slot component because the amount dialog names the item it is asking about,
 * and two copies of this expression would eventually disagree. See ADR-105.
 */
export const itemLabel = (item: Pick<SlotWithItem, 'name' | 'metadata'>) =>
  item.metadata?.label || Items[item.name]?.label || item.name;
