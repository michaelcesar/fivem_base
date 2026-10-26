import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import TweetList from './tweet/TweetList';
import { NPWDInput } from '@ui/components/Input';
import { EmptyState } from '@ui/components/EmptyState';
import fetchNui from '@utils/fetchNui';
import { Tweet, TwitterEvents } from '@typings/twitter';
import { useFilteredTweets } from '../hooks/state';
import { processTweet } from '../utils/tweets';
import { ServerPromiseResp } from '@typings/common';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { useDebounce } from '@os/phone/hooks/useDebounce';
import { Search } from 'lucide-react';

function TwitterSearch() {
  const [t] = useTranslation();
  const [searchValue, setSearchValue] = useState('');
  const debouncedSearchValue = useDebounce(searchValue, 400);
  const { addAlert } = useSnackbar();

  // a bit weird name convention
  const [tweets, setFilteredTweets] = useFilteredTweets();

  const handleChange = (e) => setSearchValue(e.target.value);

  useEffect(() => {
    const cleanedSearchValue = debouncedSearchValue.trim();
    if (!cleanedSearchValue) {
      setFilteredTweets([]);
      return;
    }

    fetchNui<ServerPromiseResp<Tweet[]>>(TwitterEvents.FETCH_TWEETS_FILTERED, {
      searchValue: cleanedSearchValue,
    }).then((resp) => {
      if (resp.status !== 'ok') {
        return addAlert({
          message: t(resp.errorMsg || ''),
          type: 'error',
        });
      }

      setFilteredTweets(resp.data.map(processTweet));
    });
  }, [debouncedSearchValue]);

  const filteredTweets = tweets || [];

  return (
    <div className="w-full">
      <div className="p-[15px]">
        <div className="flex items-center justify-start space-x-2 rounded-md border bg-neutral-200 px-2 dark:border-neutral-700 dark:bg-neutral-800">
          <Search className="h-5 w-5 dark:text-neutral-400" />
          <NPWDInput
            className="group-focus:ring-2 text-sm"
            onChange={handleChange}
            placeholder={t('TWITTER.SEARCH_TWEETS_PLACEHOLDER')}
            value={searchValue}
          />
        </div>
      </div>
      {filteredTweets.length > 0 ? (
        <TweetList tweets={tweets} />
      ) : (
        <EmptyState
          icon={<Search size={28} />}
          label={t('TWITTER.NO_SEARCH_RESULTS')}
          sublabel={t('TWITTER.NO_SEARCH_RESULTS_SUB')}
        />
      )}
    </div>
  );
}

export default TwitterSearch;
