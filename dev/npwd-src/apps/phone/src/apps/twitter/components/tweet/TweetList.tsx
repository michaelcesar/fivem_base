import { memo, useCallback, useState } from 'react';
import Tweet from './Tweet';
import { Virtuoso } from 'react-virtuoso';
import { FormattedTweet, GetTweet, TwitterEvents } from '@typings/twitter';

import { ServerPromiseResp } from '@typings/common';
import fetchNui from '@utils/fetchNui';
import { processTweet } from '@apps/twitter/utils/tweets';
import { usePhone } from '@os/phone/hooks';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { useTweetsState } from '@apps/twitter/hooks/state';
import { useTranslation } from 'react-i18next';

export function TweetList({ tweets }: { tweets: FormattedTweet[] }) {
  const { ResourceConfig } = usePhone();
  const { addAlert } = useSnackbar();
  const [t] = useTranslation();
  const TWEET_LIMIT_PER_PAGE = ResourceConfig?.twitter?.resultsLimit || 25;
  const [tweetsData, setTweetsData] = useTweetsState();
  const [hasNextPage, setHasNextPage] = useState(
    tweetsData.length === TWEET_LIMIT_PER_PAGE ? true : false,
  );
  const [page, setPage] = useState(0);
  const [isNextPageLoading, setIsNextPageLoading] = useState(false);

  const handleNewPageLoad = useCallback(() => {
    if (isNextPageLoading || !hasNextPage) return;
    setIsNextPageLoading(true);

    const pageId = page + 1;
    fetchNui<ServerPromiseResp<GetTweet[]>>(TwitterEvents.FETCH_TWEETS, { pageId }).then((resp) => {
      if (resp.status !== 'ok') {
        addAlert({
          message: resp.errorMsg,
          type: 'error',
        });
      } else {
        const newTweets = resp.data?.map(processTweet);
        if (newTweets.length < TWEET_LIMIT_PER_PAGE) {
          setHasNextPage(false);
        }
        setTweetsData([...tweetsData, ...newTweets]);
        setPage(pageId);
      }

      //Maybe a better way to do this?
      //Prevents the "250" rate limit if someone is scrolling too fast
      return setTimeout(() => {
        setIsNextPageLoading(false);
      }, 350);
    });
  }, [addAlert, setTweetsData]);

  const Footer = () => (
    <div className="flex justify-center p-6 text-sm text-neutral-400 dark:text-neutral-500">
      {hasNextPage ? t('TWITTER.LOADING_TWEETS') : t('TWITTER.NOTHING_MORE')}
    </div>
  );

  return (
    <ul className='h-full divide-y divide-blue-200'>
      <Virtuoso
        style={{ height: '100%' }}
        data={tweetsData}
        endReached={handleNewPageLoad}
        overscan={6}
        itemContent={(_, tweet) => {
          return <Tweet key={tweet.id} tweet={tweet} />;
        }}
        components={{ Footer }}
      />
    </ul>
  );
}

export default memo(TweetList); // only re-render if our tweets change
