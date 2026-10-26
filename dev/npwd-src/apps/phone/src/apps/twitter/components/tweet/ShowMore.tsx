import React, { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { NPWDButton } from '@npwd/keyos';
import { MoreVertical, Trash2, Flag, Check } from 'lucide-react';
import { usePhone } from '@os/phone/hooks/usePhone';
import { TwitterEvents } from '@typings/twitter';
import fetchNui from '@utils/fetchNui';
import { ServerPromiseResp } from '@typings/common';
import { useTwitterActions } from '../../hooks/useTwitterActions';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { ContextMenu, IContextMenuOption } from '@ui/components/ContextMenu';

// Server: uses the shared bottom-sheet `ContextMenu` (already proven to stay inside the phone
// via its portal-to-#phone fix) instead of MUI's `Menu`/`Popover`, which never reliably
// positioned itself inside the phone's scaled box no matter how it was configured.
export const ShowMore = ({ id, isReported, isMine }) => {
  const { t } = useTranslation();
  const [menuOpen, setMenuOpen] = useState(false);
  const { ResourceConfig } = usePhone();
  const { addAlert } = useSnackbar();
  const { deleteTweet } = useTwitterActions();

  const allowedToDelete = ResourceConfig?.twitter.allowDeleteTweets && isMine;
  const allowedToReport = ResourceConfig?.twitter.allowReportTweets && !isMine;

  const handleDeleteTweet = () => {
    fetchNui<ServerPromiseResp<void>>(TwitterEvents.DELETE_TWEET, { tweetId: id }).then((resp) => {
      if (resp.status !== 'ok') {
        return addAlert({
          message: t('TWITTER.FEEDBACK.DELETE_TWEET_FAILED'),
          type: 'error',
        });
      }
    });
  };

  const handleReportTweet = () => {
    fetchNui<ServerPromiseResp<void>>(TwitterEvents.REPORT, { tweetId: id }).then((resp) => {
      if (resp.status !== 'ok') {
        return addAlert({
          message: t('TWITTER.FEEDBACK.REPORT_TWEET_FAILED'),
          type: 'error',
        });
      }

      addAlert({
        message: t('TWITTER.FEEDBACK.REPORT_TWEET_SUCCESS'),
        type: 'success',
      });
    });
  };

  const menuOptions: IContextMenuOption[] = useMemo(() => {
    const options: IContextMenuOption[] = [];

    if (allowedToDelete) {
      options.push({
        label: t('GENERIC.DELETE'),
        icon: <Trash2 size={20} />,
        danger: true,
        onClick: handleDeleteTweet,
      });
    }

    if (allowedToReport) {
      options.push(
        isReported
          ? {
              label: t('TWITTER.REPORTED'),
              icon: <Check size={20} />,
              onClick: () => null,
            }
          : {
              label: t('TWITTER.REPORT'),
              icon: <Flag size={20} />,
              onClick: handleReportTweet,
            },
      );
    }

    return options;
  }, [allowedToDelete, allowedToReport, isReported, t]);

  if (!ResourceConfig || menuOptions.length === 0) return null;

  return (
    <>
      <NPWDButton
        size="sm"
        variant="ghost"
        onClick={() => setMenuOpen(true)}
        style={{ marginRight: 15 }}
      >
        <MoreVertical size={20} className="text-sky-400" />
      </NPWDButton>
      <ContextMenu
        open={menuOpen}
        onClose={() => setMenuOpen(false)}
        options={menuOptions}
        settingLabel={t('TWITTER.TWEET_OPTIONS')}
      />
    </>
  );
};

export default ShowMore;
