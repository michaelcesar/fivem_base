import React from 'react';
import makeStyles from '@mui/styles/makeStyles';
import { Box } from '@mui/material';
import Loader from '../Loader';
import ProfileForm from '../profile/ProfileForm';
import { useProfile } from '../../hooks/useProfile';

const useStyles = makeStyles({
  root: {
    height: '100%',
    width: '100%',
  },
});

function ProfileEditor() {
  const { profile, noProfileExists } = useProfile();
  const classes = useStyles();

  if (!profile && !noProfileExists) return <Loader />;

  return (
    <Box className={classes.root}>
      <ProfileForm profile={profile} />
    </Box>
  );
}

export default ProfileEditor;
