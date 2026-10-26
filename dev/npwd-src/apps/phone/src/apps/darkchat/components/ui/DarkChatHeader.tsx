import React, { useState } from 'react';
import { Box, IconButton, Paper, Button } from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import EditIcon from '@mui/icons-material/Edit';
import CheckIcon from '@mui/icons-material/Check';
import styled from '@emotion/styled';
import { Hash } from 'lucide-react';
import { DEEPWEB_SURFACE } from '../../darkchat.theme';
import { useHistory } from 'react-router-dom';
import { useActiveDarkchatValue } from '../../state/state';
import { useDarkchatAPI } from '../../hooks/useDarkchatAPI';
import { useMyPhoneNumber } from '@os/simcard/hooks/useMyPhoneNumber';
import { TextField } from '@ui/components/Input';
import { useModal } from '@apps/darkchat/hooks/useModal';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';
import { useTranslation } from 'react-i18next';

// Server: flat, no elevation, and painted with DeepWeb's own surface colour rather than the
// phone theme's background - matching Messages' header/input-bar pairing. Paper's default drop
// shadow drew a line under this bar.
const Header = styled(Paper)(() => ({
  backgroundColor: DEEPWEB_SURFACE,
  height: '60px',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'space-between',
  borderRadius: 0,
  boxShadow: 'none',
  color: '#ffffff',
}));

const LeaveButton = styled(Button)(({ theme }) => ({
  color: theme.palette.text.primary,
}));

const DarkChatHeader: React.FC = () => {
  const activeConversation = useActiveDarkchatValue();
  const { setOwnerModal } = useModal();
  const { leaveChannel, updateChannelLabel } = useDarkchatAPI();
  const { goBack } = useHistory();
  const myPhoneNumber = useMyPhoneNumber();
  const [t] = useTranslation();

  const [isEditing, setIsEditing] = useState<boolean>(false);
  const [label, setLabel] = useState<string>(activeConversation.label);

  const handleLeaveChannel = () => {
    leaveChannel(activeConversation.id);
  };

  const openOwnerModal = () => {
    setOwnerModal(true);
  };

  const handleUpdateLabel = () => {
    setIsEditing(false);
    if (label === activeConversation.label) return setLabel(activeConversation.label);
    if (!label.trim()) return setLabel(activeConversation.label);

    updateChannelLabel({
      channelId: activeConversation.id,
      label,
    });
  };

  const isOwner = myPhoneNumber === activeConversation.owner;

  return (
    <Header>
      {/* Server: same header shape as Messages' MessageModal - back arrow, a circular avatar,
          then the name with a quieter second line under it. The channel used to be a single
          26px line with nothing else, which is what made this screen read as unfinished next to
          every other conversation view on the phone. */}
      <Box display="flex" alignItems="center" flexDirection="row" gap={1} minWidth={0}>
        <IconButton onClick={goBack}>
          <ArrowBackIcon />
        </IconButton>
        <div className="flex h-9 w-9 flex-none items-center justify-center rounded-full bg-neutral-800 text-neutral-400">
          <Hash size={16} />
        </div>
        <Box display="flex" gap={1} alignItems="center" minWidth={0}>
          {isEditing ? (
            <TextField
              inputProps={{ style: { fontSize: 15 } }}
              value={label}
              onChange={(e) => setLabel(e.currentTarget.value)}
            />
          ) : (
            <div className="min-w-0">
              <p className="m-0 truncate text-sm font-medium text-white">{label}</p>
              <p className="m-0 truncate text-xs text-neutral-500">
                {activeConversation.identifier}
              </p>
            </div>
          )}
          {isOwner && (
            <Box>
              {isEditing ? (
                <IconButton disableFocusRipple disableTouchRipple onClick={handleUpdateLabel}>
                  <CheckIcon />
                </IconButton>
              ) : (
                <IconButton
                  disableFocusRipple
                  disableTouchRipple
                  onClick={() => setIsEditing(true)}
                >
                  <EditIcon />
                </IconButton>
              )}
            </Box>
          )}
        </Box>
      </Box>
      <Box pr={2}>
        {isOwner ? (
          <IconButton onClick={openOwnerModal}>
            <AdminPanelSettingsIcon />
          </IconButton>
        ) : (
          <LeaveButton onClick={handleLeaveChannel}>{t('DARKCHAT.LEAVE')}</LeaveButton>
        )}
      </Box>
    </Header>
  );
};

export default DarkChatHeader;
