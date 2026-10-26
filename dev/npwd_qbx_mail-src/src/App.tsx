import React from 'react';
import { useHistory } from 'react-router-dom';
import styled from '@emotion/styled';
import { IPhoneSettings } from '@npwd/types';
import { i18n } from 'i18next';
import { Theme, StyledEngineProvider, IconButton, Typography } from '@mui/material';
import { ArrowBack } from '@mui/icons-material';
import { RecoilEnv, RecoilRoot } from 'recoil';
import { Header } from './styles/header.styles';
import SnackbarProvider from './snackbar/SnackbarProvider';
import MailModal from './components/MailModal';
import MailList from './components/MailList';
import ThemeSwitchProvider from './ThemeSwitchProvider';

RecoilEnv.RECOIL_DUPLICATE_ATOM_KEY_CHECKING_ENABLED = false;

// Server: same Container/Header shape as npwd_qbx_garages and npwd_fleeca (padding, back
// button, title placement) so the three apps we maintain read as one consistent product.
const Container = styled.div<{ isDarkMode: boolean }>`
  flex: 1;
  padding: 1.5rem;
  display: flex;
  box-sizing: border-box;
  flex-direction: column;
  overflow: auto;
  max-height: 100%;
  /* Server: neutral-100, the same surface the phone's own AppContent and navigation bar use.
     Was #fafafa (neutral-50) - one shade lighter, which drew a visible seam where the app met
     the nav bar. The dark value below already matched neutral-900 exactly. */
  background-color: #f5f5f5;
  ${({ isDarkMode }) =>
    isDarkMode &&
    `
  background-color: rgb(23 23 23 / 1);
`}
`;

interface AppProps {
  theme: Theme;
  i18n: i18n;
  settings: IPhoneSettings;
}

const App = (props: AppProps) => {
  const history = useHistory();
  const isDarkMode = props.theme.palette.mode === 'dark';

  return (
    <StyledEngineProvider injectFirst>
      <ThemeSwitchProvider mode={props.theme.palette.mode}>
        <SnackbarProvider>
          <Container isDarkMode={isDarkMode}>
            <Header>
              <IconButton color="default" onClick={() => history.push('/')}>
                <ArrowBack />
              </IconButton>
              <Typography fontSize={24} color={isDarkMode ? 'white' : 'black'} fontWeight="bold">
                Correio
              </Typography>
            </Header>
            <MailModal />
            <MailList />
          </Container>
        </SnackbarProvider>
      </ThemeSwitchProvider>
    </StyledEngineProvider>
  );
};

export default function WithProviders(props: AppProps) {
  return (
    <RecoilRoot override key='npwd_qbx_mail'>
      <App {...props} />
    </RecoilRoot>
  );
}
