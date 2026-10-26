import { createAppThemeProvider } from '@os/apps/utils/createAppThemeProvider';
import marketplaceTheme from '../marketplace.theme';

// Server: Marketplace was the only app with a `*.theme.ts` and no provider to apply it, so
// every MUI `primary` inside it fell through to the phone-wide palette - a pale blue (#a6d4fa)
// in the dark theme. That is what made the listing action icons read as blue instead of the
// app's own red. Contacts, Messages and Notes all already do exactly this.
export const MarketplaceThemeProvider = createAppThemeProvider(marketplaceTheme);
