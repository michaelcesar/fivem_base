import React from 'react';
import { GarageItem } from '../types/garage';
import { Button, Typography } from '@mui/material';
import styled from '@emotion/styled';
import LinearProgress from '@mui/material/LinearProgress';
import Box from '@mui/material/Box';
import DirectionsCarIcon from '@mui/icons-material/DirectionsCar';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import LocalGasStationIcon from '@mui/icons-material/LocalGasStation';
import MyLocationIcon from '@mui/icons-material/MyLocation';
import BuildIcon from '@mui/icons-material/Build';
import { ServerPromiseResp } from '../types/common';
import fetchNui from '../utils/fetchNui';

type CustomColor = 'error' | 'warning' | 'success';

const StatRow = styled.div`
  display: flex;
  align-items: center;
  gap: 0.7rem;
  margin-bottom: 0.7rem;
`;

const StatIcon = styled.div<{ isDarkMode: boolean }>`
  flex-shrink: 0;
  width: 30px;
  height: 30px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: ${({ isDarkMode }) => (isDarkMode ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.06)')};
  color: ${({ isDarkMode }) => (isDarkMode ? 'rgba(255, 255, 255, 0.85)' : 'rgba(0, 0, 0, 0.7)')};
`;

const StatBody = styled.div`
  flex: 1;
  min-width: 0;
`;

const StatLabel = styled.div<{ isDarkMode: boolean }>`
  font-size: 0.72rem;
  font-weight: 600;
  color: ${({ isDarkMode }) => (isDarkMode ? 'rgba(255, 255, 255, 0.6)' : 'rgba(0, 0, 0, 0.55)')};
  margin-bottom: 0.15rem;
`;

function StatBar({ value }: { value: number }) {
  let color: CustomColor = 'error';
  if (value > 25 && value <= 75) color = 'warning';
  else if (value > 75) color = 'success';

  return (
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
      <Box sx={{ width: '100%' }}>
        <LinearProgress
          color={color}
          variant="determinate"
          value={value}
          sx={{ height: 6, borderRadius: 3 }}
        />
      </Box>
      <Box sx={{ minWidth: 32 }}>
        <Typography variant="body2" color="text.secondary" fontSize={12}>{`${Math.round(value)}%`}</Typography>
      </Box>
    </Box>
  );
}

interface VehicleDetailsProps {
  veh: GarageItem;
  isDarkMode: boolean;
}

const VehicleDetails = ({ veh, isDarkMode }: VehicleDetailsProps) => {
  const handleTrackVehicle = (plate: string) => {
    fetchNui<ServerPromiseResp>('npwd:qbx_garage:requestWaypoint', { plate });
  };

  return (
    <>
      <StatRow>
        <StatIcon isDarkMode={isDarkMode}>
          <LocationOnIcon sx={{ fontSize: 17 }} />
        </StatIcon>
        <StatBody>
          <StatLabel isDarkMode={isDarkMode}>Localização</StatLabel>
          <Typography fontSize={13} sx={{ color: isDarkMode ? '#fff' : '#1a201c' }}>{veh.garage}</Typography>
        </StatBody>
      </StatRow>

      <StatRow>
        <StatIcon isDarkMode={isDarkMode}>
          <BuildIcon sx={{ fontSize: 17 }} />
        </StatIcon>
        <StatBody>
          <StatLabel isDarkMode={isDarkMode}>Motor</StatLabel>
          <StatBar value={Math.ceil(veh.engine / 10)} />
        </StatBody>
      </StatRow>

      <StatRow>
        <StatIcon isDarkMode={isDarkMode}>
          <LocalGasStationIcon sx={{ fontSize: 17 }} />
        </StatIcon>
        <StatBody>
          <StatLabel isDarkMode={isDarkMode}>Combustível</StatLabel>
          <StatBar value={Math.ceil(veh.fuel)} />
        </StatBody>
      </StatRow>

      <StatRow>
        <StatIcon isDarkMode={isDarkMode}>
          <DirectionsCarIcon sx={{ fontSize: 17 }} />
        </StatIcon>
        <StatBody>
          <StatLabel isDarkMode={isDarkMode}>Carroceria</StatLabel>
          <StatBar value={Math.ceil(veh.body / 10)} />
        </StatBody>
      </StatRow>

      <Button
        color="info"
        variant="outlined"
        disabled={veh.state !== 'out'}
        onClick={() => handleTrackVehicle(veh.plate)}
        startIcon={<MyLocationIcon />}
        sx={{ mt: 0.5, borderRadius: '4px' }}
      >
        Localizar
      </Button>
    </>
  );
};

export default VehicleDetails;
