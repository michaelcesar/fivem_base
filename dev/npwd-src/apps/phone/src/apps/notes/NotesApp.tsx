import React, { useEffect } from 'react';
import { AppWrapper } from '@ui/components';
import { AppContent } from '@ui/components/AppContent';
import { AppTitle } from '@ui/components/AppTitle';
import { useApp } from '@os/apps/hooks/useApps';
import NoteList from './list/NoteList';
import { NoteModal } from './modal/NoteModal';
import { Fab } from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import useStyles from './notes.styles';
import { NotesThemeProvider } from './providers/NotesThemeProvider';
import {NOTES_APP_PRIMARY_COLOR} from "./notes.theme";
import { Route } from 'react-router-dom';
import { useSetModalVisible, useSetSelectedNote } from './hooks/state';
import { LoadingSpinner } from '@ui/components/LoadingSpinner';
import { useQueryParams } from '@common/hooks/useQueryParams';
import { AddNoteExportData } from '@typings/notes';
import { useTranslation } from 'react-i18next';
import { useNotesValue } from './hooks/state';

export const NotesApp: React.FC = () => {
  const classes = useStyles();
  const notesApp = useApp('NOTES');
  const [t] = useTranslation();
  const notes = useNotesValue();
  const setSelectedNote = useSetSelectedNote();
  const setModalVisible = useSetModalVisible();

  const onClickCreate = () => {
    setSelectedNote({ title: '', content: '' });
    setModalVisible(true);
  };

  const { title, content } = useQueryParams<AddNoteExportData>({ title: '', content: '' });

  useEffect(() => {
    // Althought this interface kinda blows for readability,
    // whenever we have
    if (title || content) {
      setModalVisible(true);
      setSelectedNote({ title, content });
    } else {
      setModalVisible(false);
      setSelectedNote(null);
    }
  }, [setModalVisible, title, content, setSelectedNote]);

  return (
    <NotesThemeProvider>
      <AppWrapper id="notes-app">
        <AppTitle app={notesApp} sublabel={t('NOTES.SUBLABEL', { count: notes?.length ?? 0 })} />
        <NoteModal />
        <AppContent>
          <React.Suspense fallback={<LoadingSpinner />}>
            <Route path="/notes" component={NoteList} />
          </React.Suspense>
        </AppContent>
        <Fab className={classes.absolute} onClick={onClickCreate}>
          <AddIcon style={{ color: NOTES_APP_PRIMARY_COLOR}}/>
        </Fab>
      </AppWrapper>
    </NotesThemeProvider>
  );
};
