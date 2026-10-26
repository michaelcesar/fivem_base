import React from 'react';
import { createStyles, keyframes, RingProgress, Stack, Text, Box } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';
import { gfx, hudCorner } from '../../theme';
import type { CircleProgressbarProps } from '../../typings';

// 33.5 is the r of the circle
const progressCircle = keyframes({
  '0%': { strokeDasharray: `0, ${33.5 * 2 * Math.PI}` },
  '100%': { strokeDasharray: `${33.5 * 2 * Math.PI}, 0` },
});

// Server: a slow breathing glow behind the ring - the one thing a flat panel + ring never had was
// any sense of the badge being "alive" while it sits there for several seconds. Kept slow (2.4s)
// and low-amplitude (0.35 <-> 0.6) so it reads as ambient, not as a second thing competing with the
// ring's own progress animation for attention.
const glowPulse = keyframes({
  '0%, 100%': { opacity: 0.35, transform: 'scale(0.94)' },
  '50%': { opacity: 0.6, transform: 'scale(1.04)' },
});

const useStyles = createStyles((theme, params: { duration: number }) => ({
  // Server: bottom-centre, always - `position` is deliberately NOT read from the NUI payload
  // anymore (see the component below for why). Fixed 20% height anchored to the bottom of the
  // screen, contents centred both ways.
  container: {
    width: '100%',
    height: '20%',
    bottom: 0,
    position: 'absolute',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  },
  // Server: the ring used to float bare on transparent NUI background - wrapped in the
  // same dark panel + HUD corner bracket treatment as TextUI's prompt badge, so it reads
  // as this project's own HUD instead of stock Mantine.
  badge: {
    position: 'relative',
    // Server: a Box is display:block, so the 90px RingProgress and the free-width label were
    // two block children - a label wider than the ring widened the badge and left the ring
    // sitting against its left edge, off-centre from everything else. Reported as the loading
    // not being horizontally centred. Centring the column keeps ring and label on the same
    // vertical axis no matter which one is wider. See ADR-079.
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    background: gfx.panel,
    border: `1px solid ${gfx.line}`,
    borderRadius: 3,
    boxShadow: '0 14px 28px rgba(0,0,0,0.4)',
    padding: '16px 20px 12px',
    ...hudCorner,
  },
  // Server: a soft radial glow sat behind the ring, `position: absolute` and centred on it via
  // the badge's own `position: relative` - purely decorative and `pointer-events: none` so it
  // never intercepts a click the ring or label would have gotten. Negative `zIndex` is load-bearing
  // here, not decoration: the label text below the ring is a plain non-positioned element, and
  // CSS paints non-positioned content ABOVE a positioned sibling whose z-index is 0 or higher - so
  // without going negative, the glow would have painted over the label instead of behind it.
  glow: {
    position: 'absolute',
    top: '16px',
    left: '50%',
    width: 110,
    height: 110,
    transform: 'translateX(-50%)',
    borderRadius: '50%',
    background: `radial-gradient(circle, ${gfx.blueBright}33 0%, transparent 70%)`,
    animation: `${glowPulse} 2400ms ease-in-out infinite`,
    pointerEvents: 'none',
    zIndex: -1,
  },
  progress: {
    '> svg > circle:nth-child(1)': {
      stroke: gfx.line,
    },
    // Scuffed way of grabbing the first section and animating it
    '> svg > circle:nth-child(2)': {
      stroke: gfx.blueBright,
      transition: 'none',
      animation: `${progressCircle} linear forwards`,
      animationDuration: `${params.duration}ms`,
      // Server: a rounded stroke cap reads as noticeably more refined at this thickness than the
      // engine's default square cut, especially in the last few percent where the arc is short.
      strokeLinecap: 'round',
    },
  },
  value: {
    textAlign: 'center',
    fontFamily: 'Rajdhani, sans-serif',
    fontWeight: 700,
    fontSize: 15,
    letterSpacing: '0.04em',
    color: gfx.textHi,
  },
  label: {
    textAlign: 'center',
    fontFamily: 'Inter, sans-serif',
    fontSize: 12,
    color: gfx.textMid,
    height: 25,
    marginTop: 6,
  },
}));

const CircleProgressbar: React.FC = () => {
  const [visible, setVisible] = React.useState(false);
  const [progressDuration, setProgressDuration] = React.useState(0);
  const [value, setValue] = React.useState(0);
  const [label, setLabel] = React.useState('');
  const { classes } = useStyles({ duration: progressDuration });

  useNuiEvent('progressCancel', () => {
    setValue(99);
    setVisible(false);
  });

  useNuiEvent<CircleProgressbarProps>('circleProgress', (data) => {
    if (visible) return;
    setVisible(true);
    setValue(0);
    setLabel(data.label || '');
    setProgressDuration(data.duration);
    // Server: `data.position` is deliberately ignored - bottom-centre is a project-wide rule,
    // not a per-call preference. Stock ox_lib defaults an unset `position` to 'middle', which
    // put ox_inventory's crafting bench (it never passes one) in the centre of the screen while
    // every one of our own resources passes 'bottom' - the same progress bar landing in two
    // different places depending on which resource opened it. The prop stays in the typings so
    // callers that still pass it don't break; it just has no effect.
    const onePercent = data.duration * 0.01;
    const updateProgress = setInterval(() => {
      setValue((previousValue) => {
        const newValue = previousValue + 1;
        newValue >= 100 && clearInterval(updateProgress);
        return newValue;
      });
    }, onePercent);
  });

  return (
    <>
      <Stack spacing={0} className={classes.container}>
        <ScaleFade visible={visible} onExitComplete={() => fetchNui('progressComplete')}>
          <Stack spacing={0} align="center">
            <Box className={classes.badge}>
              <Box className={classes.glow} />
              <RingProgress
                size={90}
                thickness={7}
                sections={[{ value: 0, color: gfx.blueBright }]}
                onAnimationEnd={() => setVisible(false)}
                className={classes.progress}
                label={<Text className={classes.value}>{value}%</Text>}
              />
              {label && <Text className={classes.label}>{label}</Text>}
            </Box>
          </Stack>
        </ScaleFade>
      </Stack>
    </>
  );
};

export default CircleProgressbar;
