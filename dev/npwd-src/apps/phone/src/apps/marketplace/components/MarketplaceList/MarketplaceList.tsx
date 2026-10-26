import React from 'react';
import { List } from '@ui/components/List';
import { useListingValue } from '../../hooks/state';
import { MarketplaceItem } from './MarketplaceItem';
import { EmptyState } from '@ui/components/EmptyState';
import { ShoppingBag } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export const MarketplaceList: React.FC = () => {
  const listings = useListingValue();
  const [t] = useTranslation();

  if (!listings.length) {
    return (
      <EmptyState
        icon={<ShoppingBag size={28} />}
        label={t('MARKETPLACE.NO_LISTINGS')}
        sublabel={t('MARKETPLACE.NO_LISTINGS_SUB')}
      />
    );
  }

  return (
    <List>
      {listings.map((listing) => (
        <MarketplaceItem key={listing.id} {...listing} />
      ))}
    </List>
  );
};
