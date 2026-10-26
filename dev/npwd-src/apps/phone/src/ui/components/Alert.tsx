import React, { forwardRef } from 'react';
import MuiAlert, { AlertProps } from '@mui/material/Alert';
import { Typography } from '@mui/material';

import makeStyles from '@mui/styles/makeStyles';

// Server: our own brand colours per severity, near-square corners - not MUI's default filled
// Alert palette/pill radius, which read as off-brand next to the rest of the redesigned phone.
const SEVERITY_COLORS: Record<string, { bg: string; fg: string }> = {
  success: { bg: '#25D366', fg: '#ffffff' },
  error: { bg: '#d64545', fg: '#ffffff' },
  warning: { bg: '#f0a020', fg: '#1a201c' },
  info: { bg: '#2b2b2b', fg: '#ffffff' },
};

const useStyles = makeStyles({
  root: {
    zIndex: 10000,
    borderRadius: '8px',
  },
  msg: {
    maxWidth: '300px',
    wordWrap: 'break-word',
    fontSize: '1.1em',
  },
});

export const Alert: React.FC<AlertProps> = forwardRef((props, ref) => {
  const classes = useStyles();
  const colors = SEVERITY_COLORS[props.severity ?? 'info'];

  return (
    <MuiAlert
      className={classes.root}
      elevation={4}
      variant="filled"
      {...props}
      ref={ref}
      sx={{ backgroundColor: colors.bg, color: colors.fg, '& .MuiAlert-icon': { color: colors.fg } }}
    >
      <Typography className={classes.msg}>{props.children}</Typography>
    </MuiAlert>
  );
});

export default Alert;
