import React, { useEffect, useRef, useState } from 'react';
import { useAppDispatch, useAppSelector } from '../../store';
import { closeAmountPrompt, selectPendingAmount } from '../../store/inventory';
import { onDrop } from '../../dnd/onDrop';
import { onBuy } from '../../dnd/onBuy';
import { onCraft } from '../../dnd/onCraft';
import { DropTarget } from '../../typings';

/**
 * Server: asks how many, after a shift-drag.
 *
 * It replaces two things at once: the amount box that used to sit between the grids, and shift
 * meaning "half the stack". Both were guesses about intent; this asks. See ADR-105.
 *
 * The dialog owns the pending action but never performs it - it calls the same onDrop / onBuy /
 * onCraft the drag called, with an explicit count, so every guard those run is run again against
 * whatever the inventory looks like now rather than what it looked like when the drag ended.
 */
const AmountPrompt: React.FC = () => {
  const pending = useAppSelector(selectPendingAmount);
  const dispatch = useAppDispatch();
  const [value, setValue] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (!pending) return;

    // A capped action opens on its maximum, an uncapped one on 1. Selected, so typing replaces it.
    setValue(String(pending.max > 0 ? pending.max : 1));

    const focus = window.setTimeout(() => inputRef.current?.select(), 0);
    return () => window.clearTimeout(focus);
  }, [pending]);

  useEffect(() => {
    if (!pending) return;

    // Server: Escape closes the whole inventory - useExitListener listens for it on window, and it
    // would fire straight through this dialog. Swallowed in the capture phase so Escape means
    // "cancel the question" while the question is up, and "close the inventory" otherwise.
    const swallow = (event: KeyboardEvent) => {
      if (event.code !== 'Escape') return;
      event.stopPropagation();
      dispatch(closeAmountPrompt());
    };

    window.addEventListener('keyup', swallow, true);
    window.addEventListener('keydown', swallow, true);

    return () => {
      window.removeEventListener('keyup', swallow, true);
      window.removeEventListener('keydown', swallow, true);
    };
  }, [pending, dispatch]);

  if (!pending) return null;

  const confirm = () => {
    const amount = Math.floor(Number(value));
    const { kind, source, target, max } = pending;

    dispatch(closeAmountPrompt());

    if (!Number.isFinite(amount) || amount < 1) return;

    const count = max > 0 ? Math.min(amount, max) : amount;

    if (kind === 'move') return onDrop(source, target, count);
    if (kind === 'buy') return onBuy(source, target as DropTarget, count);

    onCraft(source, target as DropTarget, count);
  };

  return (
    <div className="amount-prompt-overlay" onMouseDown={() => dispatch(closeAmountPrompt())}>
      <div className="amount-prompt-dialog" onMouseDown={(event) => event.stopPropagation()}>
        <div className="amount-prompt-title">
          {/*
            A hash, which is what this project already uses for "how many" - the give-money dialog
            in `lite_interactions` asks with `icon = 'hashtag'`. Drawn as four strokes rather than
            pasted as a Font Awesome path: this app loads no icon font, and a path string copied
            wrong renders nothing at all with no error to notice.
          */}
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
          >
            <line x1="9" y1="3" x2="7" y2="21" />
            <line x1="17" y1="3" x2="15" y2="21" />
            <line x1="3" y1="9" x2="21" y2="9" />
            <line x1="2" y1="15" x2="20" y2="15" />
          </svg>
          <p>Quantidade</p>
        </div>
        <p className="amount-prompt-item">
          {pending.max > 0 ? `${pending.label} - até ${pending.max.toLocaleString('en-us')}.` : `${pending.label}.`}
        </p>
        <input
          ref={inputRef}
          className="amount-prompt-input"
          type="number"
          min={1}
          max={pending.max > 0 ? pending.max : undefined}
          value={value}
          onChange={(event) => setValue(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === 'Enter') confirm();
          }}
          autoFocus
        />
        <div className="amount-prompt-buttons">
          <button className="amount-prompt-button" onClick={confirm}>
            Confirmar
          </button>
          <button className="amount-prompt-button" onClick={() => dispatch(closeAmountPrompt())}>
            Cancelar
          </button>
        </div>
      </div>
    </div>
  );
};

export default AmountPrompt;
