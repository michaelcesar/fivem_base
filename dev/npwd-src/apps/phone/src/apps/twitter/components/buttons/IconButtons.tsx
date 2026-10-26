import React, { memo } from 'react';
import { Image, Smile } from 'lucide-react';
import { usePhone } from '@os/phone/hooks/usePhone';

export const IconButtons = ({ onImageClick, onEmojiClick }) => {
  const { ResourceConfig } = usePhone();

  if (!ResourceConfig) return null;
  const { enableImages, enableEmojis } = ResourceConfig.twitter;

  return (
    <div className="flex flex-row items-center gap-1">
      {enableImages && (
        <button
          onClick={onImageClick}
          className="rounded-full p-2 text-neutral-500 hover:bg-black/5 dark:text-neutral-400 dark:hover:bg-white/10"
        >
          <Image size={20} />
        </button>
      )}
      {enableEmojis && (
        <button
          onClick={onEmojiClick}
          className="rounded-full p-2 text-neutral-500 hover:bg-black/5 dark:text-neutral-400 dark:hover:bg-white/10"
        >
          <Smile size={20} />
        </button>
      )}
    </div>
  );
};

export default memo(IconButtons);
