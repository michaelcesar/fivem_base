import { ThemeOptions } from '@mui/material';

// Configure all of the phone's default themes here.
// Server: every app on the phone (and the rest of the server's UI) uses Geist Variable - see
// main.css and tailwind.config.js. MUI components read typography.fontFamily from the theme,
// not the plain CSS `body` rule, so both themes must set it explicitly or MUI falls back to its
// own default (Roboto) or, in the light theme's case, an unrelated Segoe UI/Arial stack.
const FONT_FAMILY = "'Geist Variable', sans-serif";

export const PhoneThemes: Record<string, ThemeOptions> = {
  'taso-dark': {
    typography: {
      fontFamily: FONT_FAMILY,
    },
    components: {
      MuiDivider: {
        styleOverrides: {
          root: {
            borderColor: 'rgba(255, 255, 255, 0.12)',
          },
        },
      },
    },
    palette: {
      mode: 'dark',
      primary: {
        main: '#a6d4fa',
      },
      text: {
        primary: 'rgba(255, 255, 255, 0.9)',
        secondary: 'rgba(200, 200, 200, 0.9)',
        disabled: 'rgba(200, 200, 200, 0.5)',
      },
    },
  },
  'default-light': {
    typography: {
      fontFamily: FONT_FAMILY,
    },
    palette: {
      mode: 'light',
      primary: {
        main: '#607D8B',
      },
      text: {
        primary: 'rgba(0, 0, 0, 0.9)',
        secondary: 'rgba(20, 20, 20, 0.9)',
        disabled: 'rgba(20, 20, 20, 0.5)',
      },
    },
  },
};
