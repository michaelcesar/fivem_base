import React, { useCallback } from 'react';
import { List, ListItem, NPWDButton } from '@npwd/keyos';
import { useContactActions } from '../../../contacts/hooks/useContactActions';
import { CallHistoryItem } from '@typings/call';
import { useTranslation } from 'react-i18next';
import { useHistory } from 'react-router-dom';
import dayjs from 'dayjs';
import { useMyPhoneNumber } from '@os/simcard/hooks/useMyPhoneNumber';
import { useDialHistory } from '../../hooks/useDialHistory';
import { useCall } from '@os/call/hooks/useCall';
import { useContacts } from '../../../contacts/hooks/state';
import { Clock, Phone, PhoneForwarded, PhoneIncoming, PhoneMissed, UserRoundPlus } from 'lucide-react';
import { ContactAvatar } from '@ui/components/ContactAvatar';
import { EmptyState } from '@ui/components/EmptyState';
import { cn } from '@utils/css';

export const DialerHistory: React.FC = () => {
  const myNumber = useMyPhoneNumber();
  const { getDisplayByNumber } = useContactActions();
  const { initializeCall } = useCall();
  const calls = useDialHistory();
  const contacts = useContacts();
  const history = useHistory();
  const [t] = useTranslation();

  const handleCall = (phoneNumber) => {
    initializeCall(phoneNumber);
  };

  // To display the name, force a re-render when we get contacts | issue #432
  const getDisplay = useCallback(
    (number: string) => (contacts.length ? getDisplayByNumber(number) : number),
    [contacts, getDisplayByNumber],
  );

  if (!calls?.length) {
    return (
      <EmptyState
        icon={<Clock size={28} />}
        label={t('DIALER.NO_HISTORY')}
        sublabel={t('DIALER.NO_HISTORY_SUB')}
      />
    );
  }

  return (
    <div className="px-4">
      <List>
        {calls.map((call: CallHistoryItem) => {
          const isOutgoing = call.transmitter === myNumber;
          const otherNumber = isOutgoing ? call.receiver : call.transmitter;
          const isMissed = !isOutgoing && !call.is_accepted;
          const display = call.isAnonymous ? t('DIALER.ANONYMOUS') : getDisplay(otherNumber);

          return (
            <ListItem
              key={call.id}
              primaryText={
                <span className={cn(isMissed && 'text-red-500')}>{display}</span>
              }
              secondaryText={
                <span className="flex items-center gap-1">
                  {isMissed ? (
                    <PhoneMissed size={13} className="text-red-500" />
                  ) : isOutgoing ? (
                    <PhoneForwarded size={13} className="text-green-500" />
                  ) : (
                    <PhoneIncoming size={13} className="text-green-500" />
                  )}
                  {dayjs().to(dayjs.unix(parseInt(call.start)))}
                </span>
              }
              startElement={<ContactAvatar name={display} />}
              endElement={
                <div>
                  <NPWDButton
                    onClick={() => handleCall(otherNumber)}
                    size="icon"
                    variant="ghost"
                    className="rounded-full"
                    disabled={call.isAnonymous}
                  >
                    <Phone size={20} />
                  </NPWDButton>
                  {!call.isAnonymous && getDisplay(otherNumber) === otherNumber && (
                    <NPWDButton
                      onClick={() =>
                        history.push(`/contacts/-1?addNumber=${otherNumber}&referal=/phone/contacts`)
                      }
                      size="icon"
                      variant="ghost"
                      className="rounded-full"
                    >
                      <UserRoundPlus size={20} />
                    </NPWDButton>
                  )}
                </div>
              }
            />
          );
        })}
      </List>
    </div>
  );
};
