import React from 'react';
import { ChannelMessageProps } from '@typings/darkchat';
import dayjs from 'dayjs';
import { cn } from '@utils/css';
import { DEEPWEB_BUBBLE_MINE, DEEPWEB_BUBBLE_THEIRS } from '../../darkchat.theme';

// Server: same bubble shape Messages uses - a pointed corner on the side the message came from,
// the timestamp inside the bubble under the text - but on DeepWeb's near-black palette instead of
// WhatsApp's. Replaces a MUI Paper that was floated left/right with a hardcoded 50% min-width,
// which made a two-word message occupy half the screen.
const ChannelMessageBubble: React.FC<ChannelMessageProps> = (item) => {
  return (
    <div className={cn('mb-3 flex px-3', item.isMine ? 'justify-end' : 'justify-start')}>
      <div
        className={cn(
          'relative max-w-[80%] rounded-lg px-3 py-2 text-white',
          item.isMine ? 'rounded-tr-none' : 'rounded-tl-none',
        )}
        style={{
          backgroundColor: item.isMine ? DEEPWEB_BUBBLE_MINE : DEEPWEB_BUBBLE_THEIRS,
        }}
      >
        <p className="whitespace-pre-wrap break-words text-sm">{item.message}</p>
        <p className="mt-1 text-right text-[10px] text-neutral-500">
          {dayjs.unix(item.createdAt).fromNow()}
        </p>
      </div>
    </div>
  );
};

export default ChannelMessageBubble;
