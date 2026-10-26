import React, { useEffect, useState } from 'react';
import { User } from 'lucide-react';
import { twMerge } from 'tailwind-merge';
import { stripPlaceholderImageUrl } from '@utils/placeholderImages';

interface ProfileAvatarProps {
  src?: string;
  size?: number;
  className?: string;
  onClick?: () => void;
}

// Server: the phone-wide fallback for any optional, player-provided image (Match/Twitter
// profile avatars, tweet cards) - a plain grey circle with a person icon, instead of a broken
// browser image icon (what used to show up whenever the URL was empty or dead) or a dependency
// on an external placeholder image host.
export const ProfileAvatar: React.FC<ProfileAvatarProps> = ({ src, size = 64, className, onClick }) => {
  const [errored, setErrored] = useState(false);
  const resolvedSrc = stripPlaceholderImageUrl(src);

  useEffect(() => {
    setErrored(false);
  }, [resolvedSrc]);

  const showImage = Boolean(resolvedSrc) && !errored;

  return (
    <div
      onClick={onClick}
      style={{ width: size, height: size }}
      className={twMerge(
        'flex shrink-0 items-center justify-center overflow-hidden rounded-full bg-neutral-200 text-neutral-400 dark:bg-neutral-700 dark:text-neutral-500',
        onClick && 'cursor-pointer',
        className,
      )}
    >
      {showImage ? (
        <img
          src={resolvedSrc}
          onError={() => setErrored(true)}
          className="h-full w-full object-cover object-center"
          alt=""
        />
      ) : (
        <User size={size * 0.5} />
      )}
    </div>
  );
};

export default ProfileAvatar;
