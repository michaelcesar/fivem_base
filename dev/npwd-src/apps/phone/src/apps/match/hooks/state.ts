import { atom, selector, useRecoilState, useRecoilValue, useSetRecoilState } from 'recoil';
import { FormattedMatch, FormattedProfile, MatchEvents } from '@typings/match';
import fetchNui from '@utils/fetchNui';
import { ServerPromiseResp } from '@typings/common';
import LogDebugEvent from '../../../os/debug/LogDebugEvents';
import { isEnvBrowser } from '../../../utils/misc';
import { MockMyProfileData, MockProfilesData } from '../utils/constants';

export const matchState = {
  profiles: atom<FormattedProfile[]>({
    key: 'profiles',
    default: selector({
      key: 'matchDefaultProfiles',
      get: async () => {
        try {
          const resp = await fetchNui<ServerPromiseResp<FormattedProfile[]>>(
            MatchEvents.GET_PROFILES,
          );
          LogDebugEvent({ action: 'fetchProfiles', data: resp.data });
          return resp.data;
        } catch (e) {
          if (isEnvBrowser()) {
            return MockProfilesData;
          }
          console.error(e);
          return [];
        }
      },
    }),
  }),
  errorLoadingProfiles: atom<boolean>({
    key: 'errorLoadingProfiles',
    default: false,
  }),
  // Server: `null` means "not loaded yet", which is what drives the Matches tab's spinner.
  // This atom used to load page 0 itself from an async default selector, but `MatchList` also
  // fetches page 0 on mount, so reading it fired two identical requests milliseconds apart -
  // the rate limiter rejected the second, and on a real failure the selector returned
  // `undefined`, leaving the tab spinning with nothing to report. `MatchList` is the single
  // loader now; see `useMatchActions.newMatchesPage`.
  matches: atom<FormattedMatch[] | null>({
    key: 'matches',
    default: null,
  }),
  errorLoadingMatches: atom<boolean>({
    key: 'errorLoadingMatches',
    default: false,
  }),
  myProfile: atom<FormattedProfile | null>({
    key: 'myProfile',
    default: selector({
      key: 'myProfileDefault',
      get: async () => {
        try {
          const resp = await fetchNui<ServerPromiseResp<FormattedProfile>>(
            MatchEvents.GET_MY_PROFILE,
          );
          LogDebugEvent({ action: 'fetchMyProfile', data: resp.data });
          return resp.data;
        } catch (e) {
          if (isEnvBrowser()) {
            return MockMyProfileData;
          }
          console.error(e);
          return null;
        }
      },
    }),
  }),
  noProfileExists: atom<boolean>({
    key: 'noProfileExists',
    default: false,
  }),
};

export const useFormattedProfiles = () => useRecoilState(matchState.profiles);
export const useFormattedProfilesValue = () => useRecoilValue(matchState.profiles);
export const useSetFormattedProfiles = () => useSetRecoilState(matchState.profiles);

export const useMyProfile = () => useRecoilState(matchState.myProfile);
export const useMyProfileValue = () => useRecoilValue(matchState.myProfile);
export const useSetMyProfile = () => useSetRecoilState(matchState.myProfile);

export const useProfileExistsValue = () => useRecoilValue(matchState.noProfileExists);
export const useProfileExists = () => useRecoilState(matchState.noProfileExists);

export const useSetMatchesError = () => useSetRecoilState(matchState.errorLoadingMatches);

export const useFormattedMatches = () => useRecoilState(matchState.matches);
export const useMatchesValue = () => useRecoilValue(matchState.matches);
export const useSetMatches = () => useSetRecoilState(matchState.matches);
