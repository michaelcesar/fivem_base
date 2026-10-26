// Servidor: from-scratch replacement for Renewed-Banking's compiled Svelte UI.
// Vanilla JS, no build step - keeps this maintainable without a source we don't have.
// NUI contract (messages in, callbacks out) matches client/main.lua exactly.

const RESOURCE_NAME = 'Renewed-Banking';

const state = {
    accounts: [],
    activeIndex: 0,
    isAtm: false,
    pendingAction: null, // 'deposit' | 'withdraw' | 'transfer'
};

const el = {
    app: document.getElementById('app'),
    accountTabs: document.getElementById('accountTabs'),
    accountName: document.getElementById('accountName'),
    accountType: document.getElementById('accountType'),
    frozenTag: document.getElementById('frozenTag'),
    balanceAmount: document.getElementById('balanceAmount'),
    balanceCash: document.getElementById('balanceCash'),
    atmTag: document.getElementById('atmTag'),
    transList: document.getElementById('transList'),
    transEmpty: document.getElementById('transEmpty'),
    transSearch: document.getElementById('transSearch'),
    closeBtn: document.getElementById('closeBtn'),
    exportBtn: document.getElementById('exportBtn'),
    actionModal: document.getElementById('actionModal'),
    modalTitle: document.getElementById('modalTitle'),
    amountInput: document.getElementById('amountInput'),
    transferGroup: document.getElementById('transferGroup'),
    transferTarget: document.getElementById('transferTarget'),
    commentInput: document.getElementById('commentInput'),
    modalCancel: document.getElementById('modalCancel'),
    modalConfirm: document.getElementById('modalConfirm'),
    loadingOverlay: document.getElementById('loadingOverlay'),
    loadingText: document.getElementById('loadingText'),
};

const LOADING_MESSAGES = [
    'Conectando à agência...',
    'Verificando saldo...',
    'Carregando extrato...',
    'Sincronizando contas...',
];
let loadingMessageTimer = null;

function startLoadingMessages() {
    let i = 0;
    el.loadingText.textContent = LOADING_MESSAGES[0];
    clearInterval(loadingMessageTimer);
    loadingMessageTimer = setInterval(() => {
        i = (i + 1) % LOADING_MESSAGES.length;
        el.loadingText.textContent = LOADING_MESSAGES[i];
    }, 1400);
}

function stopLoadingMessages() {
    clearInterval(loadingMessageTimer);
    loadingMessageTimer = null;
}

function nuiPost(name, data) {
    return fetch(`https://${RESOURCE_NAME}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {}),
    }).then((r) => r.json()).catch(() => null);
}

function formatMoney(amount) {
    const n = Number(amount) || 0;
    return `R$ ${n.toLocaleString('pt-BR')}`;
}

function formatDate(unixSeconds) {
    if (!unixSeconds) return '';
    const d = new Date(unixSeconds * 1000);
    return d.toLocaleString('pt-BR', {
        day: '2-digit', month: '2-digit', year: 'numeric',
        hour: '2-digit', minute: '2-digit',
    });
}

// Servidor: routes through client/main.lua's 'notify' NUI callback, which calls lib.notify -
// the server's standard success/error badge - instead of a custom in-page toast.
function notify(description, type) {
    nuiPost('notify', { description, type });
}

function activeAccount() {
    return state.accounts[state.activeIndex] || null;
}

function renderTabs() {
    el.accountTabs.innerHTML = '';
    state.accounts.forEach((account, index) => {
        const tab = document.createElement('button');
        tab.className = `account-tab${index === state.activeIndex ? ' active' : ''}`;
        tab.textContent = account.name || account.id;
        tab.addEventListener('click', () => {
            state.activeIndex = index;
            renderTabs();
            renderBalance();
            renderTransactions();
        });
        el.accountTabs.appendChild(tab);
    });
}

function renderBalance() {
    const account = activeAccount();
    if (!account) return;

    el.accountName.textContent = account.name || account.id;
    el.accountType.textContent = account.type || '';
    el.balanceAmount.textContent = formatMoney(account.amount);
    el.frozenTag.classList.toggle('hidden', !account.frozen);

    if (typeof account.cash === 'number') {
        el.balanceCash.textContent = `Dinheiro em mãos: ${formatMoney(account.cash)}`;
        el.balanceCash.classList.remove('hidden');
    } else {
        el.balanceCash.classList.add('hidden');
    }

    el.atmTag.classList.toggle('hidden', !state.isAtm);
}

function renderTransactions() {
    const account = activeAccount();
    const search = el.transSearch.value.trim().toLowerCase();
    const transactions = (account && account.transactions) || [];

    const filtered = !search ? transactions : transactions.filter((t) => (
        (t.message || '').toLowerCase().includes(search)
        || (t.trans_id || '').toLowerCase().includes(search)
        || (t.receiver || '').toLowerCase().includes(search)
    ));

    el.transList.innerHTML = '';

    if (filtered.length === 0) {
        el.transList.appendChild(el.transEmpty);
        el.transEmpty.classList.remove('hidden');
        return;
    }

    for (const t of filtered) {
        const isDeposit = t.trans_type === 'deposit';
        const item = document.createElement('div');
        item.className = `trans-item ${isDeposit ? 'deposit' : 'withdraw'}`;

        const icon = document.createElement('div');
        icon.className = 'trans-icon';
        icon.textContent = isDeposit ? '↓' : '↑';

        const info = document.createElement('div');
        info.className = 'trans-info';

        const title = document.createElement('div');
        title.className = 'trans-title';
        title.textContent = t.message || t.title || '';

        const meta = document.createElement('div');
        meta.className = 'trans-meta';
        // Servidor: deposit/withdraw always resolve issuer and receiver to the same person (it's
        // your own account either way) - the arrow only means something for a real transfer
        // between two different people, so only show it when the names actually differ.
        meta.textContent = t.issuer && t.receiver && t.issuer !== t.receiver
            ? `${t.issuer} → ${t.receiver} · ${formatDate(t.time)}`
            : formatDate(t.time);

        info.appendChild(title);
        info.appendChild(meta);

        const amount = document.createElement('div');
        amount.className = 'trans-amount';
        amount.textContent = `${isDeposit ? '+' : '-'} ${formatMoney(t.amount)}`;

        item.appendChild(icon);
        item.appendChild(info);
        item.appendChild(amount);
        el.transList.appendChild(item);
    }
}

function openModal(action) {
    state.pendingAction = action;
    const titles = { deposit: 'Depositar', withdraw: 'Sacar', transfer: 'Transferir' };
    el.modalTitle.textContent = titles[action] || action;
    el.transferGroup.classList.toggle('hidden', action !== 'transfer');
    el.amountInput.value = '';
    el.transferTarget.value = '';
    el.commentInput.value = '';
    el.actionModal.classList.remove('hidden');
    el.amountInput.focus();
}

function closeModal() {
    el.actionModal.classList.add('hidden');
    state.pendingAction = null;
}

async function confirmModal() {
    const action = state.pendingAction;
    if (!action) return;

    const amount = parseInt(el.amountInput.value, 10);
    if (!amount || amount < 1) {
        notify('Informe um valor válido.', 'error');
        return;
    }

    const account = activeAccount();
    const payload = {
        amount,
        comment: el.commentInput.value || '',
        fromAccount: account ? account.id : '',
    };

    if (action === 'transfer') {
        const target = el.transferTarget.value.trim();
        if (!target) {
            notify('Informe a conta ou ID de destino.', 'error');
            return;
        }
        payload.stateid = target;
    }

    el.modalConfirm.disabled = true;
    const result = await nuiPost(action, payload);
    el.modalConfirm.disabled = false;

    if (result) {
        state.accounts = result;
        if (state.activeIndex >= state.accounts.length) state.activeIndex = 0;
        renderTabs();
        renderBalance();
        renderTransactions();
        closeModal();
    }
    // client/main.lua's NUI callback for this action already fires lib.notify on both
    // success and failure (the standard badge) - nothing to show here either way.
}

function closeBank() {
    el.app.classList.add('hidden');
    nuiPost('closeInterface', {});
}

el.closeBtn.addEventListener('click', closeBank);
el.transSearch.addEventListener('input', renderTransactions);
el.modalCancel.addEventListener('click', closeModal);
el.modalConfirm.addEventListener('click', confirmModal);
el.actionModal.addEventListener('click', (event) => {
    if (event.target === el.actionModal) closeModal();
});

document.querySelectorAll('.action-btn').forEach((btn) => {
    btn.addEventListener('click', () => openModal(btn.dataset.action));
});

el.exportBtn.addEventListener('click', () => {
    const account = activeAccount();
    if (!account) return;

    // Servidor: FiveM's NUI is a CEF browser with no OS download manager wired up - a.click()
    // on a blob: URL silently does nothing there, unlike a real Chrome tab (first attempt).
    // navigator.clipboard.writeText() ALSO silently fails there in most FiveM builds - it's
    // gated behind a permissions/focus policy the NUI embed doesn't grant (second attempt,
    // still wrong - failed with no visible error either, since NUI console errors don't reach
    // the server log at all). document.execCommand('copy') on a real, focused, selected
    // <textarea> is the one that actually works inside NUI - it's a direct DOM copy, not the
    // async Clipboard API.
    const text = JSON.stringify(account.transactions || [], null, 2);
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.focus();
    textarea.select();

    let copied = false;
    try {
        copied = document.execCommand('copy');
    } catch (err) {
        copied = false;
    }

    document.body.removeChild(textarea);

    if (copied) {
        notify('Extrato copiado! Cole num bloco de notas ou chat.', 'success');
    } else {
        notify('Não foi possível copiar o extrato.', 'error');
    }
});

document.addEventListener('keydown', (event) => {
    if (event.key !== 'Escape') return;
    if (!el.actionModal.classList.contains('hidden')) {
        closeModal();
        return;
    }
    if (!el.app.classList.contains('hidden')) {
        closeBank();
    }
});

window.addEventListener('message', (event) => {
    const data = event.data || {};

    if (data.action === 'setLoading') {
        el.loadingOverlay.classList.toggle('hidden', !data.status);
        if (data.status) {
            startLoadingMessages();
        } else {
            stopLoadingMessages();
        }
        return;
    }

    if (data.action === 'setVisible') {
        el.loadingOverlay.classList.add('hidden');
        stopLoadingMessages();
        state.accounts = data.accounts || [];
        state.activeIndex = 0;
        state.isAtm = !!data.atm;
        el.app.classList.toggle('hidden', !data.status);
        renderTabs();
        renderBalance();
        renderTransactions();
    }
});
