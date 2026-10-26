import React from 'react';
import TweetList from './TweetList';
import { useTweetsValue } from '../../hooks/state';
import TweetSkeletonList from './TweetSkeletonList';
import { EmptyState } from '@ui/components/EmptyState';
import { MessageSquare } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export function TweetListContainer() {
  const tweets = useTweetsValue();
  const [t] = useTranslation();

  if (!tweets.length) {
    return (
      <EmptyState
        icon={<MessageSquare size={28} />}
        label={t('TWITTER.NO_TWEETS')}
        sublabel={t('TWITTER.NO_TWEETS_SUB')}
      />
    );
  }

  return (
    <React.Suspense fallback={<TweetSkeletonList />}>
      <TweetList tweets={tweets} />
    </React.Suspense>
  );
}

export default TweetListContainer;
