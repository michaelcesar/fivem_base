import React from 'react';
import { ChannelItemProps } from '@typings/darkchat';
import { useHistory } from 'react-router-dom';
import { useSetActiveDarkchatState } from '../../state/state';
import { Hash } from 'lucide-react';

// Server: rebuilt on Messages' own row shape - a plain row with a divider between entries and
// an avatar-sized circle on the left - instead of MUI's ListItem/Avatar card. DeepWeb keeps its
// own near-black surfaces rather than following the phone theme, and the circle carries a hash
// rather than initials, since channels are named things, not people.
export const ChannelItem: React.FC<ChannelItemProps> = (item) => {
  const history = useHistory();
  const setActiveConversation = useSetActiveDarkchatState();

  const handleGoToConversation = () => {
    setActiveConversation(item);
    history.push(`/darkchat/conversation/${item.id}`);
  };

  return (
    <div
      onClick={handleGoToConversation}
      className="flex cursor-pointer items-center space-x-3 border-b border-neutral-800 px-3 py-3 first:border-t hover:bg-neutral-900"
    >
      <div className="flex h-10 w-10 flex-none items-center justify-center rounded-full bg-neutral-800 text-neutral-400">
        <Hash size={18} />
      </div>
      <div className="min-w-0 grow">
        <p className="truncate text-sm font-medium text-white">{item.label ?? item.identifier}</p>
        <p className="truncate text-xs text-neutral-500">{item.identifier}</p>
      </div>
    </div>
  );
};
