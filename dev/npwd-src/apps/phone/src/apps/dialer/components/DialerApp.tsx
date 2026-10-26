import React from 'react';
import { AppWrapper } from '@ui/components';
import { AppTitle } from '@ui/components/AppTitle';
import { AppContent } from '@ui/components/AppContent';
import { DialerHistory } from './views/DialerHistory';
import { Switch, Route, useLocation } from 'react-router-dom';
import DialPage from './views/DialPage';
import DialerNavBar from './DialerNavBar';
import { ContactList } from '../../contacts/components/List/ContactList';
import { DialerThemeProvider } from '../providers/DialerThemeProvider';
import { LoadingSpinner } from '@ui/components/LoadingSpinner';
import InjectDebugData from "@os/debug/InjectDebugData";
import { useApp } from '@os/apps/hooks/useApps';
import { useTranslation } from 'react-i18next';
import { useDialHistory } from '../hooks/useDialHistory';

export const DialerApp: React.FC = () => {
  const dialerApp = useApp('DIALER');
  const { pathname } = useLocation();
  const [t] = useTranslation();
  const calls = useDialHistory();

  return (
    <DialerThemeProvider>
      <AppWrapper>
        {pathname === '/phone' && (
          <AppTitle app={dialerApp} sublabel={t('DIALER.SUBLABEL', { count: calls?.length ?? 0 })} />
        )}
        <AppContent>
          <Switch>
            <Route path="/phone/dial">
              <DialPage />
            </Route>
            <Route exact path="/phone">
              <React.Suspense fallback={<LoadingSpinner />}>
                <DialerHistory />
              </React.Suspense>
            </Route>
            <React.Suspense fallback={<LoadingSpinner />}>
              <Route path="/phone/contacts" component={ContactList} />
            </React.Suspense>
          </Switch>
        </AppContent>
        <DialerNavBar />
      </AppWrapper>
    </DialerThemeProvider>
  );
};