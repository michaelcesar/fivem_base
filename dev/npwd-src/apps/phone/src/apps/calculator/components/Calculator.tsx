import React, { useMemo } from 'react';
import { useCalculator } from '../hooks/useCalculator';
import { Grid, Box, styled } from '@mui/material';
import { setClipboard } from '@os/phone/hooks/useClipboard';
import { Copy } from 'lucide-react';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { useTranslation } from 'react-i18next';
import { CalculatorButton } from './CalculatorButton';

const getFontSize = (length: number) => {
  const currentSize = 5 - length * 0.2;
  return currentSize <= 1.5 ? '1.5rem' : `${currentSize}rem`;
};

// Server: light-weight numeral font (matching the dial pad's own big, thin number display),
// instead of the default bold MUI typography weight.
const StyledResultWrapper = styled(Box)<{ length: number }>(({ theme, length }) => ({
  minHeight: '7rem',
  fontSize: length < 9 ? theme.typography.h2.fontSize : getFontSize(length),
  fontWeight: 300,
  textAlign: 'right',
  overflow: 'hidden',
  textOverflow: 'ellipsis',
  position: 'relative',
}));

export const Calculator: React.FC = () => {
  const {
    result,
    equals,
    clear,
    clearAll,
    divider,
    multiplier,
    substractor,
    adder,
    dot,
    zero,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
  } = useCalculator();

  const { addAlert } = useSnackbar();
  const [t] = useTranslation();

  const resultStr = useMemo(
    () =>
      result().toLocaleString(undefined, {
        minimumFractionDigits: 0,
        maximumFractionDigits: 4,
      }),
    [result],
  );

  const handleCopyClipboard = () => {
    setClipboard(resultStr);
    addAlert({
      message: t('GENERIC.WRITE_TO_CLIPBOARD_MESSAGE', {
        content: t('CONTACTS.FORM_NUMBER'),
      }),
      type: 'success',
    });
  };

  return (
    <Box display="flex" flexDirection="column">
      <StyledResultWrapper flexGrow={1} p={2} length={resultStr.length}>
        {/* Server: a plain subtle icon, no Fab/coloured background, matching the "quiet" icon
        treatment used elsewhere on the redesigned phone. */}
        <button
          onClick={handleCopyClipboard}
          className="absolute left-4 top-4 text-neutral-400 hover:text-neutral-600 dark:text-neutral-500 dark:hover:text-neutral-300"
        >
          <Copy size={20} strokeWidth={1.75} />
        </button>
        {resultStr}
      </StyledResultWrapper>
      <Box>
        <Grid container justifyContent="space-around">
          <CalculatorButton buttonOpts={clear} accent />
          <CalculatorButton buttonOpts={clearAll} accent />
          <CalculatorButton buttonOpts={divider} accent />
          <CalculatorButton buttonOpts={multiplier} accent />
          <CalculatorButton buttonOpts={seven} />
          <CalculatorButton buttonOpts={eight} />
          <CalculatorButton buttonOpts={nine} />
          <CalculatorButton buttonOpts={substractor} accent />
          <CalculatorButton buttonOpts={four} />
          <CalculatorButton buttonOpts={five} />
          <CalculatorButton buttonOpts={six} />
          <CalculatorButton buttonOpts={adder} accent />
          <CalculatorButton buttonOpts={one} />
          <CalculatorButton buttonOpts={two} />
          <CalculatorButton buttonOpts={three} />
          <CalculatorButton buttonOpts={equals} accent />
          <CalculatorButton buttonOpts={dot} />
          <CalculatorButton buttonOpts={zero} GridProps={{ xs: 9 }} />
        </Grid>
      </Box>
    </Box>
  );
};
