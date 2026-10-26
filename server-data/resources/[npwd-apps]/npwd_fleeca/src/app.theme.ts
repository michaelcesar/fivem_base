import { common } from '@mui/material/colors';
import { ThemeOptions } from '@mui/material';

// Servidor: matches Renewed-Banking's own bank.css --green/--green-dark/--red/--red-dark,
// so the phone app and the in-world ATM/teller UI read as the same product.
export const FLEECA_GREEN = '#16a84f';
export const FLEECA_GREEN_DARK = '#0d7a38';
export const FLEECA_RED = '#d64545';
export const FLEECA_RED_DARK = '#a3312f';

export const LIGHT_APP_TEXT_COLOR = common.white;
export const DARK_APP_TEXT_COLOR = common.black;

export const lightTheme: ThemeOptions = {
  palette: {
    mode: 'light',
    primary: {
      main: FLEECA_GREEN,
      dark: FLEECA_GREEN_DARK,
      light: '#4cc27a',
      contrastText: LIGHT_APP_TEXT_COLOR,
    },
    secondary: {
      main: FLEECA_RED,
      light: '#e37373',
      dark: FLEECA_RED_DARK,
      contrastText: LIGHT_APP_TEXT_COLOR,
    },
  },
};

export const darkTheme: ThemeOptions = {
  palette: {
    mode: 'dark',
    primary: {
      main: FLEECA_GREEN,
      dark: FLEECA_GREEN_DARK,
      light: '#4cc27a',
      contrastText: DARK_APP_TEXT_COLOR,
    },
    secondary: {
      main: FLEECA_RED,
      light: '#e37373',
      dark: FLEECA_RED_DARK,
      contrastText: DARK_APP_TEXT_COLOR,
    },
  },
};

export const themes: Record<'dark' | 'light', ThemeOptions> = {
  light: lightTheme,
  dark: darkTheme,
};
