import { FormattedMatch, FormattedProfile, MatchEvents } from '@typings/match';
import fetchNui from '@utils/fetchNui';
import { ServerPromiseResp } from '@typings/common';
import { matchState, useSetFormattedProfiles, useSetMatches, useSetMatchesError } from './state';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { Snapshot, useRecoilCallback } from 'recoil';
import { isEnvBrowser } from '../../../utils/misc';
import { MockMatchesData } from '../utils/constants';

const getIsMatchesLoading = (snapshot: Snapshot) =>
  snapshot.getLoadable<FormattedProfile[]>(matchState.profiles).state !== 'hasValue';

export const useMatchActions = () => {
  const setProfiles = useSetFormattedProfiles();
  const setMatches = useSetMatches();
  const setMatchesError = useSetMatchesError();
  const { addAlert } = useSnackbar();
  const [t] = useTranslation();

  const setViewed = useCallback(
    (id: number, liked: boolean) => {
      setProfiles((profiles) =>
        profiles.map((profile) => {
          if (id === profile.id) return { ...profile, viewed: true, liked };
          return profile;
        }),
      );

      // we don't want to store profiles you dislike (erp moment)
      if (!liked) return;
      fetchNui<ServerPromiseResp<boolean>>(MatchEvents.SAVE_LIKES, { id, liked }).then((resp) => {
        if (resp.status !== 'ok') {
          return addAlert({
            message: t('MATCH.FEEDBACK.SAVE_LIKES_FAILED'),
            type: 'error',
          });
        }

        // Instead of just fetching the matches again, we might want to first format the profile to a 'Match',then to a 'FormattedMatch'
        // and then just mutate the already existing state of matches?
        // I guess that's for another time :P

        if (resp.data) {
          addAlert({
            message: t('MATCH.FEEDBACK.NEW_LIKE_FOUND'),
            type: 'info',
          });
          fetchNui<ServerPromiseResp<FormattedMatch[]>>(MatchEvents.GET_MATCHES, { page: 0 }).then(
            (resp) => {
              // Without this check a failed refresh writes `undefined` over a list that was
              // loading or already loaded, which the Matches tab renders as its spinner.
              if (resp.status !== 'ok' || !resp.data) return;
              setMatches(resp.data);
            },
          );
        }
      });
    },
    [setProfiles, addAlert, t, setMatches],
  );

  const addMatchAccount = useRecoilCallback(
    ({ snapshot, set }) =>
      async (profile: FormattedProfile, myProfile: FormattedProfile) => {
        if (profile.identifier === myProfile.identifier) return;

        const matchesLoading = getIsMatchesLoading(snapshot);
        if (matchesLoading) return;

        set(matchState.profiles, (curVal) => [profile, ...curVal]);
      },
  );

  const addMatchedAccount = async () => {
    fetchNui<ServerPromiseResp<FormattedMatch[]>>(MatchEvents.GET_MATCHES, { page: 0 }).then(
      (resp) => {
        if (resp.status !== 'ok' || !resp.data) return;
        setMatches(resp.data);
      },
    );
  };

  // Memoised because `MatchList` uses it as an effect dependency - as a plain function it got a
  // new identity on every render, re-firing the effect (and the fetch) in a loop that only ever
  // stopped because the rate limiter rejected the follow-ups.
  const newMatchesPage = useCallback(
    (page: number) => {
      fetchNui<ServerPromiseResp<FormattedMatch[]>>(MatchEvents.GET_MATCHES, { page })
        .then((resp) => {
          // A failed fetch used to return silently here, leaving the list on its loading spinner
          // forever. `errorLoadingMatches` already drives an error message in `MatchList`; it was
          // simply never set by anything.
          if (resp.status !== 'ok' || !resp.data) return setMatchesError(true);

          setMatchesError(false);
          setMatches(resp.data);
        })
        .catch(() => {
          // Outside the game there is no NUI to answer, so keep the browser mock the `matches`
          // atom's own default selector used to provide before this became the single loader.
          if (isEnvBrowser()) {
            setMatchesError(false);
            return setMatches(MockMatchesData);
          }

          setMatchesError(true);
        });
    },
    [setMatches, setMatchesError],
  );

  return {
    setViewed,
    addMatchAccount,
    addMatchedAccount,
    newMatchesPage,
  };
};
