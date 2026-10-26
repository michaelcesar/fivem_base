import React, { useState } from 'react';
import { Image, SendHorizontal } from 'lucide-react';
import { NPWDTextarea } from '@ui/components/Input';
import { useTranslation } from 'react-i18next';
import { useDarkchatAPI } from '../../hooks/useDarkchatAPI';
import { useActiveDarkchatValue } from '../../state/state';
import { useMyPhoneNumber } from '@os/simcard/hooks/useMyPhoneNumber';
import { useModal } from '../../hooks/useModal';
import { DEEPWEB_SURFACE } from '../../darkchat.theme';

// Server: rebuilt on MessageInput's shape - a flat bar in the app's surface colour, a rounded
// text field, and plain grey icons either side. Was a MUI `Paper variant="outlined"` wrapping a
// `TextField` and two `Button`s with tooltips, which drew a hard box around the whole bar and
// looked nothing like the rest of the phone.
const ChannelInput: React.FC = () => {
  const [message, setMessage] = useState<string>('');
  const [t] = useTranslation();
  const { sendMessage } = useDarkchatAPI();
  const { id: channelId } = useActiveDarkchatValue();
  const phoneNumber = useMyPhoneNumber();
  const { setModalVisible } = useModal();

  const handleSendMessage = () => {
    if (!message.trim()) return;
    sendMessage({
      channelId,
      message,
      phoneNumber,
      type: 'text',
    });
    setMessage('');
  };

  const handleKeyPress = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  return (
    <div className="px-2 py-1" style={{ backgroundColor: DEEPWEB_SURFACE }}>
      <div className="flex items-center space-x-2 rounded-md px-2">
        <button
          onClick={() => setModalVisible(true)}
          className="h-14 text-neutral-400 hover:text-neutral-200"
        >
          <Image size={24} />
        </button>
        <NPWDTextarea
          rows={1}
          className="resize-none !bg-[#242424] !text-white placeholder:text-neutral-500"
          value={message}
          onChange={(e) => setMessage(e.currentTarget.value)}
          onKeyDown={handleKeyPress}
          placeholder={t('DARKCHAT.MESSAGE_PLACEHOLDER')}
        />
        <button
          onClick={handleSendMessage}
          className="rounded-lg p-2 text-neutral-400 hover:text-neutral-200"
        >
          <SendHorizontal size={24} />
        </button>
      </div>
    </div>
  );
};

export default ChannelInput;
