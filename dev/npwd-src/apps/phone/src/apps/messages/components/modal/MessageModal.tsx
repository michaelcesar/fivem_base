import { useEffect, useState } from 'react';
import { Slide, Paper, Typography, Button, Box, Tooltip, Skeleton } from '@mui/material';
import PersonAddIcon from '@mui/icons-material/PersonAdd';
import GroupIcon from '@mui/icons-material/Group';
import useMessages from '../../hooks/useMessages';
import Conversation, { CONVERSATION_ELEMENT_ID } from './Conversation';
import MessageSkeletonList from './MessageSkeletonList';
import MessageModalSkeleton from './MessageModalSkeleton';
import { useHistory, useLocation, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useContactActions } from '../../../contacts/hooks/useContactActions';
import { useMessagesState } from '../../hooks/state';
import { makeStyles } from '@mui/styles';
import { useMessageAPI } from '../../hooks/useMessageAPI';
import { useCall } from '@os/call/hooks/useCall';
import { useMessageActions } from '../../hooks/useMessageActions';
import GroupDetailsModal from './GroupDetailsModal';
import Backdrop from '@ui/components/Backdrop';
import { useMyPhoneNumber } from '@os/simcard/hooks/useMyPhoneNumber';
import { usePhone } from '@os/phone/hooks';
import { Phone, ArrowLeft } from 'lucide-react';
import MessageInput from '../form/MessageInput';
import AudioContextMenu from './AudioContextMenu';
import MessageContextMenu from './MessageContextMenu';
import { useQueryParams } from '@common/hooks/useQueryParams';
import { ContactAvatar } from '@ui/components/ContactAvatar';

const MAX_HEADER_CHARS = 80;
const MINIMUM_LOAD_TIME = 600;

const useStyles = makeStyles({
  tooltip: {
    fontSize: 12,
  },
  modalHide: {
    display: 'none',
  },
});

// abandon all hope ye who enter here
export const MessageModal = () => {
  const [t] = useTranslation();
  const classes = useStyles();
  const history = useHistory();
  const { pathname } = useLocation();
  const { groupId } = useParams<{ groupId: string }>();
  const { activeMessageConversation, setActiveMessageConversation } = useMessages();
  const { fetchMessages } = useMessageAPI();
  const { getLabelOrContact, getConversationParticipant } = useMessageActions();
  const { initializeCall } = useCall();

  const { getContactByNumber } = useContactActions();
  const [messages, setMessages] = useMessagesState();

  const [isLoaded, setLoaded] = useState(false);
  const [isGroupModalOpen, setIsGroupModalOpen] = useState(false);
  const [contextMenuOpen, setContextMenuOpen] = useState(false);
  const [audioContextMenuOpen, setAudioContextMenuOpen] = useState(false);

  const query = useQueryParams();
  const referalImage = query?.image || null;
  const referalNote = query?.note || null;

  const { ResourceConfig } = usePhone();

  const myPhoneNumber = useMyPhoneNumber();

  useEffect(() => {
    if (groupId) {
      fetchMessages(groupId, 0);
    }
  }, [groupId, fetchMessages]);

  useEffect(() => {
    let timeout;
    if (activeMessageConversation && messages) {
      timeout = setTimeout(() => {
        setLoaded(true);
      }, MINIMUM_LOAD_TIME);
      return;
    }
    setLoaded(false);
  }, [activeMessageConversation, messages]);

  const closeModal = () => {
    setMessages(null);
    history.push('/messages');
  };

  const openGroupModal = () => {
    setIsGroupModalOpen(true);
  };

  const closeGroupModal = () => {
    setIsGroupModalOpen(false);
  };

  useEffect(() => {
    if (!groupId) return;
    setActiveMessageConversation(parseInt(groupId, 10));
  }, [groupId, setActiveMessageConversation]);

  useEffect(() => {
    if (isLoaded) {
      const element = document.getElementById(CONVERSATION_ELEMENT_ID);
      if (element) {
        element.scrollTop = element.scrollHeight;
      }
    }
  }, [isLoaded]);

  // We need to wait for the active conversation to be set.
  if (!activeMessageConversation) {
    return <MessageModalSkeleton />;
  }

  let header = getLabelOrContact(activeMessageConversation);
  // don't allow too many characters, it takes too much room
  const truncatedHeader = `${header.slice(0, MAX_HEADER_CHARS).trim()}...`;
  header = header.length > MAX_HEADER_CHARS ? truncatedHeader : header;

  const handleAddContact = (number: string) => {
    const exists = getContactByNumber(number);
    const referal = encodeURIComponent(pathname);
    if (exists) {
      return history.push(`/contacts/${exists.id}/?referal=${referal}`);
    }
    return history.push(`/contacts/-1/?addNumber=${number}&referal=${referal}`);
  };

  // This only gets used for 1 on 1 conversations
  let conversationList = activeMessageConversation.conversationList.split('+');
  conversationList = conversationList.filter((targetNumber) => targetNumber !== myPhoneNumber);
  // Add optionals here out of abundancy of caution for phone number being null
  // Participant is not participant ots the local phone number
  let targetNumber: string =
    conversationList.length > 0 ? conversationList[0] : activeMessageConversation.participant;

  const doesContactExist = getConversationParticipant(activeMessageConversation.conversationList);
  return (
    <Slide direction="left" in={!!activeMessageConversation}>
      {/* Server: was `space-between flex h-full w-full flex-col` - `space-between` is not a
          Tailwind class (the utility is `justify-between`), so it never did anything. Replaced
          with `overflow-hidden`, which does the job that was actually wanted here: the column is
          exactly the height of the screen and neither the header nor the input bar can be pushed
          past its edges by a tall conversation. */}
      <div className="flex h-full w-full flex-col overflow-hidden">
        {isGroupModalOpen && <Backdrop />}
        <Box
          display="flex"
          paddingX={1}
          paddingY={1}
          justifyContent="space-between"
          alignItems="center"
          gap={1}
          className="shrink-0 border-b border-neutral-200 bg-[#F7F7F7] dark:border-neutral-700 dark:bg-[#202C33]"
          sx={{ borderRadius: 0 }}
        >
          <button onClick={closeModal} className="rounded-full p-2 hover:bg-black/5 dark:hover:bg-white/10">
            <ArrowLeft size={26} className="text-black dark:text-white" />
          </button>
          <ContactAvatar name={header} size={36} />
          <div className="flex flex-1 flex-col overflow-hidden pl-1">
            <Typography noWrap variant="body1" className="font-semibold text-black dark:text-white">
              {header}
            </Typography>
            {!activeMessageConversation.isGroupChat && (
              <Typography noWrap variant="caption" className="text-neutral-500 dark:text-neutral-400">
                {targetNumber}
              </Typography>
            )}
          </div>
          {!activeMessageConversation.isGroupChat && (
            <Tooltip
              classes={{ tooltip: classes.tooltip }}
              title={`${t('GENERIC.CALL')} ${targetNumber}`}
              placement="bottom"
            >
              <button
                onClick={() => initializeCall(targetNumber)}
                className="rounded-full p-3 hover:bg-black/5 dark:hover:bg-white/10"
              >
                <Phone size={18} className="text-[#25D366]" />
              </button>
            </Tooltip>
          )}
          {activeMessageConversation.isGroupChat ? (
            <Button>
              <GroupIcon onClick={openGroupModal} fontSize="large" className="text-black dark:text-white" />
            </Button>
          ) : !activeMessageConversation.isGroupChat && !doesContactExist ? (
            <Button>
              <PersonAddIcon
                onClick={() => handleAddContact(targetNumber)}
                fontSize="large"
                className="text-black dark:text-white"
              />
            </Button>
          ) : !activeMessageConversation.isGroupChat && doesContactExist ? null : null}
        </Box>
        <div className="min-h-0 flex-1 overflow-hidden">
          {isLoaded && activeMessageConversation && ResourceConfig ? (
            <Conversation
              isVoiceEnabled={ResourceConfig.voiceMessage.enabled}
              messages={messages}
              activeMessageGroup={activeMessageConversation}
            />
          ) : (
            // Server: `overflow-hidden`, not `overflow-y-auto` - the placeholder bubbles add up
            // to more than the screen, and a skeleton nobody is meant to scroll should not grow
            // its own scrollbar while it waits.
            <div className="h-full overflow-hidden">
              <MessageSkeletonList />
            </div>
          )}
        </div>
        {/* Server: `shrink-0` - the header and the input bar are fixed furniture; only the
            conversation area between them gives way when there is not enough room. */}
        <div className="shrink-0">
          <div>
            {audioContextMenuOpen ? (
              <AudioContextMenu onClose={() => setAudioContextMenuOpen(false)} />
            ) : !isLoaded ? (
              // Server: `MessageInput` itself returns `null` until `messageConversation.id` is
              // set, which briefly isn't the case while `isLoaded` is still false - the input
              // bar disappeared entirely during that window instead of showing *something*.
              <div className="flex items-center gap-2 bg-[#F7F7F7] px-3 py-2 dark:bg-[#202C33]">
                <Skeleton variant="circular" width={24} height={24} />
                <Skeleton variant="rounded" className="flex-1" height={36} />
                <Skeleton variant="circular" width={24} height={24} />
              </div>
            ) : (
              <MessageInput
                messageGroupName={activeMessageConversation.participant}
                messageConversation={activeMessageConversation}
                onAddImageClick={() => setContextMenuOpen(true)}
                onVoiceClick={() => setAudioContextMenuOpen(true)}
                voiceEnabled={ResourceConfig.voiceMessage.enabled}
              />
            )}
          </div>
          <MessageContextMenu
            messageGroup={activeMessageConversation}
            isOpen={contextMenuOpen}
            onClose={() => setContextMenuOpen(false)}
            image={referalImage}
            note={referalNote}
          />
        </div>

        <GroupDetailsModal
          open={isGroupModalOpen}
          onClose={closeGroupModal}
          conversationList={activeMessageConversation.conversationList}
          addContact={handleAddContact}
        />
      </div>
    </Slide>
  );
};
