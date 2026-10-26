import React from 'react';
import { Backdrop, Paper, BoxProps } from '@mui/material';
import makeStyles from '@mui/styles/makeStyles';
import { AppContentTypes } from '../interface/InterfaceUI';
import { LoadingSpinner } from '@ui/components/LoadingSpinner';
import { classNames } from '@utils/css';

const useStyles = makeStyles(() => ({
  wrapper: {
    flex: 1,
    flexDirection: 'column',
    display: 'flex',
  },
  backdrop: {
    position: 'absolute',
    zIndex: 1,
  },
  paper: {
    width: '100%',
    flex: '1 1 auto', // allow application to fill entireity of space
  },
}));

export const AppContent: React.FC<AppContentTypes & BoxProps> = ({
  children,
  paperStyle,
  backdrop,
  disableSuspenseHandler,
  onClickBackdrop,
  ...props
}) => {
  const classes = useStyles();

  return (
    <div
      className="flex flex-col flex-1 bg-neutral-100 dark:bg-neutral-900"
      // Server: `overflowX` is always hidden. Apps that animate in with MUI `Slide`
      // (MessageModal, MessageGroupModal, NoteModal) are translated by `window.innerWidth -
      // rect.left`, which is measured against the *game* window, not the phone - roughly 450px
      // sideways. With `overflow: auto` on both axes that turned into a real horizontal scroll
      // range on this container, so every conversation opened with a fat scrollbar across the
      // bottom and the screen could be dragged sideways. Nothing on the phone scrolls
      // horizontally, so clipping that axis costs nothing.
      style={backdrop ? { overflow: 'hidden' } : { overflowX: 'hidden', overflowY: 'auto' }}
    >
      <Backdrop className={classes.backdrop} open={backdrop || false} onClick={onClickBackdrop} />
      {/* Server: `min-h-0` is the missing link in the phone's flex chain. `.PhoneAppContainer`,
          `AppWrapper` and the div above all carry a zero minimum already, but this one kept the
          default `min-height: auto` - and for a *block* box the automatic minimum in the block
          axis is simply its content height (unlike widths, heights have nothing to reflow). So
          any app whose content is intrinsically taller than the 714px screen forced this div to
          that full height, and every `h-full` inside it resolved against the overgrown number
          instead of the screen. In Messages that pushed the input bar clean off the bottom while
          the message skeleton (682px of bubbles) was on screen: the app looked like it had no
          input bar at all until the conversation finished loading. */}
      <div className={classNames('min-h-0 flex-auto w-full grow', props.className)} style={paperStyle}>
        {!disableSuspenseHandler ? (
          <React.Suspense fallback={<LoadingSpinner />}>{children}</React.Suspense>
        ) : (
          { children }
        )}
      </div>
    </div>
  );
};
