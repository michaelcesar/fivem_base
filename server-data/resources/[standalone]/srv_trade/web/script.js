/*
  Servidor: the trade screen's behaviour.

  This file draws and nothing else. It never decides whether an offer is allowed, whether a slot
  still holds what it claims, or whether a swap may happen - every one of those is a round trip to
  srv_trade's server.lua, which re-checks from the live inventory. What is drawn here is always the
  last thing the server said, never a local guess about what the server will say next.

  That is why there is no optimistic update anywhere below: a slot dropped into an offer does not
  appear until the server echoes it back. It costs a frame and it removes an entire class of bug
  where the screen and the server disagree about what is on the table.
*/

const RESOURCE = 'srv_trade';

const state = {
  open: false,
  offerSlots: 10,
  inventory: [],
  weight: 0,
  maxWeight: 0,
  mine: {},
  theirs: {},
  iConfirmed: false,
  theyConfirmed: false,
};

const el = (id) => document.getElementById(id);

const post = (name, data) =>
  fetch(`https://${RESOURCE}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data || {}),
  }).catch(() => {});

/* ---------------------------------------------------------------------------------------------
   Drawing
   --------------------------------------------------------------------------------------------- */

/** One slot, built to the same shape ox_inventory's InventorySlot renders. */
function buildSlot(item, { draggable }) {
  const slot = document.createElement('div');
  slot.className = 'inventory-slot';

  if (!item) return slot;

  /* `item.image` arrives as a finished URL. Resolving it here would mean reimplementing
     ox_inventory's rules in a second place, and client.lua already has the data to do it once. */
  slot.style.backgroundImage = `url(${item.image})`;

  if (draggable) {
    slot.className += ' draggable';
    slot.draggable = true;
  }

  const wrapper = document.createElement('div');
  wrapper.className = 'item-slot-wrapper';

  const header = document.createElement('div');
  header.className = 'item-slot-header-wrapper';

  /* Servidor: `en-us` and these exact fraction digits are what ox_inventory formats slot counts and
     weights with. Matched rather than localised: this screen sits next to that one in the player's
     head, and a stack shown as 1.000 here and 1,000 there reads as two different programs. */
  if (item.count > 1) {
    const count = document.createElement('div');
    count.className = 'inventory-slot-number';
    count.textContent = item.count.toLocaleString('en-us');
    header.appendChild(count);
  }

  const info = document.createElement('div');
  info.className = 'item-slot-info-wrapper';

  if (item.weight) {
    const weight = document.createElement('p');
    weight.textContent =
      item.weight >= 1000
        ? `${(item.weight / 1000).toLocaleString('en-us', { minimumFractionDigits: 2 })}kg`
        : `${item.weight.toLocaleString('en-us', { minimumFractionDigits: 0 })}g`;
    info.appendChild(weight);
  }

  const labelBox = document.createElement('div');
  labelBox.className = 'inventory-slot-label-box';

  const label = document.createElement('div');
  label.className = 'inventory-slot-label-text';
  label.textContent = item.label;
  labelBox.appendChild(label);

  wrapper.appendChild(header);
  wrapper.appendChild(info);
  wrapper.appendChild(labelBox);

  slot.appendChild(wrapper);

  return slot;
}

function renderInventory() {
  const grid = el('inventory');
  grid.replaceChildren();

  state.inventory.forEach((item) => {
    const slot = buildSlot(item, { draggable: true });
    slot.addEventListener('dragstart', (event) => {
      event.dataTransfer.setData('text/plain', JSON.stringify({ from: 'inventory', item }));
    });
    grid.appendChild(slot);
  });

  /* The real weight and the real maximum, both from ox_inventory - same header text and same bar as
     the inventory itself, rather than a total carried against a maximum this screen would have had
     to invent. */
  el('inventory-weight').textContent = `${(state.weight / 1000).toFixed(2)}/${(state.maxWeight / 1000).toFixed(2)}kg`;
  el('inventory-bar').className = 'trade-bar-fill';
  el('inventory-bar').style.width = state.maxWeight
    ? `${Math.min(100, (state.weight / state.maxWeight) * 100)}%`
    : '0%';
}

function renderOffer(gridId, offers, { mine }) {
  const grid = el(gridId);
  grid.replaceChildren();

  for (let index = 1; index <= state.offerSlots; index++) {
    const item = offers[String(index)];
    const slot = buildSlot(item, { draggable: false });

    if (mine) {
      slot.addEventListener('dragover', (event) => {
        event.preventDefault();
        slot.classList.add('drop-hover');
      });
      slot.addEventListener('dragleave', () => slot.classList.remove('drop-hover'));
      slot.addEventListener('drop', (event) => {
        event.preventDefault();
        slot.classList.remove('drop-hover');
        handleDrop(index, event);
      });

      /* Taking something back out. A click rather than a drag because there is only one place it
         can go - back to the inventory it never actually left. */
      if (item) {
        slot.style.cursor = 'pointer';
        slot.addEventListener('click', () => post('setOffer', { index, slot: null, count: null }));
      }
    }

    grid.appendChild(slot);
  }
}

function render() {
  renderInventory();
  renderOffer('mine-offer', state.mine, { mine: true });
  renderOffer('theirs-offer', state.theirs, { mine: false });

  el('mine-confirmed').textContent = state.iConfirmed ? 'Confirmado' : 'Aguardando';
  el('mine-confirmed').className = `trade-status${state.iConfirmed ? ' confirmed' : ''}`;
  el('mine-bar').className = `trade-bar-fill${state.iConfirmed ? '' : ' pending'}`;
  el('mine-bar').style.width = state.iConfirmed ? '100%' : '';

  el('theirs-confirmed').textContent = state.theyConfirmed ? 'Confirmado' : 'Aguardando';
  el('theirs-confirmed').className = `trade-status${state.theyConfirmed ? ' confirmed' : ''}`;
  el('theirs-bar').className = `trade-bar-fill${state.theyConfirmed ? '' : ' pending'}`;
  el('theirs-bar').style.width = state.theyConfirmed ? '100%' : '';

  el('confirm').className = `inventory-control-button${state.iConfirmed ? ' active' : ''}`;
  el('confirm').textContent = state.iConfirmed ? 'Confirmado' : 'Confirmar';
}

/* ---------------------------------------------------------------------------------------------
   Dropping an item into my offer
   --------------------------------------------------------------------------------------------- */

let pendingDrop = null;

function handleDrop(index, event) {
  let payload;

  try {
    payload = JSON.parse(event.dataTransfer.getData('text/plain'));
  } catch {
    return;
  }

  if (!payload || payload.from !== 'inventory') return;

  const item = payload.item;

  /* Servidor: shift is read at the DROP, not at the drag start - the player decides they want part
     of a stack while the item is already moving, which is when their hand is on the keyboard. */
  if (event.shiftKey && item.count > 1) {
    pendingDrop = { index, item };
    el('amount-item').textContent = `${item.label} - até ${item.count.toLocaleString('en-us')}.`;
    const input = el('amount-input');
    input.max = item.count;
    input.value = item.count;
    el('amount').classList.remove('hidden');
    input.focus();
    input.select();
    return;
  }

  /* Without shift the whole stack goes on the table, which is ox_inventory's own behaviour for a
     plain drag and the common case in a trade. */
  post('setOffer', { index, slot: item.slot, count: item.count });
}

function closeAmount() {
  pendingDrop = null;
  el('amount').classList.add('hidden');
}

el('amount-confirm').addEventListener('click', () => {
  if (!pendingDrop) return closeAmount();

  const amount = Math.floor(Number(el('amount-input').value));
  const { index, item } = pendingDrop;

  closeAmount();

  if (!Number.isFinite(amount) || amount < 1) return;

  post('setOffer', { index, slot: item.slot, count: Math.min(amount, item.count) });
});

el('amount-cancel').addEventListener('click', closeAmount);

el('amount-input').addEventListener('keydown', (event) => {
  if (event.key === 'Enter') el('amount-confirm').click();
  else if (event.key === 'Escape') closeAmount();
});

/* ---------------------------------------------------------------------------------------------
   Buttons and messages
   --------------------------------------------------------------------------------------------- */

/* Confirming is a toggle: the server clears both confirmations on any change to either offer, so
   the only way to withdraw one without changing anything is to press it again. */
el('confirm').addEventListener('click', () => post('confirm', { confirmed: !state.iConfirmed }));
el('cancel').addEventListener('click', () => post('cancel'));

window.addEventListener('keydown', (event) => {
  if (!state.open) return;

  if (event.key === 'Escape') {
    if (!el('amount').classList.contains('hidden')) return closeAmount();
    post('cancel');
  }
});

window.addEventListener('message', (event) => {
  const data = event.data;

  if (data.action === 'open') {
    state.open = true;
    state.offerSlots = data.offerSlots || 10;
    state.inventory = [];
    state.mine = {};
    state.theirs = {};
    state.iConfirmed = false;
    state.theyConfirmed = false;

    el('theirs-label').textContent = `Oferta de ${data.partner}`;
    el('trade').classList.remove('hidden');
    render();
    return;
  }

  if (data.action === 'update') {
    state.inventory = data.inventory || [];
    state.weight = data.weight || 0;
    state.maxWeight = data.maxWeight || 0;
    state.mine = data.mine || {};
    state.theirs = data.theirs || {};
    state.iConfirmed = data.iConfirmed === true;
    state.theyConfirmed = data.theyConfirmed === true;

    if (data.partner) el('theirs-label').textContent = `Oferta de ${data.partner}`;

    render();
    return;
  }

  if (data.action === 'close') {
    state.open = false;
    closeAmount();
    el('trade').classList.add('hidden');
  }
});
