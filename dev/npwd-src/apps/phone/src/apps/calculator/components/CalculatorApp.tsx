import React from 'react';
import { AppWrapper } from '@ui/components';
import { AppTitle } from '@ui/components/AppTitle';
import { AppContent } from '@ui/components/AppContent';
import { Calculator } from './Calculator';
import { useApp } from '@os/apps/hooks/useApps';
import { useTranslation } from 'react-i18next';

export const CalculatorApp: React.FC = () => {
  const calculator = useApp('CALCULATOR');
  const [t] = useTranslation();
  return (
    <AppWrapper>
      <AppTitle app={calculator} sublabel={t('CALCULATOR.SUBLABEL')} />
      <AppContent>
        <Calculator />
      </AppContent>
    </AppWrapper>
  );
};
