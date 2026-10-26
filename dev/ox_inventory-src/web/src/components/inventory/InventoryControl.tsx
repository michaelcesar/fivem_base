import React, { useState } from 'react';
import UsefulControls from './UsefulControls';

/**
 * Server: what is left of the middle column.
 *
 * It used to hold an amount box and three buttons - Use, Give, Close - and all four were removed by
 * ADR-105, because each had a route the player reaches faster:
 *
 *   - amount box -> shift while dragging, which now asks how many (AmountPrompt)
 *   - Use        -> right-click the slot, "Usar"
 *   - Give       -> `lite_trade`, where both sides see what is on the table
 *   - Close      -> TAB, the key that opened it
 *
 * The component survives because it also owns the "useful controls" help dialog and the button that
 * opens it, which are a different feature that happened to live in the same file.
 */
const InventoryControl: React.FC = () => {
  const [infoVisible, setInfoVisible] = useState(false);

  return (
    <>
      <UsefulControls infoVisible={infoVisible} setInfoVisible={setInfoVisible} />

      <button className="useful-controls-button" onClick={() => setInfoVisible(true)}>
        <svg xmlns="http://www.w3.org/2000/svg" height="2em" viewBox="0 0 524 524">
          <path d="M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zM216 336h24V272H216c-13.3 0-24-10.7-24-24s10.7-24 24-24h48c13.3 0 24 10.7 24 24v88h8c13.3 0 24 10.7 24 24s-10.7 24-24 24H216c-13.3 0-24-10.7-24-24s10.7-24 24-24zm40-208a32 32 0 1 1 0 64 32 32 0 1 1 0-64z" />
        </svg>
      </button>
    </>
  );
};

export default InventoryControl;
