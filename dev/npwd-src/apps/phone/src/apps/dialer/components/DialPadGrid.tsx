import React, { useContext } from 'react';
import { Box, Grid } from '@mui/material';
import { DialInputCtx } from '../context/InputContext';

// Server: real iPhone dial pad - round keys, big digit, small grey letter caption
// underneath (standard telephone letter mapping), instead of plain rectangular text buttons.
const LETTERS: Record<string, string> = {
  '1': '',
  '2': 'ABC',
  '3': 'DEF',
  '4': 'GHI',
  '5': 'JKL',
  '6': 'MNO',
  '7': 'PQRS',
  '8': 'TUV',
  '9': 'WXYZ',
  '0': '',
};

interface ButtonItemProps {
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
  label: string | number;
}

const ButtonItem: React.FC<ButtonItemProps> = ({ label, onClick }) => {
  const letters = LETTERS[String(label)];

  return (
    <Grid item xs={4} className="flex justify-center py-1.5">
      <button
        onClick={onClick}
        className="flex h-16 w-16 flex-col items-center justify-center rounded-full bg-neutral-200 text-neutral-900 transition-colors active:bg-neutral-300 dark:bg-neutral-800 dark:text-white dark:active:bg-neutral-700"
      >
        <span className="text-2xl font-medium leading-none">{label}</span>
        {letters && <span className="mt-0.5 text-[10px] tracking-wide text-neutral-500 dark:text-neutral-400">{letters}</span>}
      </button>
    </Grid>
  );
};

export const DialGrid = () => {
  const { add, removeOne, clear } = useContext(DialInputCtx);

  return (
    <Box className="px-6 pb-6">
      <Grid container justifyContent="space-around">
        <ButtonItem label={1} onClick={() => add(1)} />
        <ButtonItem label={2} onClick={() => add(2)} />
        <ButtonItem label={3} onClick={() => add(3)} />
        <ButtonItem label={4} onClick={() => add(4)} />
        <ButtonItem label={5} onClick={() => add(5)} />
        <ButtonItem label={6} onClick={() => add(6)} />
        <ButtonItem label={7} onClick={() => add(7)} />
        <ButtonItem label={8} onClick={() => add(8)} />
        <ButtonItem label={9} onClick={() => add(9)} />
        <ButtonItem label="*" onClick={clear} />
        <ButtonItem label={0} onClick={() => add(0)} />
        <ButtonItem label="#" onClick={removeOne} />
        <ButtonItem label="-" onClick={() => add('-')} />
      </Grid>
    </Box>
  );
};

export default DialGrid;
