import React, { useState } from 'react';
import { Theme } from '@mui/material/styles';
import makeStyles from '@mui/styles/makeStyles';
import DialGrid from '../DialPadGrid';
import { DialerInput } from '../DialerInput';
import { DialInputCtx } from '../../context/InputContext';
import { useQueryParams } from '@common/hooks/useQueryParams';

const useStyles = makeStyles((theme: Theme) => ({
  root: {
    width: '100%',
    minHeight: '100%',
    display: 'flex',
    flexDirection: 'column',
    // Server: iPhone's own dialer keeps the number display near the top and pins the keypad to
    // the bottom of the screen - this used to stack both at the top with dead space underneath.
    justifyContent: 'space-between',
  },
}));

const DialPage: React.FC = () => {
  const classes = useStyles();
  const query = useQueryParams();
  const queryNumber = query.number;
  const [inputVal, setInputVal] = useState(queryNumber || '');

  return (
    <div className={classes.root}>
      <DialInputCtx.Provider
        value={{
          inputVal,
          add: (val: string) => setInputVal(inputVal + val),
          removeOne: () => setInputVal(inputVal.slice(0, -1)),
          clear: () => setInputVal(''),
          set: (val: string) => setInputVal(val),
        }}
      >
        <DialerInput />
        <DialGrid />
      </DialInputCtx.Provider>
    </div>
  );
};
export default DialPage;
