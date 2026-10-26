import { Box, Button } from '@mui/material';
import { Theme } from '@mui/material/styles';
import makeStyles from '@mui/styles/makeStyles';
import React, { useState } from 'react';
import { MarketplaceEvents, MarketplaceListing } from '@typings/marketplace';
import DeleteIcon from '@mui/icons-material/Delete';
import ReportIcon from '@mui/icons-material/Report';
import ChatIcon from '@mui/icons-material/Chat';
import PhoneIcon from '@mui/icons-material/Phone';
import { useTranslation } from 'react-i18next';
import { useHistory } from 'react-router-dom';
import fetchNui from '../../../../utils/fetchNui';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { ServerPromiseResp } from '@typings/common';
import { useMyPhoneNumber } from '@os/simcard/hooks/useMyPhoneNumber';
import { useCall } from '@os/call/hooks/useCall';
import { Tooltip } from '@ui/components/Tooltip';
import { ConfirmDialog } from '@ui/components/ConfirmDialog';

const useStyles = makeStyles((theme: Theme) => ({
  icon: {
    color: theme.palette.primary.main,
  },
}));

export const ListingActions: React.FC<MarketplaceListing> = ({ children, ...listing }) => {
  const classes = useStyles();
  const myNumber = useMyPhoneNumber();
  const [t] = useTranslation();
  const history = useHistory();
  const { initializeCall } = useCall();
  const { addAlert } = useSnackbar();
  const [confirmDeleteOpen, setConfirmDeleteOpen] = useState(false);
  const [confirmReportOpen, setConfirmReportOpen] = useState(false);

  const handleDeleteListing = () => {
    fetchNui<ServerPromiseResp>(MarketplaceEvents.DELETE_LISTING, {
      id: listing.id,
    }).then((resp) => {
      setConfirmDeleteOpen(false);

      if (resp.status !== 'ok') {
        return addAlert({
          message: t('MARKETPLACE.FEEDBACK.DELETE_LISTING_FAILED'),
          type: 'error',
        });
      }

      addAlert({
        message: t('MARKETPLACE.FEEDBACK.DELETE_LISTING_SUCCESS'),
        type: 'success',
      });
    });
  };

  const handleReportListing = () => {
    fetchNui<ServerPromiseResp>(MarketplaceEvents.REPORT_LISTING, {
      id: listing.id,
    }).then((resp) => {
      setConfirmReportOpen(false);

      if (resp.status !== 'ok') {
        return addAlert({
          message: t('MARKETPLACE.FEEDBACK.REPORT_LISTING_FAILED'),
          type: 'error',
        });
      }

      addAlert({
        message: t('MARKETPLACE.FEEDBACK.REPORT_LISTING_SUCCESS'),
        type: 'success',
      });
    });
  };

  const handleCall = () => {
    initializeCall(listing.number);
  };

  const handleMessage = () => {
    history.push(`/messages/new?phoneNumber=${listing.number}`);
  };

  return (
    <Box justifyContent="space-between" alignItems="center">
      <div style={{ float: 'left' }}>
        {listing.number !== myNumber && (
          <>
            <Tooltip title={t('GENERIC.MESSAGE')}>
              <Button onClick={handleMessage}>
                <ChatIcon className={classes.icon} />
              </Button>
            </Tooltip>
            <Tooltip title={`${t('GENERIC.CALL')}: ${listing.number}`}>
              <Button onClick={handleCall}>
                <PhoneIcon className={classes.icon} />
              </Button>
            </Tooltip>
          </>
        )}
      </div>

      <div style={{ float: 'right' }}>
        {listing.number === myNumber ? (
          <Tooltip title={t('GENERIC.DELETE')}>
            <Button onClick={() => setConfirmDeleteOpen(true)}>
              <DeleteIcon />
            </Button>
          </Tooltip>
        ) : (
          <Tooltip title={t('GENERIC.REPORT')}>
            <Button onClick={() => setConfirmReportOpen(true)}>
              <ReportIcon />
            </Button>
          </Tooltip>
        )}
      </div>

      <ConfirmDialog
        open={confirmDeleteOpen}
        title={t('MARKETPLACE.DELETE_LISTING_CONFIRM_TITLE')}
        description={t('MARKETPLACE.DELETE_LISTING_CONFIRM_DESC')}
        confirmLabel={t('GENERIC.DELETE')}
        cancelLabel={t('GENERIC.CANCEL')}
        onConfirm={handleDeleteListing}
        onCancel={() => setConfirmDeleteOpen(false)}
      />
      <ConfirmDialog
        open={confirmReportOpen}
        title={t('MARKETPLACE.REPORT_LISTING_CONFIRM_TITLE')}
        confirmLabel={t('GENERIC.REPORT')}
        cancelLabel={t('GENERIC.CANCEL')}
        onConfirm={handleReportListing}
        onCancel={() => setConfirmReportOpen(false)}
      />
    </Box>
  );
};
