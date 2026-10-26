import React, { useCallback, useState } from 'react';
import { CircularProgress } from '@mui/material';
import { Message, MessageConversation, MessageEvents } from '@typings/messages';
import { MessageBubble } from './MessageBubble';
import fetchNui from '../../../../utils/fetchNui';
import { ServerPromiseResp } from '@typings/common';
import { useConversationId, useSetMessages } from '../../hooks/state';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { useHistory } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import InfiniteScroll from 'react-infinite-scroll-component';

interface IProps {
  activeMessageGroup: MessageConversation;
  messages: Message[];
  isVoiceEnabled: boolean;
}

export const CONVERSATION_ELEMENT_ID = 'message-modal-conversation';

const Conversation: React.FC<IProps> = ({ activeMessageGroup, messages, isVoiceEnabled }) => {
  const conversationId = useConversationId();
  const { addAlert } = useSnackbar();
  const history = useHistory();
  const setMessages = useSetMessages();
  const [t] = useTranslation();
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(!!messages.length);

  const handleNextPage = useCallback(() => {
    fetchNui<ServerPromiseResp<Message[]>>(MessageEvents.FETCH_MESSAGES, {
      conversationId: conversationId,
      page,
    }).then((resp) => {
      if (resp.status !== 'ok') {
        addAlert({
          message: t('MESSAGES.FEEDBACK.FETCHED_MESSAGES_FAILED'),
          type: 'error',
        });

        return history.push('/messages');
      }

      if (resp.data.length === 0) {
        setHasMore(false);
        return;
      }

      setHasMore(true);
      setPage((curVal) => curVal + 1);

      setMessages((currVal) => [...resp.data, ...currVal]);
    });
  }, [addAlert, conversationId, setMessages, history, t, page, setPage]);

  return (
    // Server: proper light/dark WhatsApp background - both themes get the real WhatsApp colour
    // (cream `#ECE5DD` light, near-black `#0B141A` dark) and the same one-motif chat-bubble
    // doodle, just recoloured per theme so it stays visible against either background. Two
    // stacked absolute layers (one per theme, toggled by Tailwind's `dark:` variant) instead of
    // a single inline `background-image`, since that can't switch with the theme on its own.
    <div className="relative h-full bg-[#ECE5DD] dark:bg-[#0B141A]">
      <div
        className="pointer-events-none absolute inset-0 dark:hidden"
        style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='90' height='90' viewBox='0 0 90 90'%3E%3Cpath fill='none' stroke='%23D8CFC3' stroke-width='1.6' d='M45 18c-13 0-23 8-23 19 0 7 4 13 11 16l-3 9 11-6c1 0 3 1 4 1 13 0 23-9 23-20s-10-19-23-19z'/%3E%3C/svg%3E")`,
          backgroundRepeat: 'repeat',
        }}
      />
      <div
        className="pointer-events-none absolute inset-0 hidden dark:block"
        style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='90' height='90' viewBox='0 0 90 90'%3E%3Cpath fill='none' stroke='%23233138' stroke-width='1.6' d='M45 18c-13 0-23 8-23 19 0 7 4 13 11 16l-3 9 11-6c1 0 3 1 4 1 13 0 23-9 23-20s-10-19-23-19z'/%3E%3C/svg%3E")`,
          backgroundRepeat: 'repeat',
        }}
      />
      <div
        id="scrollableDiv"
        className="relative"
        style={{
          overflow: 'auto',
          maxHeight: 620,
          display: 'flex',
          flexDirection: 'column-reverse',
          flexGrow: 1,
          padding: '12px 10px',
        }}
      >
        <InfiniteScroll
          next={handleNextPage}
          scrollableTarget="scrollableDiv"
          hasMore={hasMore}
          inverse={true}
          loader={<CircularProgress />}
          dataLength={messages.length}
        >
          {messages.map((message) => (
            <MessageBubble key={message.id} message={message} />
          ))}
        </InfiniteScroll>
      </div>
    </div>
  );
};

export default Conversation;
