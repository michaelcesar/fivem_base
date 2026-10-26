import React from 'react';
import Skeleton from '@mui/material/Skeleton';

interface IProps {
  height: number;
  isMine?: boolean;
}

// Server: was a fixed `width={325}` bar indented with `marginLeft: 60px` for own messages -
// 385px of content inside a 400px screen, with nothing keeping it there if the phone ever gets
// narrower, and the "mine" side was only *indented* rather than right-aligned. It now mirrors
// MessageBubble's own geometry (`justify-end/start` around an 80%-wide bubble), so the loading
// state has the same shape as the conversation that replaces it and cannot overflow sideways at
// any width. Sizing goes through MUI's own props rather than Tailwind classes: emotion injects
// its styles after the static stylesheet, so a utility class of equal specificity would lose.
export default function MessageSkeleton({ height, isMine = false }: IProps) {
  return (
    <div className={`mb-3 flex px-3 py-1 ${isMine ? 'justify-end' : 'justify-start'}`}>
      <Skeleton
        variant="rectangular"
        width="80%"
        height={height}
        sx={{ borderRadius: '20px' }}
      />
    </div>
  );
}
