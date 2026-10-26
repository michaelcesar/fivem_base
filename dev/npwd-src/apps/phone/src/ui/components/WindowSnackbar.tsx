import React, { useState } from 'react';
import { Snackbar, Typography } from '@mui/material';
import { Alert } from './Alert';
import makeStyles from '@mui/styles/makeStyles';
import { useNuiEvent } from 'fivem-nui-react-lib';
import { useTranslation } from 'react-i18next';

const useStyles = makeStyles({
  root: {
    position: 'absolute',
    width: 'auto',
    bottom: 20,
  },
});
// NOTE: Will make this more generic at some point for error handling as well
const WindowSnackbar: React.FC = () => {
  const [open, setOpen] = useState<boolean>(false);
  const [message, setMessage] = useState<string>('');
  const [severity, setSeverity] = useState<'info' | 'error' | 'success'>('info');

  const classes = useStyles();
  const [t] = useTranslation();

  useNuiEvent('PHONE', 'startRestart', () => {
    setMessage(t('MISC.RESTARTING_UI'));
    setOpen(true);
    setSeverity('error');
    setTimeout(() => window.location.reload(), 3000);
  });

  const handleClose = () => {
    setOpen(false);
  };

  return (
    <Snackbar open={open} onClose={handleClose} className={classes.root}>
      <Alert severity={severity}>
        <Typography variant="body1">{t('APPS_DIALER')} - {message}</Typography>
      </Alert>
    </Snackbar>
  );
};

export default WindowSnackbar;
