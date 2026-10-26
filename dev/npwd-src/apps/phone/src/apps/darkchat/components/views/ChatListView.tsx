import React, { useState } from 'react';
import { useChannelsValue } from '../../state/state';
import { ChannelItem } from '../ui/ChannelItem';
import { NewChannelModal } from '../ui/NewChannelModal';
import Backdrop from '@ui/components/Backdrop';
import { EmptyState } from '@ui/components/EmptyState';
import { Hash, Plus } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { DARKCHAT_APP_SECONDARY_COLOR, DEEPWEB_BACKGROUND } from '../../darkchat.theme';

// Server: the channel list now follows Messages' own list screen - bare rows with dividers, the
// shared EmptyState when there is nothing, and a floating round action button - instead of the
// stock MUI List plus a Fab painted from `palette.action.active`.
const ChatList: React.FC = () => {
  const channels = useChannelsValue();
  const [modal, setModal] = useState<boolean>(false);
  const [t] = useTranslation();

  const toggleModal = () => {
    setModal((curVal) => !curVal);
  };

  return (
    <div className="relative h-full" style={{ backgroundColor: DEEPWEB_BACKGROUND }}>
      <NewChannelModal open={modal} closeModal={toggleModal} />
      {modal && <Backdrop />}

      {channels.length ? (
        <div>
          {channels.map((channel) => (
            <ChannelItem key={channel.id} {...channel} />
          ))}
        </div>
      ) : (
        <EmptyState
          icon={<Hash size={28} />}
          label={t('DARKCHAT.NO_CHANNELS')}
          sublabel={t('DARKCHAT.NO_CHANNELS_SUB')}
        />
      )}

      <button
        onClick={toggleModal}
        className="absolute bottom-10 right-5 flex h-12 w-12 items-center justify-center rounded-full text-white"
        style={{ backgroundColor: DARKCHAT_APP_SECONDARY_COLOR }}
      >
        <Plus size={22} />
      </button>
    </div>
  );
};

export default ChatList;
