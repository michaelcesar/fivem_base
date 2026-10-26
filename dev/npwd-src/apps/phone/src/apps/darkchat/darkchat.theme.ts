import { grey, common, green } from '@mui/material/colors';
import { ThemeOptions } from '@mui/material';

export const DARKCHAT_APP_PRIMARY_COLOR = grey[900];
export const DARKCHAT_APP_TEXT_COLOR = common.white;
export const DARKCHAT_APP_SECONDARY_COLOR = green[500];

// Server: DeepWeb reuses Messages' layout (row list with dividers, bubbles with a tail, a flat
// header and input bar sharing one surface colour) but never its light palette - this app is
// always near-black regardless of the phone's theme, which is the whole point of it. These are
// the four surfaces that layout needs.
export const DEEPWEB_BACKGROUND = '#0A0A0A';
export const DEEPWEB_SURFACE = '#161616';
export const DEEPWEB_BUBBLE_THEIRS = '#1E1E1E';
export const DEEPWEB_BUBBLE_MINE = '#12351F';

const theme: ThemeOptions = {
  palette: {
    primary: {
      main: DARKCHAT_APP_PRIMARY_COLOR,
      dark: grey[900],
      light: grey[100],
      contrastText: DARKCHAT_APP_TEXT_COLOR,
    },
    secondary: {
      main: DARKCHAT_APP_SECONDARY_COLOR,
    },
  },
};

export default theme;
