import { DragSource, DropTarget } from './dnd';
import { Inventory } from './inventory';
import { Slot } from './slot';

/**
 * Server: a drag that is waiting for the player to say how many.
 *
 * Holding shift used to mean "half the stack", and the amount box beside the grids meant "this
 * many". Both are gone: shift now asks. The action is stored rather than performed, and replayed
 * with an explicit count once the dialog is answered - `kind` says which of the three it was,
 * because moving, buying and crafting take different paths on the way out.
 *
 * The source and target are stored as the drag reported them, NOT as resolved slots. Replaying
 * re-reads both from the store, so an inventory that changed while the dialog was open is seen.
 */
export type PendingAmount = {
  kind: 'move' | 'buy' | 'craft';
  source: DragSource;
  target?: DropTarget;
  max: number;
  label: string;
};

export type State = {
  leftInventory: Inventory;
  rightInventory: Inventory;
  pendingAmount: PendingAmount | null;
  shiftPressed: boolean;
  isBusy: boolean;
  additionalMetadata: Array<{ metadata: string; value: string }>;
  history?: {
    leftInventory: Inventory;
    rightInventory: Inventory;
  };
};
