import React from 'react';
import { Box, createStyles, keyframes, Text } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';
import { gfx, hudCorner } from '../../theme';
import type { ProgressbarProps } from '../../typings';

// Server: a moving highlight along the fill, the one piece of motion this bar had none of before -
// a flat colour block reads as static even while it's animating length, since nothing inside it
// moves. 200% wide so the highlight has room to travel off both edges rather than popping at 0%.
const shimmer = keyframes({
  '0%': { backgroundPosition: '200% 0' },
  '100%': { backgroundPosition: '-200% 0' },
});

const useStyles = createStyles((_theme, params: { duration: number }) => ({
  // Server: restyled onto this project's `gfx` theme - this was the one progress bar left on
  // stock Mantine (`theme.colors.dark[5]`, `theme.colors[theme.primaryColor]`) after the circular
  // one and the skill check were already converted. Same panel + hairline border + HUD corner
  // bracket treatment `CircleProgressbar`'s badge uses, so the two read as one family rather than
  // two different bars that happen to share a project.
  container: {
    position: 'relative',
    width: 360,
    height: 14,
    borderRadius: 999,
    background: 'rgba(0, 0, 0, 0.55)',
    border: `1px solid ${gfx.line}`,
    overflow: 'hidden',
  },
  // The label and percentage sit in their own badge above the bar, matching `CircleProgressbar`'s
  // value/label pairing instead of the old white-on-bar text that lost contrast the moment the
  // fill caught up to it.
  badge: {
    position: 'relative',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    background: gfx.panel,
    border: `1px solid ${gfx.line}`,
    borderRadius: 3,
    boxShadow: '0 14px 28px rgba(0,0,0,0.4)',
    padding: '14px 20px 16px',
    ...hudCorner,
  },
  wrapper: {
    width: '100%',
    height: '20%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    bottom: 0,
    position: 'absolute',
  },
  bar: {
    height: '100%',
    // A gradient rather than a flat fill, and the moving shimmer keyframe layered on top of it -
    // together they're what makes a bar that is otherwise just "getting wider" read as active.
    background: `linear-gradient(90deg, ${gfx.blueDim} 0%, ${gfx.blueBright} 100%)`,
    backgroundSize: '200% 100%',
    animationName: `progress-bar, ${shimmer}`,
    animationTimingFunction: 'linear, linear',
    animationIterationCount: '1, infinite',
    animationDuration: `${params.duration}ms, 1600ms`,
  },
  label: {
    textAlign: 'center',
    fontFamily: 'Rajdhani, sans-serif',
    fontWeight: 700,
    fontSize: 15,
    letterSpacing: '0.04em',
    color: gfx.textHi,
  },
}));

const Progressbar: React.FC = () => {
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState('');
  const [duration, setDuration] = React.useState(0);
  const { classes } = useStyles({ duration });

  useNuiEvent('progressCancel', () => setVisible(false));

  useNuiEvent<ProgressbarProps>('progress', (data) => {
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);
  });

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible} onExitComplete={() => fetchNui('progressComplete')}>
          <Box className={classes.badge}>
            {label && <Text className={classes.label}>{label}</Text>}
            <Box className={classes.container} mt={label ? 10 : 0}>
              <Box className={classes.bar} onAnimationEnd={() => setVisible(false)} />
            </Box>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default Progressbar;
