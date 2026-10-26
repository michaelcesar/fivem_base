import { canStack, findAvailableSlot, getTargetInventory, isSlotWithItem } from '../helpers';
import { validateMove } from '../thunks/validateItems';
import { store } from '../store';
import { DragSource, DropTarget, InventoryType, SlotWithItem } from '../typings';
import { moveSlots, openAmountPrompt, stackSlots, swapSlots } from '../store/inventory';
import { Items } from '../store/items';
import { itemLabel } from '../helpers/itemLabel';

/**
 * @param amount how many to move. Omitted on a real drag: shift then opens the amount dialog and
 * this is called again with the answer. See ADR-105.
 */
export const onDrop = (source: DragSource, target?: DropTarget, amount?: number) => {
  const { inventory: state } = store.getState();

  const { sourceInventory, targetInventory } = getTargetInventory(state, source.inventory, target?.inventory);

  const sourceSlot = sourceInventory.items[source.item.slot - 1] as SlotWithItem;

  const sourceData = Items[sourceSlot.name];

  if (sourceData === undefined) return console.error(`${sourceSlot.name} item data undefined!`);

  // If dragging from container slot
  if (sourceSlot.metadata?.container !== undefined) {
    // Prevent storing container in container
    if (targetInventory.type === InventoryType.CONTAINER)
      return console.log(`Cannot store container ${sourceSlot.name} inside another container`);

    // Prevent dragging of container slot when opened
    if (state.rightInventory.id === sourceSlot.metadata.container)
      return console.log(`Cannot move container ${sourceSlot.name} when opened`);
  }

  const targetSlot = target
    ? targetInventory.items[target.item.slot - 1]
    : findAvailableSlot(sourceSlot, sourceData, targetInventory.items);

  if (targetSlot === undefined) return console.error('Target slot undefined!');

  // If dropping on container slot when opened
  if (targetSlot.metadata?.container !== undefined && state.rightInventory.id === targetSlot.metadata.container)
    return console.log(`Cannot swap item ${sourceSlot.name} with container ${targetSlot.name} when opened`);

  // Server: every guard above has already passed, so the dialog is only ever opened for a move
  // that would have gone through. Asking and then refusing would be worse than not asking.
  if (amount === undefined && state.shiftPressed && sourceSlot.count > 1 && sourceInventory.type !== 'shop') {
    return store.dispatch(
      openAmountPrompt({
        kind: 'move',
        source,
        target,
        max: sourceSlot.count,
        label: itemLabel(sourceSlot),
      })
    );
  }

  // Without shift the whole stack moves. That was already the behaviour whenever the amount box
  // read 0, which was its resting state; ADR-105 made it the only behaviour.
  const count =
    amount === undefined ? sourceSlot.count : Math.min(Math.max(Math.floor(amount), 1), sourceSlot.count);

  const data = {
    fromSlot: sourceSlot,
    toSlot: targetSlot,
    fromType: sourceInventory.type,
    toType: targetInventory.type,
    count: count,
  };

  store.dispatch(
    validateMove({
      ...data,
      fromSlot: sourceSlot.slot,
      toSlot: targetSlot.slot,
    })
  );

  isSlotWithItem(targetSlot, true)
    ? sourceData.stack && canStack(sourceSlot, targetSlot)
      ? store.dispatch(
          stackSlots({
            ...data,
            toSlot: targetSlot,
          })
        )
      : store.dispatch(
          swapSlots({
            ...data,
            toSlot: targetSlot,
          })
        )
    : store.dispatch(moveSlots(data));
};
