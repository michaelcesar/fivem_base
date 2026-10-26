// Servidor: dev-only entry point, used by `vite`/`vite preview` for local iteration outside
// the game - the in-game build never loads this. npwd's core imports `./config` (see
// npwd.config.ts) directly instead, which is what actually renders in the phone.
import React from 'react';
import { createRoot } from 'react-dom/client';
import { MemoryRouter } from 'react-router-dom';
import { createTheme } from '@mui/material';
import App from './App';

const root = createRoot(document.getElementById('root')!);
root.render(
  <MemoryRouter>
    <App theme={createTheme({ palette: { mode: 'dark' } })} i18n={{} as any} settings={{} as any} />
  </MemoryRouter>,
);
