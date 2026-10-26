import { isSlotWithItem } from '../helpers';
import { store } from '../store';
import { DragSource, DropTarget } from '../typings';
import { Items } from '../store/items';
import { buyItem } from '../thunks/buyItem';
import { openAmountPrompt } from '../store/inventory';
import { itemLabel } from '../helpers/itemLabel';

/**
 * @param amount how many to buy. Omitted on a real drag: shift then opens the amount dialog and
 * this is called again with the answer. See ADR-105.
 */
export const onBuy = (source: DragSource, target: DropTarget, amount?: number) => {
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

  // Server: `sourceSlot.count` is the shop's stock, and a shop with unlimited stock reports it as
  // undefined - there is nothing to cap against, so the dialog is opened without a maximum.
  if (amount === undefined && state.shiftPressed && sourceSlot.count !== 1) {
    return store.dispatch(
      openAmountPrompt({
        kind: 'buy',
        source,
        target,
        max: sourceSlot.count || 0,
        label: itemLabel(sourceSlot),
      })
    );
  }

  // One per drag without shift. Buying a stack by accident costs money, so this default is
  // deliberately the opposite of the move default.
  const count =
    amount === undefined
      ? 1
      : sourceSlot.count
        ? Math.min(Math.max(Math.floor(amount), 1), sourceSlot.count)
        : Math.max(Math.floor(amount), 1);

  const data = {
    fromSlot: sourceSlot,
    toSlot: targetSlot,
    fromType: sourceInventory.type,
    toType: targetInventory.type,
    count: count,
  };

  store.dispatch(
    buyItem({
      ...data,
      fromSlot: sourceSlot.slot,
      toSlot: targetSlot.slot,
    })
  );
};
