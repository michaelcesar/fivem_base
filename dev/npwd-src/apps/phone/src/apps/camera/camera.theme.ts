import { common, grey } from '@mui/material/colors';

// Server: Camera was the only app whose registered colours were written inline in
// os/apps/config/apps.tsx instead of living in a `*.theme.ts` like every other app. Extracted so
// the app's own components can reference the same constant the home-screen icon uses, rather
// than each guessing a shade (ADR-034).
export const CAMERA_APP_PRIMARY_COLOR = grey['A400'];
export const CAMERA_APP_TEXT_COLOR = common.white;
