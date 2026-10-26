import React, { useEffect } from 'react';
import styled from '@emotion/styled';
import { Box, Typography, useTheme } from '@mui/material';
import MailOutlineIcon from '@mui/icons-material/MailOutline';
import { useMailsValue, useSetSelectedMail, useSetModalVisible, useSetMail, getMailItems } from '../atoms/mail-atoms';
import { Mail } from '../types/mail';
import { useMailAPI } from '../hooks/useMailAPI';
import { useMailActions } from '../hooks/useMailActions';
import { useNuiEvent } from '../hooks/useNuiEvent';

// Server: near-square cards matching npwd_qbx_garages/npwd_fleeca's shared visual language,
// instead of the stock MUI ListItemButton/divider look.
const MailCard = styled.div<{ isDarkMode: boolean; unread: boolean }>`
  background: ${({ isDarkMode }) => (isDarkMode ? 'rgb(38 38 38 / 1)' : '#ffffff')};
  border-radius: 8px;
  border-left: 4px solid ${({ unread }) => (unread ? '#ed6c02' : 'transparent')};
  margin-bottom: 0.7rem;
  padding: 0.9rem 1rem;
  cursor: pointer;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.12);
`;

const CardTop = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 0.8rem;
`;

const Sender = styled.div<{ isDarkMode: boolean; unread: boolean }>`
  font-size: 0.92rem;
  font-weight: ${({ unread }) => (unread ? 700 : 600)};
  color: ${({ isDarkMode }) => (isDarkMode ? '#ffffff' : '#1a201c')};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
`;

const DateLabel = styled.div<{ isDarkMode: boolean }>`
  flex-shrink: 0;
  font-size: 0.75rem;
  color: ${({ isDarkMode }) => (isDarkMode ? 'rgba(255, 255, 255, 0.55)' : 'rgba(0, 0, 0, 0.5)')};
`;

const Subject = styled.div<{ isDarkMode: boolean }>`
  margin-top: 0.25rem;
  font-size: 0.85rem;
  color: ${({ isDarkMode }) => (isDarkMode ? 'rgba(255, 255, 255, 0.75)' : 'rgba(0, 0, 0, 0.65)')};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
`;

// Server: matches the core NPWD phone's own empty-state convention (icon in a rounded
// background, bold label, muted sublabel) - this app can't import that shared React component
// (separate Module Federation build), so it's reproduced here with this app's own primitives.
const EmptyIconCircle = styled.div<{ isDarkMode: boolean }>`
  display: flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: 9999px;
  margin: 0 auto 12px auto;
  background: ${({ isDarkMode }) => (isDarkMode ? 'rgb(64 64 64 / 1)' : 'rgb(229 229 229 / 1)')};
  color: ${({ isDarkMode }) => (isDarkMode ? 'rgb(163 163 163 / 1)' : 'rgb(163 163 163 / 1)')};
`;

const MailList = () => {
  const mails = useMailsValue();
  const theme = useTheme();
  const isDarkMode = theme.palette.mode === 'dark';
  const setMails = useSetMail();
  const setMail = useSetSelectedMail();
  const setModalVisible = useSetModalVisible();
  const { updateRead } = useMailAPI();
  const { newMail } = useMailActions();

  useEffect(() => {
    getMailItems()
      .then(val => setMails(val))
      .catch(console.error);
  }, []);

  useNuiEvent<Mail[]>('npwd_qbx_mail', 'newMail', (data) => {
    if (!data) return;

    newMail(data[0]);
  });

  const handleMailModal = (mail: Mail) => {
    if (!mail.read) {
      updateRead(mail.mailid);
    }

    setMail(mail);
    setModalVisible(true);
  };

  const mailDate = (dateData: number) => {
    const date = new Date(dateData);
    return (
      ('0' + date.getDate()).slice(-2) +
      '/' +
      ('0' + (date.getMonth() + 1)).slice(-2) +
      '/' +
      date.getFullYear()
    );
  };

  if (!mails || mails.length === 0) {
    return (
      <Box sx={{ textAlign: 'center', mt: 6 }}>
        <EmptyIconCircle isDarkMode={isDarkMode}>
          <MailOutlineIcon fontSize="medium" />
        </EmptyIconCircle>
        <Typography fontSize={16} fontWeight={600} color={isDarkMode ? 'white' : 'black'}>
          Nenhuma correspondência ainda
        </Typography>
        <Typography fontSize={13} sx={{ opacity: 0.6, mt: 0.5 }} color={isDarkMode ? 'white' : 'black'}>
          As cartas que você receber vão aparecer aqui.
        </Typography>
      </Box>
    );
  }

  return (
    <Box>
      {mails.map((mail: Mail) => (
        <MailCard
          key={mail.mailid}
          isDarkMode={isDarkMode}
          unread={mail.read === 0}
          onClick={() => handleMailModal(mail)}
        >
          <CardTop>
            <Sender isDarkMode={isDarkMode} unread={mail.read === 0}>{mail.sender}</Sender>
            <DateLabel isDarkMode={isDarkMode}>{mailDate(mail.date)}</DateLabel>
          </CardTop>
          <Subject isDarkMode={isDarkMode}>{mail.subject}</Subject>
        </MailCard>
      ))}
    </Box>
  );
};

export default MailList;
