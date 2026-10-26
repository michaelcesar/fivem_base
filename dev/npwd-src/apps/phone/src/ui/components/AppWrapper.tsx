import React from 'react';
import { AppWrapperTypes } from '../interface/InterfaceUI';

export const AppWrapper: React.FC<AppWrapperTypes> = ({
  children,
  style,
  handleClickAway,
  ...props
}) => {
  return (
    <div
      {...props}
      style={{
        padding: 0,
        margin: 0,
        width: '100%',
        height: '100%',
        display: 'flex',
        position: 'relative',
        flexDirection: 'column',
        // Server: was `minHeight: '720px'` - the same magic number `.PhoneAppContainer` used to
        // carry, and 6px more than the space actually left once the notification and navigation
        // bars are accounted for. With the container now `flex: 1`, a hard floor here would just
        // push the nav bar back out and reopen the dark seam above it.
        minHeight: 0,
        ...style,
      }}
    >
      {children}
    </div>
  );
};
