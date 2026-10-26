import React from 'react';
import { Box, CircularProgress } from '@mui/material';
import makeStyles from '@mui/styles/makeStyles';

// Server: originally `height: 100%` plus a `marginTop: 140px` on the spinner - 100% of the
// container *and then* 140px more, so the loading state was always taller than its space and the
// spinner sat wherever that pushed it.
//
// The first fix swapped the height for `flex: 1`, which did nothing: AppContent's inner element
// is a plain block, not a flex container, so `flex` on its child is ignored and the box collapsed
// to the spinner's own height - leaving it pinned to the top. Back to `height: 100%` (that part
// was always right), with `alignItems` doing the vertical centring the original never had.
const useStyles = makeStyles({
  root: {
    height: '100%',
    width: '100%',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  },
});

function Loader() {
  const classes = useStyles();
  return (
    <Box className={classes.root}>
      <CircularProgress size={60} />
    </Box>
  );
}

export default Loader;
