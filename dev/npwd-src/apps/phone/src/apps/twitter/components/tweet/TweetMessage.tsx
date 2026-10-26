import React, { memo, useRef, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { usePhone } from '@os/phone/hooks/usePhone';
import { getNewLineCount } from '../../utils/message';
import { NPWDTextarea } from '@ui/components/Input';

export const TweetMessage = ({ modalVisible, message, handleChange, onEnter }) => {
  const textFieldInputRef = useRef<HTMLTextAreaElement>(null);
  const { ResourceConfig } = usePhone();
  const [t] = useTranslation();

  const { characterLimit, newLineLimit } = ResourceConfig.twitter;

  useEffect(() => {
    textFieldInputRef.current && textFieldInputRef.current.focus();
  }, [modalVisible]);

  if (!ResourceConfig) return null;

  let errorMessage = null;

  const overCharacterLimit = message.trim().length > characterLimit;
  const characterWarningPrompt = `${t('TWITTER.TWEET_MESSAGE_CHAR_LIMIT')} (${characterLimit})`;

  const overNewLineLimit = getNewLineCount(message) > newLineLimit;
  const newLineWarningPrompt = `${t('TWITTER.TWEET_MESSAGE_NEW_LINE_LIMIT')} (${newLineLimit})`;

  if (overCharacterLimit) {
    errorMessage = characterWarningPrompt;
  } else if (overNewLineLimit) {
    errorMessage = newLineWarningPrompt;
  }

  const handleOnEnter = (event: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (overNewLineLimit) return;

    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      onEnter();
    }
  };

  return (
    <div className="mt-2 w-full">
      <NPWDTextarea
        value={message}
        onChange={(e) => handleChange(e.currentTarget.value)}
        onKeyDown={handleOnEnter}
        ref={textFieldInputRef}
        placeholder={t('TWITTER.TWEET_MESSAGE_PLACEHOLDER')}
        className="min-h-32 resize-none text-base"
      />
      {errorMessage && <p className="mt-1 text-xs text-red-500">{errorMessage}</p>}
    </div>
  );
};

export default memo(TweetMessage);
