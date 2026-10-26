import React, { useState } from 'react';
import { Add, Delete } from '@mui/icons-material';
import { useCheckedConversationsValue, useIsEditing } from '../../hooks/state';
import { useMessageAPI } from '../../hooks/useMessageAPI';
import { toggleKeys } from '@ui/components';
import { ConfirmDialog } from '@ui/components/ConfirmDialog';
import { useTranslation } from 'react-i18next';
import { cn } from '@utils/css';

interface NewMessageGroupButtonProps {
  onClick(): void;
}

export const NewMessageGroupButton: React.FC<NewMessageGroupButtonProps> = ({ onClick }) => {
  const checkedConversations = useCheckedConversationsValue();
  const [isEditing, setIsEditing] = useIsEditing();
  const { deleteConversation } = useMessageAPI();
  const [t] = useTranslation();
  const [confirmOpen, setConfirmOpen] = useState(false);

  const handleDeleteConversations = () => {
    deleteConversation(checkedConversations);
    setIsEditing(false);
    setConfirmOpen(false);
  };

  return (
    <>
      <button
        className={cn(
          'absolute bottom-10 right-5 flex items-center justify-center rounded-md p-2 text-white',
          // In editing mode this same button becomes the delete action, so it takes the
          // destructive red used by ConfirmDialog/ContextMenu. Otherwise it is the "new
          // conversation" action and uses the phone's standard blue accent (the same sky-500
          // Twitter's own buttons use), not the green it inherited from the Messages theme.
          isEditing ? 'bg-red-500 hover:bg-red-600' : 'bg-sky-500 hover:bg-sky-600',
          'disabled:opacity-50',
        )}
        color="primary"
        disabled={isEditing && checkedConversations.length === 0}
        onClick={!isEditing ? onClick : () => setConfirmOpen(true)}
        onMouseUp={() => {
          toggleKeys(false);
        }}
      >
        {!isEditing ? <Add /> : <Delete />}
      </button>
      <ConfirmDialog
        open={confirmOpen}
        title={t('MESSAGES.DELETE_CONVERSATION_CONFIRM_TITLE', { count: checkedConversations.length })}
        confirmLabel={t('GENERIC.DELETE')}
        cancelLabel={t('GENERIC.CANCEL')}
        onConfirm={handleDeleteConversations}
        onCancel={() => setConfirmOpen(false)}
      />
    </>
  );
};

export default NewMessageGroupButton;
