import { Box, Typography } from '@mui/material';
import styled from '@emotion/styled';
import React, { useState } from 'react';
import { GarageItem } from '../types/garage';
import FlightIcon from '@mui/icons-material/Flight';
import PedalBikeIcon from '@mui/icons-material/PedalBike';
import DirectionsCarIcon from '@mui/icons-material/DirectionsCar';
import DirectionsBoatIcon from '@mui/icons-material/DirectionsBoat';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import VehicleDetails from './VehicleDetails';

interface VehicleListProps {
  isDarkMode: boolean;
  vehicles: Map<string, GarageItem[]>;
}

// Server: near-square corners and clean cards, matching the project's standard (same visual
// language as npwd_fleeca and Renewed-Banking's own bank.css), instead of the stock MUI
// Accordion/List look.
const SectionLabel = styled.div<{ isDarkMode: boolean }>`
  font-size: 0.78rem;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: ${({ isDarkMode }) => (isDarkMode ? 'rgba(255, 255, 255, 0.6)' : 'rgba(0, 0, 0, 0.55)')};
  margin: 1.2rem 0 0.6rem;

  &:first-of-type {
    margin-top: 0;
  }
`;

const VehicleCard = styled.div<{ isDarkMode: boolean; accent: string }>`
  background: ${({ isDarkMode }) => (isDarkMode ? 'rgb(38 38 38 / 1)' : '#ffffff')};
  border-radius: 8px;
  border-left: 4px solid ${({ accent }) => accent};
  margin-bottom: 0.7rem;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.12);
`;

const CardSummary = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.8rem;
  padding: 0.9rem 1rem;
  cursor: pointer;
`;

const CardLeft = styled.div`
  display: flex;
  align-items: center;
  gap: 0.9rem;
  min-width: 0;
`;

// Server: the vehicle preview, always visible inline (unlike the in-world garage, where ox_lib
// only renders its image inside a hover card - there is no hover on a phone). Served by our own
// `lite_vehicleimages` resource, the same 256x144 files the in-world garage uses; 56px wide keeps
// the 16:9 ratio and the row height close to what the type icon it replaces already occupied.
const VehicleThumb = styled.img`
  width: 56px;
  height: 32px;
  object-fit: contain;
  flex-shrink: 0;
`;

const VehicleName = styled.div<{ isDarkMode: boolean }>`
  font-size: 0.92rem;
  font-weight: 600;
  color: ${({ isDarkMode }) => (isDarkMode ? '#ffffff' : '#1a201c')};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
`;

const VehiclePlate = styled.div<{ isDarkMode: boolean }>`
  font-size: 0.78rem;
  color: ${({ isDarkMode }) => (isDarkMode ? 'rgba(255, 255, 255, 0.6)' : 'rgba(0, 0, 0, 0.55)')};
`;

const StatePill = styled.div<{ accent: string }>`
  flex-shrink: 0;
  font-size: 0.72rem;
  font-weight: 700;
  color: ${({ accent }) => accent};
  background: ${({ accent }) => `${accent}1f`};
  border-radius: 4px;
  padding: 0.3rem 0.6rem;
  white-space: nowrap;
`;

const ExpandArrow = styled(ExpandMoreIcon)<{ expanded: boolean; isDarkMode: boolean }>`
  transition: transform 0.15s ease;
  flex-shrink: 0;
  color: ${({ isDarkMode }) => (isDarkMode ? 'rgba(255, 255, 255, 0.6)' : 'rgba(0, 0, 0, 0.45)')};
  transform: rotate(${({ expanded }) => (expanded ? '180deg' : '0deg')});
`;

const CardDetails = styled.div`
  padding: 0 1rem 1rem;
`;

const STATE_LABELS: Record<GarageItem['state'], string> = {
  out: 'Na rua',
  garaged: 'Na garagem',
  impounded: 'Apreendido',
  seized: 'Confiscado',
  unknown: 'Desconhecido',
};

const STATE_COLORS: Record<GarageItem['state'], string> = {
  out: '#ed6c02',
  garaged: '#16a84f',
  impounded: '#d64545',
  seized: '#d64545',
  unknown: '#9e9e9e',
};

const TYPE_ICONS: Record<GarageItem['type'], React.ReactNode> = {
  car: <DirectionsCarIcon sx={{ fontSize: 28 }} />,
  aircraft: <FlightIcon sx={{ fontSize: 28 }} />,
  boat: <DirectionsBoatIcon sx={{ fontSize: 28 }} />,
  bike: <PedalBikeIcon sx={{ fontSize: 28 }} />,
};

const TYPE_LABELS: Record<GarageItem['type'], string> = {
  car: 'Carros',
  aircraft: 'Aeronaves',
  boat: 'Barcos',
  bike: 'Motos',
};

export const VehicleList: React.FC<VehicleListProps> = ({ vehicles, isDarkMode }) => {
  const [expandedPlate, setExpandedPlate] = useState<string | null>(null);
  // Server: the image pack covers 815 of the ~882 known models, so some vehicles genuinely have
  // no picture. Rather than shipping the whole model list into this bundle just to check
  // membership (the in-world garage does that, because Lua can read the generated table for
  // free), a failed load just falls back to the type icon that was there before.
  const [brokenImages, setBrokenImages] = useState<Record<string, true>>({});

  const toggle = (plate: string) => {
    setExpandedPlate(plate !== expandedPlate ? plate : null);
  };

  return (
    <Box>
      {Array.from(vehicles.keys()).map((type) => (
        <React.Fragment key={type}>
          <SectionLabel isDarkMode={isDarkMode}>
            {TYPE_LABELS[type as GarageItem['type']] ?? type}
          </SectionLabel>

          {vehicles.get(type)?.map((veh) => {
            const expanded = expandedPlate === veh.plate;
            const accent = STATE_COLORS[veh.state];

            return (
              <VehicleCard key={veh.plate} isDarkMode={isDarkMode} accent={accent}>
                <CardSummary onClick={() => toggle(veh.plate)}>
                  <CardLeft>
                    {veh.model && !brokenImages[veh.model] ? (
                      <VehicleThumb
                        src={`nui://lite_vehicleimages/images/${veh.model}.png`}
                        alt={`${veh.brand} ${veh.vehicle}`}
                        onError={() => setBrokenImages((prev) => ({ ...prev, [veh.model]: true }))}
                      />
                    ) : (
                      <Box sx={{ color: isDarkMode ? 'rgba(255,255,255,0.85)' : 'rgba(0,0,0,0.75)', display: 'flex' }}>
                        {TYPE_ICONS[veh.type]}
                      </Box>
                    )}
                    <Box sx={{ minWidth: 0 }}>
                      <VehicleName isDarkMode={isDarkMode}>{veh.brand} {veh.vehicle}</VehicleName>
                      <VehiclePlate isDarkMode={isDarkMode}>{veh.plate}</VehiclePlate>
                    </Box>
                  </CardLeft>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.8 }}>
                    <StatePill accent={accent}>{STATE_LABELS[veh.state]}</StatePill>
                    <ExpandArrow expanded={expanded} isDarkMode={isDarkMode} />
                  </Box>
                </CardSummary>

                {expanded && (
                  <CardDetails>
                    <VehicleDetails veh={veh} isDarkMode={isDarkMode} />
                  </CardDetails>
                )}
              </VehicleCard>
            );
          })}
        </React.Fragment>
      ))}
    </Box>
  );
};
