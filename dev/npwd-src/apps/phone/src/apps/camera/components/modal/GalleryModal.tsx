import React, { useMemo, useState, useCallback } from 'react';
import useStyles from './modal.styles';
import { Button, Paper } from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import DeleteIcon from '@mui/icons-material/Delete';
import ShareIcon from '@mui/icons-material/Share';
import { useHistory } from 'react-router-dom';
import { useQueryParams } from '@common/hooks/useQueryParams';
import { ShareModal } from './ShareModal';
import { GalleryPhoto, PhotoEvents } from '@typings/photo';
import { usePhotoActions } from '../../hooks/usePhotoActions';
import fetchNui from '@utils/fetchNui';
import { ServerPromiseResp } from '@typings/common';
import { useTranslation } from 'react-i18next';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { ConfirmDialog } from '@ui/components/ConfirmDialog';

export const GalleryModal = () => {
  const [shareOpen, setShareOpen] = useState(null);
  const [confirmOpen, setConfirmOpen] = useState(false);

  const classes = useStyles();
  const history = useHistory();
  const query = useQueryParams();
  const { deletePhoto } = usePhotoActions();
  const { addAlert } = useSnackbar();
  const [t] = useTranslation();

  const referal = query.referal || '/camera';

  const meta: GalleryPhoto = useMemo(
    () => ({ id: parseInt(query.id), image: query.image as string }),
    [query],
  );

  const _handleClose = () => {
    history.push(referal);
  };

  const handleDeletePhoto = () => {
    setConfirmOpen(false);
    fetchNui<ServerPromiseResp<GalleryPhoto>>(PhotoEvents.DELETE_PHOTO, {
      image: meta.image,
    }).then((serverResp) => {
      if (serverResp.status !== 'ok') {
        return addAlert({ message: t('CAMERA.FAILED_TO_DELETE'), type: 'error' });
      }

      deletePhoto(meta.image);

      history.push(referal);
    });
  };

  const handleSharePhoto = useCallback(() => {
    setShareOpen(meta);
  }, [meta]);

  if (!meta) return null;

  return (
    <>
      <ShareModal referal={referal} meta={shareOpen} onClose={() => setShareOpen(null)} />
      {/* Server: elevation={0}. MUI Paper's default drop shadow drew a line across the top of
          the photo view, reading as a stray border above the back-arrow row - the same cause as
          the unwanted line under the dialler's number field. */}
      <Paper square elevation={0} className={classes.modal}>
        <div className={shareOpen ? classes.backgroundModal : null} />
        <Button onClick={_handleClose}>
          <ArrowBackIcon />
        </Button>
        <div className={classes.image} style={{ backgroundImage: `url(${meta.image})` }} />
        <div className={classes.actionDiv}>
          <Button onClick={() => setConfirmOpen(true)}>
            <DeleteIcon fontSize="large" className="text-red-500" />
          </Button>
          <Button onClick={handleSharePhoto}>
            <ShareIcon fontSize="large" />
          </Button>
        </div>
      </Paper>
      <ConfirmDialog
        open={confirmOpen}
        title={t('CAMERA.DELETE_PHOTO_CONFIRM_TITLE', { count: 1 })}
        confirmLabel={t('GENERIC.DELETE')}
        cancelLabel={t('GENERIC.CANCEL')}
        onConfirm={handleDeletePhoto}
        onCancel={() => setConfirmOpen(false)}
      />
    </>
  );
};
