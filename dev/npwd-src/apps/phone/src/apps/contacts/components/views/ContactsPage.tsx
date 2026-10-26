import React from 'react';
import { ContactList } from '../List/ContactList';
import { AppTitle } from '@ui/components/AppTitle';
import { useApp } from '@os/apps/hooks/useApps';
import { useContacts } from '../../hooks/state';
import { useTranslation } from 'react-i18next';

export const ContactPage: React.FC = () => {
  const contactsApp = useApp('CONTACTS');
  const contacts = useContacts();
  const [t] = useTranslation();

  return (
    <div className="">
      <AppTitle app={contactsApp} sublabel={t('CONTACTS.SUBLABEL', { count: contacts?.length ?? 0 })} />
      <ContactList />
    </div>
  );
};