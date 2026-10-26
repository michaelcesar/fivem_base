import { Slide, Paper } from '@mui/material';
import React, { useEffect, useState } from 'react';
import { ArrowLeft, Trash2 } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { NPWDButton } from '@npwd/keyos';
import { NPWDInput, NPWDTextarea } from '@ui/components/Input';
import { useModalVisible, useSelectedNote } from '../hooks/state';
import { useHistory, useLocation } from 'react-router-dom';
import { useNotesAPI } from '../hooks/useNotesAPI';

const MAX_CONTENT_LENGTH = 250;

export const NoteModal: React.FC = () => {
  const { addNewNote, deleteNote, updateNote } = useNotesAPI();
  const [modalVisible, setModalVisible] = useModalVisible();
  const [t] = useTranslation();
  const [selectedNote, setSelectedNote] = useSelectedNote();
  const [noteTitle, setNoteTitle] = useState('');
  const [noteContent, setNoteContent] = useState('');

  const history = useHistory();
  const location = useLocation();

  const isNewNote = !Boolean(selectedNote?.id);

  useEffect(() => {
    if (selectedNote !== null) {
      setNoteContent(selectedNote.content);
      setNoteTitle(selectedNote.title);
    }
  }, [selectedNote]);

  // Server: iPhone's own Notes app has no separate title field - the title is just the first
  // line of the note. Matching that here also fixes a real bug: the save button used to stay
  // silently disabled (no error, nothing visible) whenever the title field was left empty, which
  // read as "the save button doesn't work" since most people type the content first.
  const resolveTitle = () => noteTitle.trim() || noteContent.trim().slice(0, 30) || t('NOTES.UNTITLED');

  const handleDeleteNote = () => {
    deleteNote({ id: selectedNote.id })
      .then(() => setModalVisible(false))
      .catch(console.error);
  };

  const handleSave = () => {
    const save = isNewNote
      ? addNewNote({ title: resolveTitle(), content: noteContent })
      : updateNote({ id: selectedNote.id, title: resolveTitle(), content: noteContent });

    save
      .then(() => {
        if (isNewNote && location.search) history.push(location.pathname);
        setModalVisible(false);
      })
      .catch(console.error);
  };

  const handleClose = () => setModalVisible(false);

  const handleClearContent = () => {
    setSelectedNote(null);
    if (location.search) history.push(location.pathname);
  };

  if (selectedNote === null) return null;

  return (
    <Slide
      direction="left"
      in={modalVisible}
      mountOnEnter
      unmountOnExit
      onExited={handleClearContent}
    >
      {/* elevation={0} - Paper's default drop shadow drew a line across the top of the note
          editor, reading as a stray border above the header. Same cause as the photo view. */}
      <Paper
        square
        elevation={0}
        className="absolute z-20 flex h-full w-full flex-col bg-neutral-100 dark:bg-neutral-900"
      >
        {/* Server: a subtle grey, one step off the body behind it, and no bottom border - the
            header should read as a soft block rather than a separate strip. Tried the app's own
            yellow first; it was too loud for a header this size. */}
        <div className="flex items-center gap-1 bg-neutral-200 px-1 py-1 dark:bg-neutral-800">
          <button
            onClick={handleClose}
            className="rounded-full p-2 hover:bg-black/5 dark:hover:bg-white/10"
          >
            <ArrowLeft size={22} className="text-black dark:text-white" />
          </button>
          {/* Server: `font-medium`, not `font-semibold` - the header label was heavier than the
              rest of the phone's own headers. */}
          <span className="font-medium text-black dark:text-white">
            {isNewNote ? t('NOTES.NEW_NOTE') : t('NOTES.EDIT_NOTE')}
          </span>
        </div>

        <div className="flex flex-1 flex-col gap-2 overflow-auto p-3">
          {/* Server: was `text-lg font-semibold`, which made this the only input on the phone
              bigger and heavier than the shared style - against NPWDInput's own neutral-200 fill
              that reads as a boxed-in, bolder field than everything around it. Left at the
              component's own size and weight; the title is distinguished by being first, not by
              being louder. */}
          <NPWDInput
            placeholder={t('NOTES.TITLE_PLACEHOLDER')}
            className="font-medium placeholder:font-normal"
            maxLength={25}
            value={noteTitle}
            onChange={(e) => setNoteTitle(e.target.value)}
          />
          <NPWDTextarea
            placeholder={t('NOTES.CONTENT_PLACEHOLDER')}
            className="min-h-0 flex-1 resize-none text-base"
            maxLength={MAX_CONTENT_LENGTH}
            value={noteContent}
            onChange={(e) => setNoteContent(e.target.value)}
          />
          <span className="self-end text-xs text-neutral-400">
            {noteContent.length}/{MAX_CONTENT_LENGTH}
          </span>
        </div>

        <div className="flex gap-2 border-t border-neutral-200 p-3 dark:border-neutral-700">
          {!isNewNote && (
            <NPWDButton
              onClick={handleDeleteNote}
              className="flex items-center justify-center gap-1.5 bg-red-500"
            >
              <Trash2 size={16} />
              {t('GENERIC.DELETE')}
            </NPWDButton>
          )}
          <NPWDButton className="flex-1 bg-[#25D366]" onClick={handleSave}>
            {t('GENERIC.SAVE')}
          </NPWDButton>
        </div>
      </Paper>
    </Slide>
  );
};
