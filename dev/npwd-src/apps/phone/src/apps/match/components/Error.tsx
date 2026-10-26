import React from 'react';
import { useTranslation } from 'react-i18next';
import { EmptyState } from '@ui/components/EmptyState';
import { Heart } from 'lucide-react';

function NoProfiles() {
  const [t] = useTranslation();
  return (
    <EmptyState
      icon={<Heart size={28} />}
      label={t('MATCH.FEEDBACK.NO_PROFILES')}
      sublabel={t('MATCH.FEEDBACK.NO_PROFILES_SUB')}
    />
  );
}

export default NoProfiles;
