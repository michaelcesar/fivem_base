import React from 'react';
import styled from '@emotion/styled';
import { Typography } from '@mui/material';
import { ArrowDownward, ArrowUpward } from '@mui/icons-material';
import { Transaction } from '../types/bank';
import { formatMoney } from '../utils/formatMoney';

const Row = styled.div`
  display: flex;
  align-items: center;
  gap: 0.8rem;
  padding: 0.7rem 0;
  border-bottom: 1px solid rgba(128, 128, 128, 0.15);

  &:last-of-type {
    border-bottom: none;
  }
`;

const IconBadge = styled.div<{ isDeposit: boolean }>`
  width: 34px;
  height: 34px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  color: #ffffff;
  background: ${({ isDeposit }) => (isDeposit ? '#16a84f' : '#d64545')};
`;

interface TransactionListProps {
  transactions: Transaction[];
  isDarkMode: boolean;
}

const formatDate = (time: number) => new Date(time * 1000).toLocaleString('pt-BR');

export const TransactionList = ({ transactions, isDarkMode }: TransactionListProps) => {
  if (!transactions || transactions.length === 0) {
    return (
      <Typography align="center" fontSize={14} sx={{ opacity: 0.7, mt: 2 }}>
        Nenhuma transação ainda.
      </Typography>
    );
  }

  return (
    <div>
      {transactions.map((t) => {
        const isDeposit = t.trans_type === 'deposit';
        // Servidor: deposit/withdraw resolve issuer and receiver to the same person (see
        // Renewed-Banking's own bank.js) - the arrow only means something for a real transfer.
        const meta =
          t.issuer && t.receiver && t.issuer !== t.receiver
            ? `${t.issuer} → ${t.receiver} · ${formatDate(t.time)}`
            : formatDate(t.time);

        return (
          <Row key={t.trans_id}>
            <IconBadge isDeposit={isDeposit}>
              {isDeposit ? <ArrowDownward fontSize="small" /> : <ArrowUpward fontSize="small" />}
            </IconBadge>
            <div style={{ flex: 1, minWidth: 0 }}>
              <Typography
                fontSize={14}
                fontWeight={600}
                color={isDarkMode ? 'white' : 'black'}
                noWrap
              >
                {t.message || t.title}
              </Typography>
              <Typography fontSize={12} sx={{ opacity: 0.65 }} noWrap>
                {meta}
              </Typography>
            </div>
            <Typography fontSize={14} fontWeight={700} color={isDeposit ? '#16a84f' : '#d64545'}>
              {isDeposit ? '+' : '-'} {formatMoney(t.amount)}
            </Typography>
          </Row>
        );
      })}
    </div>
  );
};
