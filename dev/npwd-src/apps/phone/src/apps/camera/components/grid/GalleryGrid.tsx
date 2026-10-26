import React from 'react';
import { Box, Checkbox, IconButton } from '@mui/material';
import useStyles from './grid.styles';
import { useHistory } from 'react-router-dom';
import { useQueryParams } from '@common/hooks/useQueryParams';
import { addQueryToLocation } from '@common/utils/addQueryToLocation';
import { getLocationFromUrl } from '@common/utils/getLocationFromUrl';
import { usePhotosValue, useIsEditing, useCheckedPhotos } from '../../hooks/state';
import EditIcon from '@mui/icons-material/Edit';
import { EmptyState } from '@ui/components/EmptyState';
import { Camera } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export const GalleryGrid = () => {
  const classes = useStyles();
  const history = useHistory();
  const query = useQueryParams();
  const photos = usePhotosValue();
  const [isEditing, setIsEditing] = useIsEditing();
  const [checkedPhotos, setCheckedPhotos] = useCheckedPhotos();
  const [t] = useTranslation();

  const referal = query.referal ? decodeURIComponent(query.referal) : '/camera/image';

  const handlePhotoOpen = (photo) => {
    history.push(addQueryToLocation(getLocationFromUrl(referal), 'image', photo.image));
  };

  const toggleEdit = () => {
    setIsEditing((prev) => !prev);
  };

  const toggleCheck = (photoId: number) => {
    const currentIndex = checkedPhotos.indexOf(photoId);
    const newChecked = [...checkedPhotos];

    if (currentIndex === -1) {
      newChecked.push(photoId);
    } else {
      newChecked.splice(currentIndex, 1);
    }

    setCheckedPhotos(newChecked);
  };

  if (!photos.length) {
    return (
      <EmptyState
        icon={<Camera size={28} />}
        label={t('CAMERA.NO_PHOTOS')}
        sublabel={t('CAMERA.NO_PHOTOS_SUB')}
      />
    );
  }

  return (
    <div>
      <Box display="flex" flexWrap="wrap" alignContent="flex-start" className={classes.root}>
        {!!photos.length && (
          <Box position="absolute" top={10} right={3}>
            <IconButton onClick={toggleEdit}>
              <EditIcon />
            </IconButton>
          </Box>
        )}
        {photos.map((photo) => {
          return isEditing ? (
            <Box key={photo.id}>
              <div
                style={{ backgroundImage: `url(${photo.image})` }}
                className={classes.photo}
                onClick={() => toggleCheck(photo.id)}
              >
                <Checkbox checked={checkedPhotos.indexOf(photo.id) !== -1} />
              </div>
            </Box>
          ) : (
            <Box key={photo.id} onClick={() => handlePhotoOpen(photo)}>
              <div style={{ backgroundImage: `url(${photo.image})` }} className={classes.photo} />
            </Box>
          );
        })}
      </Box>
    </div>
  );
};
