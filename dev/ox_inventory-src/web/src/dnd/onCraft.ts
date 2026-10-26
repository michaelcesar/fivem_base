import { store } from '../store';
import { DragSource, DropTarget } from '../typings';
import { isSlotWithItem } from '../helpers';
import { Items } from '../store/items';
import { craftItem } from '../thunks/craftItem';
import { openAmountPrompt } from '../store/inventory';
import { itemLabel } from '../helpers/itemLabel';

/**
 * @param amount how many to craft. Omitted on a real drag: shift then opens the amount dialog and
 * this is called again with the answer. See ADR-105.
 */
export const onCraft = (source: DragSource, target: DropTarget, amount?: number) => {
  const { inventory: state } = store.getState();

  const sourceInventory = state.rightInventory;
  const targetInventory = state.leftInventory;

  const sourceSlot = sourceInventory.items[source.item.slot - 1];

  if (!isSlotWithItem(sourceSlot)) throw new Error(`Item ${sourceSlot.slot} name === undefined`);

  if (sourceSlot.count === 0) return;

  const sourceData = Items[sourceSlot.name];

  if (sourceData === undefined) return console.error(`Item ${sourceSlot.name} data undefined!`);

  const targetSlot = targetInventory.items[target.item.slot - 1];

  if (targetSlot === undefined) return console.error(`Target slot undefined`);

  // Server: crafting has no stock to cap against - the limit is the ingredients, and the server
  // is the only thing that knows whether they are there. The dialog opens without a maximum and the
  // server refuses what cannot be made.
  if (amount === undefined && state.shiftPressed) {
    return store.dispatch(
      openAmountPrompt({ kind: 'craft', source, target, max: 0, label: itemLabel(sourceSlot) })
    );
  }

  const count = amount === undefined ? 1 : Math.max(Math.floor(amount), 1);

  const data = {
    fromSlot: sourceSlot,
    toSlot: targetSlot,
    fromType: sourceInventory.type,
    toType: targetInventory.type,
    count,
  };

  store.dispatch(
    craftItem({
      ...data,
      fromSlot: sourceSlot.slot,
      toSlot: targetSlot.slot,
    })
  );
};
