import React, { useEffect, useState } from 'react';
import { Box } from '@mui/material';
import { useActiveDarkchatValue, useDarkchatMessagesValue } from '../../state/state';
import { useLocation } from 'react-router-dom';
import { LoadingSpinner } from '@ui/components/LoadingSpinner';
import { useDarkchatAPI } from '../../hooks/useDarkchatAPI';
import ChannelMessageBubble from '../ui/ChannelMessageBubble';
import ChannelImageBubble from '../ui/ChannelImageBubble';
import ChannelInput from '../ui/ChannelInput';
import { UploadMediaModal } from '../modals/UploadMedia';
import { useQueryParams } from '@common/hooks/useQueryParams';
import { useHistory } from 'react-router-dom';
import { deleteQueryFromLocation } from '@common/utils/deleteQueryFromLocation';
import { useModal } from '../../hooks/useModal';
import Backdrop from '@ui/components/Backdrop';
import { OwnerModal } from '@apps/darkchat/components/modals/OwnerModal';
import { DEEPWEB_BACKGROUND } from '../../darkchat.theme';

export const ConversationView: React.FC = () => {
  const activeConversation = useActiveDarkchatValue();
  const { fetchMessages, fetchMembers } = useDarkchatAPI();
  const messages = useDarkchatMessagesValue();
  const history = useHistory();
  const query = useQueryParams();
  const { pathname, search } = useLocation();
  const { setModalMedia, modalVisible, ownerModal, setOwnerModal } = useModal();

  useEffect(() => {
    if (!query?.image) return;

    setModalMedia(query.image);

    history.replace(deleteQueryFromLocation({ pathname, search }, 'image'));
  }, [query?.image, history, pathname, search, setModalMedia]);

  useEffect(() => {
    fetchMessages(activeConversation.id);
    fetchMembers(activeConversation.id);
  }, [activeConversation]);

  if (!activeConversation && !messages) return <LoadingSpinner />;

  return (
    // Server: `height: 100%`, not `flex: 1`. AppContent's inner element is a plain block, so a
    // `flex` value on its child is ignored entirely and this column collapsed to the height of
    // however many messages existed - leaving the input bar floating under the last one with
    // empty screen below it. `height: 100%` fills the block; the flex sizing *inside* this
    // column then works, because this element is the flex container for it.
    <Box display="flex" flexDirection="column" height="100%">
      <UploadMediaModal />
      <OwnerModal open={ownerModal} closeModal={() => setOwnerModal(false)} />
      {modalVisible || (ownerModal && <Backdrop />)}
      {/* Server: same shape as Messages' own Conversation - a patterned background layer behind
          a padded scroll container. The height was `605`, a hardcoded pixel value unrelated to
          the space actually left after the header and input bar, so the list either overflowed or
          left a gap depending on the phone's zoom. `flex: 1` fills whatever is really there.
          The motif is a terminal prompt rather than Messages' chat bubble, drawn in a barely-lit
          grey so it reads as texture on near-black instead of decoration. */}
      <Box position="relative" flex={1} minHeight={0} sx={{ backgroundColor: DEEPWEB_BACKGROUND }}>
        <div
          className="pointer-events-none absolute inset-0"
          style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='90' height='90' viewBox='0 0 90 90'%3E%3Cpath fill='none' stroke='%231C1C1C' stroke-width='2' stroke-linecap='round' d='M30 34l10 10-10 10M46 54h16'/%3E%3C/svg%3E")`,
            backgroundRepeat: 'repeat',
          }}
        />
        <Box
          position="relative"
          display="flex"
          flexDirection="column"
          width="100%"
          height="100%"
          overflow="auto"
          sx={{ padding: '12px 10px' }}
        >
          {/* `mt-auto` bottom-anchors the messages the way a chat reads, without using
              `justify-content: flex-end`, which clips the top of the list once it overflows. */}
          <div className="mt-auto">
            {messages.map((message) =>
              /* type is wether or not the message is a image or not */
              message.isImage ? (
                <ChannelImageBubble {...message} />
              ) : (
                <ChannelMessageBubble {...message} />
              ),
            )}
          </div>
        </Box>
      </Box>
      {/* flexShrink: 0 - the input bar keeps its height and stays pinned to the bottom while the
          message list above it takes all the remaining space and scrolls. */}
      <Box flexShrink={0}>
        <ChannelInput />
      </Box>
    </Box>
  );
};
