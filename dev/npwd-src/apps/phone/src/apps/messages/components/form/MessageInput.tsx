import React, { ChangeEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Paper, Box, Button, ButtonGroup } from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import MicIcon from '@mui/icons-material/Mic';
import IosShareIcon from '@mui/icons-material/IosShare';
import { NPWDInput, NPWDTextarea, TextField } from '@ui/components/Input';
import { useMessageAPI } from '../../hooks/useMessageAPI';
import { MessageConversation } from '@typings/messages';
import useMessages from '../../hooks/useMessages';
import { useWordFilter } from '@os/wordfilter/hooks/useWordFilter';
import { useConfig } from '@os/phone/hooks';
import { Image, Mic, SendHorizonal, SendHorizontal } from 'lucide-react';

interface IProps {
  onAddImageClick(): void;

  onVoiceClick: () => void;
  messageConversation: MessageConversation | undefined;
  messageGroupName: string | undefined;
  voiceEnabled: boolean;
}

const MessageInput = ({
  messageConversation,
  onAddImageClick,
  onVoiceClick,
  voiceEnabled,
}: IProps) => {
  const [t] = useTranslation();
  const [message, setMessage] = useState('');
  const { sendMessage } = useMessageAPI();
  const { activeMessageConversation } = useMessages();
  const { clean } = useWordFilter();

  const handleSubmit = async () => {
    if (message.trim()) {
      await sendMessage({
        conversationId: messageConversation.id,
        conversationList: activeMessageConversation.conversationList,
        message: clean(message),
        tgtPhoneNumber: messageConversation.participant,
      });
      setMessage('');
    }
  };

  const handleKeyPress = async (event: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      event.stopPropagation();
      await handleSubmit();
    }
  };

  const handleChange = (e: ChangeEvent<HTMLTextAreaElement | HTMLInputElement>) => {
    setMessage(e.currentTarget.value);
  };

  if (!messageConversation.id) return null;

  return (
    <div className="bg-[#F7F7F7] px-2 py-1 dark:bg-[#202C33]">
      <div className="flex items-center space-x-2 rounded-md px-2">
        <button
          onClick={onAddImageClick}
          className="h-14 text-neutral-500 hover:text-neutral-700 dark:text-neutral-400 dark:hover:text-neutral-200"
        >
          <Image size={24} />
        </button>
        <NPWDTextarea
          rows={1}
          className="resize-none !bg-white !text-black placeholder:text-neutral-500 dark:!bg-[#2A3942] dark:!text-white dark:placeholder:text-neutral-400"
          onKeyDown={handleKeyPress}
          value={message}
          onChange={handleChange}
          placeholder={t('MESSAGES.NEW_MESSAGE')}
        />
        <div className="flex items-center space-x-2">
          {voiceEnabled && (
            <button
              onClick={onVoiceClick}
              className="text-neutral-500 hover:text-neutral-700 dark:text-neutral-400 dark:hover:text-neutral-200"
            >
              <Mic size={24} />
            </button>
          )}

          <button
            onClick={handleSubmit}
            className="rounded-lg p-2 text-neutral-500 hover:text-neutral-700 dark:text-neutral-400 dark:hover:text-neutral-200"
          >
            <SendHorizontal size={24} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default MessageInput;
