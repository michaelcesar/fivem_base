import { Avatar, Box, IconButton, Paper, Typography } from '@mui/material';
import MoreVertIcon from '@mui/icons-material/MoreVert';
import { makeStyles } from '@mui/styles';
import React, { useState } from 'react';
import { Message } from '@typings/messages';
import StyledMessage from '../ui/StyledMessage';
import { PictureResponsive } from '@ui/components/PictureResponsive';
import { PictureReveal } from '@ui/components/PictureReveal';
import { useMyPhoneNumber } from '@os/simcard/hooks/useMyPhoneNumber';
import MessageBubbleMenu from './MessageBubbleMenu';
import { useSetSelectedMessage } from '../../hooks/state';
import MessageEmbed from '../ui/MessageEmbed';
import { useContactActions } from '../../../contacts/hooks/useContactActions';
import dayjs from 'dayjs';
import { MoreHorizontal, MoreVertical } from 'lucide-react';
import { cn } from '@utils/css';
import { calendarPickerSkeletonClasses } from '@mui/lab';

// Server: WhatsApp's own two colours - soft green (#DCF8C6 light / #005C4B dark) for your own
// messages, white/dark grey (#202C33 dark) for everyone else's - instead of the iOS blue/
// light-grey pair this used before. Written as literal Tailwind arbitrary-value classes
// throughout this file rather than built from a shared constant, since Tailwind's JIT scanner
// needs the literal class string present in the source to generate it.
const useStyles = makeStyles((theme) => ({
  mySms: {
    margin: theme.spacing(1),
    padding: '6px',
    height: 'auto',
    width: 'auto',
    float: 'left',
    borderRadius: '8px',
    textOverflow: 'ellipsis',
  },
  sms: {
    padding: '6px',
    width: 'auto',
    float: 'left',
    minWidth: 'auto',
    maxWidth: 'auto',
    height: 'auto',
    borderRadius: '8px',
    textOverflow: 'ellipsis',
  },
  myAudioSms: {
    float: 'left',
    margin: theme.spacing(1),
    padding: '6px',
    minWidth: '60%',
    maxWidth: '80%',
    borderRadius: '12px',
    textOverflow: 'ellipsis',
  },
  audioSms: {
    float: 'left',
    width: 'auto',
    marginLeft: 5,
    minWidth: '60%',
    maxWidth: '80%',
    borderRadius: '15px',
    textOverflow: 'ellipsis',
  },
  message: {
    wordBreak: 'break-word',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
}));

const isImage = (url) => {
  return /(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|png|jpeg|gif|webp)/g.test(url);
};

interface MessageBubbleProps {
  message: Message;
}

export const MessageBubble: React.FC<MessageBubbleProps> = ({ message }) => {
  const classes = useStyles();
  const [menuOpen, setMenuOpen] = useState(false);
  const { getContactByNumber } = useContactActions();

  const setSelectedMessage = useSetSelectedMessage();
  const openMenu = () => {
    setMenuOpen(true);
    setSelectedMessage(message);
  };
  const myNumber = useMyPhoneNumber();
  const isMine = message.author === myNumber;

  let parsedEmbed;
  if (message?.embed) {
    parsedEmbed = JSON.parse(message?.embed);
  }

  const getContact = () => {
    return getContactByNumber(message.author);
  };

  const isMessageImage = isImage(message.message);

  // Server: WhatsApp layout - your own messages align right in soft green, everyone else's
  // align left in white/dark grey, each with a small pointed "tail" on the outer top corner,
  // matching WhatsApp's own bubble shape instead of a plain fully-rounded pill.
  if (message.is_embed && parsedEmbed.type === 'audio') {
    return (
      <div>
        <Box display="flex" ml={1} alignItems="stretch" mt={1} justifyContent={isMine ? 'flex-end' : 'flex-start'}>
          <Paper
            className={cn(
              isMine ? classes.myAudioSms : classes.audioSms,
              isMine
                ? 'bg-[#DCF8C6] text-black dark:bg-[#005C4B] dark:text-white'
                : 'bg-white text-black dark:bg-[#202C33] dark:text-white',
            )}
            variant="outlined"
          >
            <MessageEmbed
              type={parsedEmbed.type}
              embed={parsedEmbed}
              isMine={isMine}
              message={message.message}
              openMenu={openMenu}
            />
            {!isMine && (
              <Typography fontWeight="bold" fontSize={14} color="text.secondary">
                {getContact()?.display ?? message.author}
              </Typography>
            )}
            <p className="mb-1 pl-2 text-xs text-neutral-500 dark:text-neutral-400">{dayjs.unix(message.createdAt).fromNow()}</p>
          </Paper>
        </Box>
        <MessageBubbleMenu open={menuOpen} handleClose={() => setMenuOpen(false)} />
      </div>
    );
  }

  const showVertIcon = isMine || isMessageImage;

  return (
    <>
      <div className={cn('mb-3 px-3 py-1 flex', isMine ? 'justify-end' : 'justify-start')}>
        <div className={cn('flex flex-col max-w-[80%]', isMine && 'items-end')}>
          {!isMine && (
            <p className="px-2 text-xs font-medium text-neutral-500 dark:text-neutral-400">
              {getContact()?.display ?? message.author}
            </p>
          )}
          {/* Server: the delete/menu button lives in its own row with just the bubble - it used
          to share `items-center` with the whole name+bubble+timestamp column, which centred it
          against the wrong (taller) box and left it looking stuck near the top. */}
          <div className={cn('flex items-center', isMine && 'flex-row-reverse')}>
            <div
              className={cn(
                'relative flex items-center rounded-lg px-3 py-2 text-black shadow-sm dark:text-white',
                isMine
                  ? "rounded-tr-none bg-[#DCF8C6] before:absolute before:-right-2 before:top-0 before:h-0 before:w-0 before:border-l-[8px] before:border-t-[8px] before:border-l-transparent before:border-t-[#DCF8C6] before:content-[''] dark:bg-[#005C4B] dark:before:border-t-[#005C4B]"
                  : "rounded-tl-none bg-white before:absolute before:-left-2 before:top-0 before:h-0 before:w-0 before:border-r-[8px] before:border-t-[8px] before:border-r-transparent before:border-t-white before:content-[''] dark:bg-[#202C33] dark:before:border-t-[#202C33]",
              )}
            >
              {message.is_embed ? (
                <>
                  <MessageEmbed
                    type={parsedEmbed.type}
                    embed={parsedEmbed}
                    isMine={isMine}
                    message={message.message}
                    openMenu={openMenu}
                  />
                </>
              ) : (
                <div>
                  {isMessageImage ? (
                    <PictureReveal>
                      <PictureResponsive src={message.message} alt="message multimedia" />
                    </PictureReveal>
                  ) : (
                    <p className="text-sm">{message.message}</p>
                  )}
                </div>
              )}
            </div>
            {showVertIcon && (
              <button onClick={openMenu} className="mx-1 text-neutral-400">
                <MoreVertical size={18} />
              </button>
            )}
          </div>
          <p className={cn('px-2 text-xs text-neutral-400', isMine && 'text-right')}>
            {dayjs.unix(message.createdAt).fromNow()}
          </p>
        </div>
      </div>
      <MessageBubbleMenu
        message={message}
        isImage={isMessageImage}
        open={menuOpen}
        handleClose={() => setMenuOpen(false)}
      />
    </>
  );
};
