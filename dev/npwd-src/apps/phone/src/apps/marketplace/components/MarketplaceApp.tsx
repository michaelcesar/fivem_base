import React from 'react';
import { AppWrapper } from '@ui/components';
import { AppContent } from '@ui/components/AppContent';
import { MarketplaceListContainer } from './MarketplaceList/MarketplaceListContainer';
import { NavigationBar } from './navigation/NavigationBar';
import { Switch, Route } from 'react-router-dom';
import { ListingFormContainer } from './form/ListingFormContainer';
import { AppTitle } from '@ui/components/AppTitle';
import { useApp } from '@os/apps/hooks/useApps';
import { WordFilterProvider } from '@os/wordfilter/providers/WordFilterProvider';
import { createExternalAppProvider } from '@os/apps/utils/createExternalAppProvider';
import { useTranslation } from 'react-i18next';
import { MarketplaceThemeProvider } from '../providers/MarketplaceThemeProvider';

export const MarketplaceApp: React.FC = () => {
  const marketplaceApp = useApp('MARKETPLACE');
  const Provider = createExternalAppProvider(marketplaceApp);
  const [t] = useTranslation();

  return (
    <Provider>
      <MarketplaceThemeProvider>
        <AppWrapper id="marketplace-app">
          <AppTitle app={marketplaceApp} sublabel={t('MARKETPLACE.SUBLABEL')} />
          <AppContent>
            <WordFilterProvider>
              <Switch>
                <Route path="/marketplace" exact component={MarketplaceListContainer} />
                <Route path="/marketplace/new" component={ListingFormContainer} />
              </Switch>
            </WordFilterProvider>
          </AppContent>
          <NavigationBar />
        </AppWrapper>
      </MarketplaceThemeProvider>
    </Provider>
  );
};
