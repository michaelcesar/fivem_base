import React from 'react';
import styled from '@emotion/styled';
import { Typography } from '@mui/material';
import { FLEECA_GREEN, FLEECA_GREEN_DARK } from '../app.theme';
import { Account } from '../types/bank';
import { formatMoney } from '../utils/formatMoney';

const Card = styled.div`
  background: linear-gradient(135deg, ${FLEECA_GREEN} 0%, ${FLEECA_GREEN_DARK} 100%);
  border-radius: 18px;
  padding: 1.4rem 1.6rem;
  color: #ffffff;
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
`;

interface BalanceCardProps {
  account: Account;
}

export const BalanceCard = ({ account }: BalanceCardProps) => (
  <Card>
    <Typography fontSize={13} sx={{ opacity: 0.85 }}>
      {account.type}
    </Typography>
    <Typography fontSize={17} fontWeight={700}>
      {account.name}
    </Typography>
    <Typography fontSize={30} fontWeight={800} sx={{ mt: 1 }}>
      {formatMoney(account.amount)}
    </Typography>
    {typeof account.cash === 'number' && (
      <Typography fontSize={13} sx={{ opacity: 0.85 }}>
        Dinheiro: {formatMoney(account.cash)}
      </Typography>
    )}
  </Card>
);
