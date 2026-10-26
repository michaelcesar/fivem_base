import React, { useEffect, useState } from 'react';
import { useHistory } from 'react-router-dom';
import styled from '@emotion/styled';
import { Header } from './styles/header.styles';
import { IPhoneSettings } from '@npwd/types';
import { i18n } from 'i18next';
import { IconButton, Theme, StyledEngineProvider, Typography, Tabs, Tab } from '@mui/material';
import { ArrowBack } from '@mui/icons-material';
import ThemeSwitchProvider from './ThemeSwitchProvider';
import { BalanceCard } from './components/BalanceCard';
import { ActionButtons } from './components/ActionButtons';
import { TransactionList } from './components/TransactionList';
import fetchNui from './utils/fetchNui';
import { ServerPromiseResp } from './types/common';
import { Account } from './types/bank';

const Container = styled.div<{ isDarkMode: boolean }>`
  flex: 1;
  padding: 1.5rem;
  display: flex;
  box-sizing: border-box;
  flex-direction: column;
  overflow: auto;
  max-height: 100%;
  /* Servidor: neutral-100, the same surface the phone's own AppContent and navigation bar use.
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

// Servidor: this app is a second front end on the exact same Fleeca accounts the in-world
// ATM/teller NUI already reads and writes (Renewed-Banking's server callbacks, called here
// through client/client.lua's NUI bridge) - no separate banking system, no separate balance.
const App = (props: AppProps) => {
  const history = useHistory();
  const isDarkMode = props.theme.palette.mode === 'dark';

  const [accounts, setAccounts] = useState<Account[]>([]);
  const [activeIndex, setActiveIndex] = useState(0);

  const loadAccounts = () => {
    fetchNui<ServerPromiseResp<Account[]>>('npwd_fleeca:getAccounts', null, {
      status: 'ok',
      data: [],
    }).then((resp) => {
      if (!resp.data) return;
      setAccounts(resp.data);
    });
  };

  useEffect(() => {
    loadAccounts();
  }, []);

  const activeAccount = accounts[activeIndex];

  const handleAction = (
    action: 'transfer',
    amount: number,
    targetId?: string,
    comment?: string,
  ) => {
    if (!activeAccount) return;

    fetchNui<ServerPromiseResp<Account[]>>('npwd_fleeca:' + action, {
      fromAccount: activeAccount.id,
      amount,
      targetId,
      comment,
    }).then((resp) => {
      if (resp.status === 'ok' && resp.data) {
        setAccounts(resp.data);
      }
    });
  };

  return (
    <StyledEngineProvider injectFirst>
      <ThemeSwitchProvider mode={props.theme.palette.mode}>
        <Container isDarkMode={isDarkMode}>
          <Header>
            <IconButton color="default" onClick={() => history.push('/')}>
              <ArrowBack />
            </IconButton>
            <Typography fontSize={24} color={isDarkMode ? 'white' : 'black'} fontWeight="bold">
              Fleeca
            </Typography>
          </Header>

          {accounts.length === 0 && (
            <Typography align="center" fontSize={16} sx={{ opacity: 0.7, mt: 4 }}>
              Nenhuma conta encontrada.
            </Typography>
          )}

          {accounts.length > 1 && (
            <Tabs
              value={activeIndex}
              onChange={(_, value) => setActiveIndex(value)}
              variant="scrollable"
              scrollButtons="auto"
              sx={{ mb: 1.5, minHeight: 36 }}
            >
              {accounts.map((account, index) => (
                <Tab key={account.id} label={account.name} value={index} sx={{ minHeight: 36 }} />
              ))}
            </Tabs>
          )}

          {activeAccount && (
            <>
              <BalanceCard account={activeAccount} />
              <ActionButtons onSubmit={handleAction} />
              <Typography fontSize={15} fontWeight={700} color={isDarkMode ? 'white' : 'black'} sx={{ mt: 1, mb: 0.5 }}>
                Transações
              </Typography>
              <TransactionList transactions={activeAccount.transactions} isDarkMode={isDarkMode} />
            </>
          )}
        </Container>
      </ThemeSwitchProvider>
    </StyledEngineProvider>
  );
};

const WithProviders: React.FC<AppProps> = (props) => <App {...props} />;

export default WithProviders;
