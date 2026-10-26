import React, { useEffect, useState } from 'react';
import { Paper } from '@mui/material';
import makeStyles from '@mui/styles/makeStyles';
import { useTranslation } from 'react-i18next';

import { useProfiles } from '../../hooks/useProfiles';
import Loader from '../Loader';
import PageText from '../PageText';
import ActiveProfile from '../ActiveProfile';
import { useMatchActions } from '../../hooks/useMatchActions';
import { EmptyState } from '@ui/components/EmptyState';
import { UserRound } from 'lucide-react';

const useStyles = makeStyles({
  root: {
    height: '100%',
    width: '100%',
    overflow: 'hidden',
  },
});

// set a minimum load time so the user doesn't see a flash
// of the loader and then the matches themselves
const MINIMUM_LOAD_TIME = 1250;

const MatchPage = () => {
  const classes = useStyles();
  const [t] = useTranslation();
  const { profiles, error, activeProfile } = useProfiles();
  const { setViewed } = useMatchActions();
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    window.setTimeout(() => {
      setLoaded(true);
    }, MINIMUM_LOAD_TIME);
  }, []);

  const handleSwipe = (id: number, liked: boolean) => {
    // the user didn't choose (didn't swipe far enough)
    if (liked === null) return;
    setViewed(id, liked);
  };

  if (error) return <PageText text={t('MATCH.FEEDBACK.PROFILES_ERROR')} />;
  if (!loaded || !profiles) return <Loader />;
  if (!activeProfile)
    return (
      <EmptyState
        icon={<UserRound size={28} />}
        label={t('MATCH.FEEDBACK.NO_PROFILES')}
        sublabel={t('MATCH.FEEDBACK.NO_PROFILES_SUB')}
      />
    );

  return (
    <Paper className={classes.root} square elevation={0}>
      <ActiveProfile profile={activeProfile} onSwipe={handleSwipe} />
    </Paper>
  );
};

export default MatchPage;
