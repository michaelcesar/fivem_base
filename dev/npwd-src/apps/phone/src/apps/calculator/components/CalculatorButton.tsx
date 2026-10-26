import React, { HTMLAttributes } from 'react';
import { Grid } from '@mui/material';
import { GridProps } from '@mui/material';
import { cn } from '@utils/css';

interface ButtonOptions {
  onClick: () => void;
  label: string;
}

interface CalculatorButtonProps extends HTMLAttributes<HTMLButtonElement> {
  GridProps?: GridProps;
  buttonOpts: ButtonOptions;
  // Server: operators (÷ × − + = C AC) get the accent treatment, digits stay neutral -
  // matching the dial pad's own round-key redesign instead of the stock MUI text buttons.
  accent?: boolean;
}

export const CalculatorButton: React.FC<CalculatorButtonProps> = ({
  className,
  buttonOpts,
  GridProps,
  accent = false,
}) => (
  <Grid key={buttonOpts.label} item xs={3} {...GridProps} className="flex justify-center py-1.5">
    <button
      onClick={buttonOpts.onClick}
      className={cn(
        'flex h-16 w-16 items-center justify-center rounded-full text-xl font-medium transition-colors',
        accent
          ? 'bg-[#25D366] text-white active:bg-[#1ea952]'
          : 'bg-neutral-200 text-neutral-900 active:bg-neutral-300 dark:bg-neutral-800 dark:text-white dark:active:bg-neutral-700',
        className,
      )}
    >
      {buttonOpts.label}
    </button>
  </Grid>
);
