import React, { useState } from 'react';
import { Add, Delete } from '@mui/icons-material';
import { Fab, CircularProgress } from '@mui/material';
import { useIsEditing } from '../hooks/state';
import fetchNui from '@utils/fetchNui';
import { ServerPromiseResp } from '@typings/common';
import { GalleryPhoto, PhotoEvents } from '@typings/photo';
import { usePhotoActions } from '../hooks/usePhotoActions';
import { useCheckedPhotosValue } from '../hooks/state';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { useTranslation } from 'react-i18next';
import { styled } from '@mui/material/styles';
import { ConfirmDialog } from '@ui/components/ConfirmDialog';
import { CAMERA_APP_PRIMARY_COLOR } from '../camera.theme';

const FloatBtn = styled(Fab)(({ theme }) => ({
  position: 'absolute',
  bottom: theme.spacing(5),
  right: theme.spacing(3),
}));

const NewPhotoButton = () => {
  const [isEditing, setIsEditing] = useIsEditing();
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const checkedPhotos = useCheckedPhotosValue();
  const { takePhoto, deletePhotos } = usePhotoActions();
  const { addAlert } = useSnackbar();
  const [t] = useTranslation();

  const handleTakePhoto = () => {
    setIsLoading(true);
    fetchNui<ServerPromiseResp<GalleryPhoto>>(PhotoEvents.TAKE_PHOTO).then((serverResp) => {
      if (serverResp.status !== 'ok') {
        // We do early returns so we want to unset the loading here
        setIsLoading(false);
        return addAlert({
          message: t(serverResp.errorMsg),
          type: 'error',
        });
      }

      takePhoto(serverResp.data);
      setIsLoading(false);
    });
  };

  const handleDeletePhotos = () => {
    setConfirmOpen(false);
    fetchNui<ServerPromiseResp<number[]>>(PhotoEvents.DELETE_MULTIPLE_PHOTOS, checkedPhotos).then(
      (serverResp) => {
        if (serverResp.status !== 'ok') {
          return addAlert({ message: t('CAMERA.FAILED_TO_DELETE'), type: 'error' });
        }
        deletePhotos(checkedPhotos);
        setIsEditing(false);
      },
    );
  };

  if (isLoading)
    return (
      <FloatBtn disabled={true} sx={{ bgcolor: CAMERA_APP_PRIMARY_COLOR }}>
        <CircularProgress size={24} sx={{ color: '#ffffff' }} />
      </FloatBtn>
    );

  return (
    <>
      {/* Server: the icon used to be painted `palette.primary.main` on a Fab that was also
          `color="primary"` - the same colour on itself, so the "+" was invisible. Camera has no
          theme of its own, so both come from the app's registered colour (grey A400) with the
          white content colour it is registered with, and red while deleting (ADR-034: brand
          colour says which app, red says what the action does). */}
      <FloatBtn
        onClick={!isEditing ? handleTakePhoto : () => setConfirmOpen(true)}
        disabled={isEditing && checkedPhotos.length === 0}
        sx={{
          bgcolor: isEditing ? '#ef4444' : CAMERA_APP_PRIMARY_COLOR,
          color: '#ffffff',
          '&:hover': { bgcolor: isEditing ? '#dc2626' : '#1f1f1f' },
        }}
      >
        {!isEditing ? <Add /> : <Delete />}
      </FloatBtn>
      <ConfirmDialog
        open={confirmOpen}
        title={t('CAMERA.DELETE_PHOTO_CONFIRM_TITLE', { count: checkedPhotos.length })}
        confirmLabel={t('GENERIC.DELETE')}
        cancelLabel={t('GENERIC.CANCEL')}
        onConfirm={handleDeletePhotos}
        onCancel={() => setConfirmOpen(false)}
      />
    </>
  );
};

export default NewPhotoButton;
