import React from 'react';
import { ChannelMessageProps } from '@typings/darkchat';
import dayjs from 'dayjs';
import { cn } from '@utils/css';
import { PictureReveal } from '@ui/components/PictureReveal';
import { PictureResponsive } from '@ui/components/PictureResponsive';
import { DEEPWEB_BUBBLE_MINE, DEEPWEB_BUBBLE_THEIRS } from '../../darkchat.theme';

// Server: same bubble as ChannelMessageBubble - green when it is mine, dark grey when it is
// not. This one had been left on the old MUI Paper with a `minWidth: 50%` and a colour derived
// from `palette.primary.dark`, so an image arrived in a differently-coloured, differently-shaped
// bubble than the text sitting right above it.
const ChannelImageBubble: React.FC<ChannelMessageProps> = (item) => {
  return (
    <div className={cn('mb-3 flex px-3', item.isMine ? 'justify-end' : 'justify-start')}>
      <div
        className={cn(
          'relative max-w-[80%] rounded-lg p-1 text-white',
          item.isMine ? 'rounded-tr-none' : 'rounded-tl-none',
        )}
        style={{
          backgroundColor: item.isMine ? DEEPWEB_BUBBLE_MINE : DEEPWEB_BUBBLE_THEIRS,
        }}
      >
        <PictureReveal>
          <PictureResponsive src={item.message} alt="Darkchat image" />
        </PictureReveal>
        <p className="mb-0 mt-1 px-1 text-right text-[10px] text-neutral-500">
          {dayjs.unix(item.createdAt).fromNow()}
        </p>
      </div>
    </div>
  );
};

export default ChannelImageBubble;
