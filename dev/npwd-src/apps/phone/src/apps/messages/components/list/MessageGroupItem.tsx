import React, { useCallback } from 'react';
import { Checkbox } from '@mui/material';

import { MessageConversation } from '@typings/messages';
import { useContactActions } from '../../../contacts/hooks/useContactActions';
import { useContacts } from '../../../contacts/hooks/state';
import { Contact } from '@typings/contact';
import { ContactAvatar } from '@ui/components/ContactAvatar';
import { Bell } from 'lucide-react';
import { MESSAGES_APP_ACCENT_BLUE } from '../../messages.theme';

interface IProps {
  messageConversation: MessageConversation;
  handleClick: (conversations: MessageConversation) => () => void;
  isEditing: boolean;
  checked: number[];
  handleToggle: (id: number) => void;
}

const MessageGroupItem = ({
  messageConversation,
  handleClick,
  isEditing,
  checked,
  handleToggle,
}: IProps): any => {
  const toggleCheckbox = () => {
    handleToggle(messageConversation.id);
  };

  const contacts = useContacts();
  const { getContactByNumber } = useContactActions();

  const contactDisplay = useCallback(
    (number: string): Contact | null => {
      return contacts.length ? getContactByNumber(number) : null;
    },
    [contacts, getContactByNumber],
  );

  const getContact = useCallback((): Contact | null => {
    // This is the source
    const participant = messageConversation.participant;
    const conversationList = messageConversation.conversationList.split('+');

    for (const p of conversationList) {
      if (p !== participant) {
        const contact = contactDisplay(p);
        return contact || null;
      }
    }
  }, [contactDisplay, messageConversation]);

  const getLabelOrContact = useCallback((): Contact | string => {
    const conversationLabel = messageConversation.label;
    // This is the source
    const participant = messageConversation.participant;
    const conversationList = messageConversation.conversationList.split('+');

    // Label is required if the conversation is a group chat
    if (messageConversation.isGroupChat) return conversationLabel;

    return getContact()?.display || conversationList.filter((p) => p !== participant)[0];
  }, [messageConversation, getContact]);

  // Server: no card background/rounded-list styling here (unlike @npwd/keyos's shared List) -
  // requested a plain WhatsApp-style row instead, just a border between rows.
  return (
    <div
      onClick={!isEditing ? handleClick(messageConversation) : toggleCheckbox}
      className="flex cursor-pointer items-center space-x-3 border-b border-neutral-200 px-3 py-3 first:border-t hover:bg-neutral-100 dark:border-neutral-800 dark:hover:bg-neutral-900"
    >
      {isEditing && (
        // Checked state forced to Messages' blue accent rather than MUI's `primary` (the app's
        // green) - the same by-request exception as the "new conversation" button. Unchecked
        // stays MUI's neutral grey.
        <Checkbox
          checked={checked.indexOf(messageConversation.id) !== -1}
          edge="start"
          disableRipple
          sx={{ '&.Mui-checked': { color: MESSAGES_APP_ACCENT_BLUE } }}
        />
      )}
      <ContactAvatar
        name={messageConversation.isGroupChat ? messageConversation.label : getContact()?.display ?? String(getLabelOrContact())}
      />
      <div className="min-w-0 grow">
        <p className="truncate text-sm font-medium text-neutral-900 dark:text-white">
          {getLabelOrContact()}
        </p>
      </div>
      {messageConversation.unreadCount > 0 && (
        <Bell size={18} className="flex-none text-[#25D366]" />
      )}
    </div>
  );
};

export default MessageGroupItem;
