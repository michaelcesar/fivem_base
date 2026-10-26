import React from 'react';
import { SearchContacts } from './SearchContacts';
import { Link, useHistory, useLocation } from 'react-router-dom';
import { useFilteredContacts } from '../../hooks/state';
import { Contact, ContactEvents } from "@typings/contact";
import { useCall } from '@os/call/hooks/useCall';
import useMessages from '@apps/messages/hooks/useMessages';
import LogDebugEvent from '@os/debug/LogDebugEvents';
import { useContactActions } from '@apps/contacts/hooks/useContactActions';
import { useMyPhoneNumber } from '@os/simcard/hooks/useMyPhoneNumber';
import { Phone, MessageSquare, Plus, Clipboard, UsersRound } from 'lucide-react';
import { List, ListItem, NPWDButton } from '@npwd/keyos';
import { ContactAvatar } from '@ui/components/ContactAvatar';
import { useQueryParams } from '@common/hooks/useQueryParams';
import { Tooltip } from '@ui/components/Tooltip';
import { useTranslation } from "react-i18next";
import { setClipboard } from "@os/phone/hooks";
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import fetchNui from "@utils/fetchNui";
import { useMessageAPI } from '@apps/messages/hooks/useMessageAPI';

export const ContactList: React.FC = () => {
  const filteredContacts = useFilteredContacts();
  const history = useHistory();

  // FIXME: This should be reduced before being passed to the component
  const groupedContacts = filteredContacts.reduce((r, e) => {
    const group = e.display.charAt(0).toUpperCase();
    if (!r[group]) r[group] = { group, contacts: [e] };
    else r[group].contacts.push(e);

    return r;
  }, []);

  const myNumber = useMyPhoneNumber()

  return (
    <div className="relative">
      <div className="sticky top-0 z-50">
        <div className="flex items-center space-x-2 bg-neutral-100 px-4 dark:bg-neutral-900">
          <SearchContacts />
          <NPWDButton
            size="icon"
            className="rounded-full p-2 text-neutral-900"
            variant="ghost"
            onClick={() => history.push('/contacts/-1')}
          >
            <Plus className="h-6 w-6" />
          </NPWDButton>
        </div>
      </div>

      <div className="mt-4 overflow-y-auto px-4">
        <nav className="space-y-2 overflow-y-auto" aria-label="Directory">
          <div key="self" className="relative">
            <List>
                <SelfContact key="self" number={myNumber} />
            </List>
          </div>

          {Object.keys(groupedContacts)
            .sort()
            .map((letter) => (
              <div key={letter} className="relative">
                <div className="sticky top-0 z-10 rounded-xl border-b border-t border-gray-200 bg-neutral-50 px-6 py-1 text-sm font-medium text-gray-500 dark:border-none dark:bg-neutral-800">
                  <h3>{letter}</h3>
                </div>
                <List>
                  {groupedContacts[letter].contacts.map((contact: Contact) => (
                    <ContactItem key={contact.id} {...contact} />
                  ))}
                </List>
              </div>
            ))}
        </nav>
      </div>
    </div>
  );
};

interface ContactItemProps extends Contact {
  onClick?: () => void;
}

const SelfContact = ({number}: {number: string}) => {
  const [t] = useTranslation();
  const {addAlert} = useSnackbar()
  const copyNumber = () => {
    setClipboard(number);
    addAlert({
      message: t('GENERIC.WRITE_TO_CLIPBOARD_MESSAGE', {
        content: t('CONTACTS.FORM_NUMBER') as string,
      }),
      type: 'success',
    });
  }

  const shareLocal = () => {
    fetchNui(ContactEvents.LOCAL_SHARE)
  }

  return (
    <ListItem>
      <div className="min-w-0 flex-1">
        <div
          className="flex items-center justify-between focus:outline-none"
        >
          <div className="flex items-center space-x-2">
            <ContactAvatar name={t('CONTACTS.MY_NUMBER') as string} />
            <div>
              <p className="text-base font-medium text-neutral-900 dark:text-neutral-100">
                {t('CONTACTS.MY_NUMBER')}
              </p>
              <p className="text-sm text-neutral-400">{number}</p>
            </div>
          </div>
          <div className="space-x-3">
            <Tooltip title={t('GENERIC.WRITE_TO_CLIPBOARD_TOOLTIP', {content: t('CONTACTS.FORM_NUMBER')}) as string}>
              <button
                onClick={copyNumber}
                className="rounded-full bg-neutral-100 p-3 text-neutral-300 hover:bg-neutral-200 dark:bg-neutral-900 dark:hover:bg-neutral-700"
              >
                <Clipboard size={20} />
              </button>
            </Tooltip>
            <Tooltip title={t('CONTACTS.NEARBY_SHARE')} >
              <button
                onClick={shareLocal}
                className="rounded-full bg-neutral-100 p-3 text-neutral-300 hover:bg-neutral-200 dark:bg-neutral-900 dark:hover:bg-neutral-700"
              >
                <UsersRound size={20} />
              </button>
            </Tooltip>
          </div>
        </div>
      </div>
    </ListItem>
  );
}

const ContactItem = ({ number, id, display }: ContactItemProps) => {
  const query = useQueryParams<{ referal: string }>();
  const { referal } = query;

  const { initializeCall } = useCall();
  const { goToConversation } = useMessages();
  const { findExistingConversation } = useContactActions();
  const { addConversation } = useMessageAPI();
  const myPhoneNumber = useMyPhoneNumber();
  const history = useHistory();

  const startCall = (e) => {
    e.stopPropagation();
    e.preventDefault();
    LogDebugEvent({
      action: 'Emitting `Start Call` to Scripts',
      level: 2,
      data: true,
    });
    initializeCall(number.toString());
  };

  const handleMessage = (e) => {
    e.stopPropagation();
    e.preventDefault();

    const phoneNumber = number.toString();
    LogDebugEvent({
      action: 'Routing to Message',
      level: 1,
      data: { phoneNumber },
    });
    const conversation = findExistingConversation(myPhoneNumber, phoneNumber);
    if (conversation) {
      return goToConversation(conversation);
    }

    // Server: create the conversation directly and land in it - no more detour through the
    // manual number-entry form (already reachable from Messages' own "+" button for group
    // chats, which still need to pick more than one participant).
    addConversation({
      conversationLabel: '',
      participants: [myPhoneNumber, phoneNumber],
      isGroupChat: false,
    });
  };

  return (
    <ListItem>
      <div className="min-w-0 flex-1">
        <Link
          to={
            referal
              ? `${referal}?contact=${encodeURIComponent(JSON.stringify({ number, id, display }))}`
              : `/contacts/${id}`
          }
          className="flex items-center justify-between focus:outline-none"
        >
          <div className="flex items-center space-x-2">
            <ContactAvatar name={display} />
            <div>
              <p className="text-base font-medium text-neutral-900 dark:text-neutral-100">
                {display}
              </p>
              <p className="text-sm text-neutral-400">{number}</p>
            </div>
          </div>
          <div className="space-x-3">
            <button
              onClick={startCall}
              className="rounded-full bg-green-100 p-3 text-green-500 hover:bg-green-200 dark:bg-green-900/30 dark:hover:bg-neutral-700"
            >
              <Phone size={20} />
            </button>
            <button
              onClick={handleMessage}
              className="rounded-full bg-blue-100 p-3 text-blue-400 hover:bg-blue-200 dark:bg-blue-900/30 dark:hover:bg-neutral-700"
            >
              <MessageSquare size={20} />
            </button>
          </div>
        </Link>
      </div>
    </ListItem>
  );
};
