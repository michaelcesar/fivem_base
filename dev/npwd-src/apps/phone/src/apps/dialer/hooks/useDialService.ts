import { CallEvents, CallHistoryItem } from '@typings/call';
import { IAlert, useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { useTranslation } from 'react-i18next';
import { useNuiEvent } from '@common/hooks/useNuiEvent';
import { dialState, useSetHistory } from './state';
import { useRecoilCallback } from 'recoil';

export const useDialService = () => {
  const { addAlert } = useSnackbar();
  const setHistory = useSetHistory();
  const [t] = useTranslation();

  const handleAddAlert = ({ message, type }: IAlert) => {
    addAlert({
      message: t(`APPS_${message}`),
      type,
    });
  };

  // Server: this used to silently drop the call entirely if the initial history fetch hadn't
  // resolved yet (`state !== 'hasValue'` just returned, never saving) - reported as "made a call,
  // it never showed up in history". Now it always saves, falling back to an empty list instead
  // of the whole current history if that initial fetch is still in flight.
  const saveCall = useRecoilCallback(
    ({ snapshot }) =>
      (callObj: CallHistoryItem) => {
        const loadable = snapshot.getLoadable(dialState.history);
        const curHistory = loadable.state === 'hasValue' ? loadable.contents : [];

        setHistory([callObj, ...curHistory]);
      },
    [],
  );

  useNuiEvent('DIALER', CallEvents.WAS_ACCEPTED, saveCall);
  useNuiEvent('DIALER', CallEvents.WAS_REJECTED, saveCall);
  useNuiEvent('DIALER', CallEvents.SEND_ALERT, handleAddAlert);
};
