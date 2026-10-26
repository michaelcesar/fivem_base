import { amber, common } from '@mui/material/colors';
import { ThemeOptions } from '@mui/material';

// Server: the app carried two different greens - this one (Tailwind green-500), which reached
// only the home-screen icon and MUI's `primary` controls like the conversation checkbox, and
// #25D366, which the whole conversation UI (bubbles, send, record) actually uses. Unified on
// #25D366, the phone's canonical green, so "the Messages green" means one colour.
export const MESSAGES_APP_PRIMARY_COLOR = '#25D366';

// Server: Messages is the one app allowed to break the per-app-brand-colour rule (ADR-033) -
// its "new conversation" button and its conversation selector are blue, by request, rather than
// the green above. This is Tailwind's `sky-500`, the same colour `bg-sky-500` resolves to on
// NewMessageGroupButton, kept here as a constant so the two cannot drift apart.
export const MESSAGES_APP_ACCENT_BLUE = '#0ea5e9';
export const MESSAGES_APP_TEXT_COLOR = common.white;

const theme: ThemeOptions = {
  palette: {
    primary: {
      main: MESSAGES_APP_PRIMARY_COLOR,
      dark: amber[900],
      light: amber[100],
      contrastText: MESSAGES_APP_TEXT_COLOR,
    },
  },
};

export default theme;
