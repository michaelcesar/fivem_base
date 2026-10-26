import React, { useEffect, useState } from 'react';
import { useHistory } from 'react-router-dom';
import styled from '@emotion/styled';
import { Header } from './styles/header.styles';
import { IPhoneSettings } from '@npwd/types';
import { i18n } from 'i18next';
import { IconButton, Theme, StyledEngineProvider, Typography } from '@mui/material';
import { ArrowBack } from '@mui/icons-material';
import ThemeSwitchProvider from './ThemeSwitchProvider';
import { GarageItem } from './types/garage';
import { MockGarage } from './utils/constants';
import { buildRespObj } from './utils/misc';
import { VehicleList } from './components/VehicleList';
import fetchNui from './utils/fetchNui';
import { ServerPromiseResp } from './types/common';
import { RecoilEnv, RecoilRoot } from 'recoil';

RecoilEnv.RECOIL_DUPLICATE_ATOM_KEY_CHECKING_ENABLED = false;

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
  const [mappedVeh, setMappedVeh] = useState<Map<string, GarageItem[]>>(new Map<string, GarageItem[]>());

  const isDarkMode = props.theme.palette.mode === 'dark';

  useEffect(() => {
    fetchNui<ServerPromiseResp<GarageItem[]>>(
      'npwd:qbx_garage:getVehicles',
      null,
      buildRespObj(MockGarage)
      ).then((resp) => {
        if (!resp.data) return;
        const mappedVehicles = new Map<string, GarageItem[]>()
        resp.data.forEach((vehicle: GarageItem) => {
          if (!mappedVehicles.get(vehicle.type)) mappedVehicles.set(vehicle.type, []);
          mappedVehicles.get(vehicle.type)?.push(vehicle);
        });

        setMappedVeh(mappedVehicles);
    });
  }, []);

  return (
    <StyledEngineProvider injectFirst>
      <ThemeSwitchProvider mode={props.theme.palette.mode}>
        <Container isDarkMode={isDarkMode}>
          <Header>
            <IconButton color="default" onClick={() => history.push('/')}>
              <ArrowBack />
            </IconButton>
            <Typography fontSize={24} color={isDarkMode ? "white" : "black"} fontWeight="bold">
              Garagem
            </Typography>
          </Header>
          {mappedVeh.size > 0 ? (
            <VehicleList isDarkMode={isDarkMode} vehicles={mappedVeh} />
          ) : (
            <Typography align="center" fontSize={16} sx={{ opacity: 0.7, mt: 4 }} color={isDarkMode ? "white" : "black"}>
              Nenhum veículo encontrado.
            </Typography>
          )}
        </Container>
      </ThemeSwitchProvider>
    </StyledEngineProvider>
  );
};

const WithProviders: React.FC<AppProps> = (props) => (
  <RecoilRoot override key="npwd_qbx_garages">
    <App {...props} />
  </RecoilRoot>
);

export default WithProviders;
