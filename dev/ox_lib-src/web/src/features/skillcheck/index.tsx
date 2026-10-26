import { useRef, useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import Indicator from './indicator';
import { fetchNui } from '../../utils/fetchNui';
import { Box, createStyles } from '@mantine/core';
import type { GameDifficulty, SkillCheckProps } from '../../typings';
import { gfx } from '../../theme';

export const circleCircumference = 2 * 50 * Math.PI;

const getRandomAngle = (min: number, max: number) => Math.floor(Math.random() * (max - min)) + min;

const difficultyOffsets = {
  easy: 50,
  medium: 40,
  hard: 25,
};

// Server: restyled onto this project's `gfx` design language (see theme/index.ts) - upstream drew
// this with Mantine defaults (`theme.colors.dark[5]`, `theme.fn.primaryColor()` and a hardcoded
// `'red'`), which is the one screen in the fork that still looked like stock ox_lib.
//
// The colour choices carry meaning rather than just matching a palette: the target arc is `green`
// because it is the zone you are trying to hit, and the moving indicator is `textHi` (near-white)
// because it has to stay legible against both the dark track AND the green arc it crosses. Using
// the silver accent for the arc was tried first and rejected - silver on a dark track reads as
// decoration, not as a target.
const useStyles = createStyles((_theme, params: { difficultyOffset: number }) => ({
  svg: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    r: 50,
    width: 500,
    height: 500,
  },
  track: {
    fill: 'transparent',
    // Server: a flat panel colour would vanish against a dark scene and glare against a bright
    // one, so the empty track is drawn as translucent black - it reads as a recess over anything.
    stroke: 'rgba(0, 0, 0, 0.55)',
    strokeWidth: 8,
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    '@media (min-height: 1440px)': {
      strokeWidth: 10,
      r: 65,
      strokeDasharray: 2 * 65 * Math.PI,
    },
  },
  skillArea: {
    fill: 'transparent',
    stroke: gfx.green,
    strokeWidth: 8,
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    strokeDashoffset: circleCircumference - (Math.PI * 50 * params.difficultyOffset) / 180,
    '@media (min-height: 1440px)': {
      strokeWidth: 10,
      r: 65,
      strokeDasharray: 2 * 65 * Math.PI,
      strokeDashoffset: 2 * 65 * Math.PI - (Math.PI * 65 * params.difficultyOffset) / 180,
    },
  },
  indicator: {
    stroke: gfx.textHi,
    strokeWidth: 16,
    fill: 'transparent',
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    strokeDashoffset: circleCircumference - 3,
    '@media (min-height: 1440px)': {
      strokeWidth: 18,
      r: 65,
      strokeDasharray: 2 * 65 * Math.PI,
      strokeDashoffset: 2 * 65 * Math.PI - 5,
    },
  },
  // The key prompt is a miniature of this project's card: panel fill, 1px hairline border, 3px
  // corners, Rajdhani display type. No HUD corner bracket - at 28px the 14px bracket from
  // `hudCorner` would cover half the box.
  button: {
    position: 'absolute',
    left: '50%',
    top: '50%',
    transform: 'translate(-50%, -50%)',
    background: gfx.panel,
    border: `1px solid ${gfx.line}`,
    borderRadius: 3,
    boxShadow: '0 14px 28px rgba(0,0,0,0.4)',
    color: gfx.textHi,
    width: 28,
    height: 28,
    textAlign: 'center',
    fontFamily: 'Rajdhani, sans-serif',
    fontSize: 18,
    fontWeight: 700,
    letterSpacing: '0.04em',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    '@media (min-height: 1440px)': {
      width: 34,
      height: 34,
      fontSize: 24,
    },
  },
}));

const SkillCheck: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const dataRef = useRef<{ difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] } | null>(null);
  const dataIndexRef = useRef<number>(0);
  const [skillCheck, setSkillCheck] = useState<SkillCheckProps>({
    angle: 0,
    difficultyOffset: 50,
    difficulty: 'easy',
    key: 'e',
  });
  const { classes } = useStyles({ difficultyOffset: skillCheck.difficultyOffset });

  useNuiEvent('startSkillCheck', (data: { difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] }) => {
    dataRef.current = data;
    dataIndexRef.current = 0;
    const gameData = Array.isArray(data.difficulty) ? data.difficulty[0] : data.difficulty;
    const offset = typeof gameData === 'object' ? gameData.areaSize : difficultyOffsets[gameData];
    const randomKey = data.inputs ? data.inputs[Math.floor(Math.random() * data.inputs.length)] : 'e';
    setSkillCheck({
      angle: -90 + getRandomAngle(120, 360 - offset),
      difficultyOffset: offset,
      difficulty: gameData,
      keys: data.inputs?.map((input) => input.toLowerCase()),
      key: randomKey.toLowerCase(),
    });

    setVisible(true);
  });

  useNuiEvent('skillCheckCancel', () => {
    setVisible(false);
    fetchNui('skillCheckOver', false);
  });

  const handleComplete = (success: boolean) => {
    if (!dataRef.current) return;
    if (!success || !Array.isArray(dataRef.current.difficulty)) {
      setVisible(false);
      return fetchNui('skillCheckOver', success);
    }

    if (dataIndexRef.current >= dataRef.current.difficulty.length - 1) {
      setVisible(false);
      return fetchNui('skillCheckOver', success);
    }

    dataIndexRef.current++;
    const data = dataRef.current.difficulty[dataIndexRef.current];
    const key = dataRef.current.inputs
      ? dataRef.current.inputs[Math.floor(Math.random() * dataRef.current.inputs.length)]
      : 'e';
    const offset = typeof data === 'object' ? data.areaSize : difficultyOffsets[data];
    setSkillCheck((prev) => ({
      ...prev,
      angle: -90 + getRandomAngle(120, 360 - offset),
      difficultyOffset: offset,
      difficulty: data,
      key: key.toLowerCase(),
    }));
  };

  return (
    <>
      {visible && (
        <>
          <svg className={classes.svg}>
            {/*Circle track*/}
            <circle className={classes.track} />
            {/*SkillCheck area*/}
            <circle transform={`rotate(${skillCheck.angle}, 250, 250)`} className={classes.skillArea} />
            <Indicator
              angle={skillCheck.angle}
              offset={skillCheck.difficultyOffset}
              multiplier={
                skillCheck.difficulty === 'easy'
                  ? 1
                  : skillCheck.difficulty === 'medium'
                  ? 1.5
                  : skillCheck.difficulty === 'hard'
                  ? 1.75
                  : skillCheck.difficulty.speedMultiplier
              }
              handleComplete={handleComplete}
              className={classes.indicator}
              skillCheck={skillCheck}
            />
          </svg>
          <Box className={classes.button}>{skillCheck.key.toUpperCase()}</Box>
        </>
      )}
    </>
  );
};

export default SkillCheck;
