import React, { useState } from 'react';
import styled from '@emotion/styled';
import { FLEECA_GREEN } from '../app.theme';

// Servidor: the phone app only transfers. Depositing and withdrawing move physical cash, which
// requires standing at an ATM or teller - client/client.lua doesn't even register NUI callbacks
// for them any more, so there is nothing here to render a button for.
type ActionType = 'transfer';

const Row = styled.div`
  display: flex;
  gap: 0.7rem;
  margin: 1.1rem 0;
`;

const ActionBtn = styled.button<{ gradientFrom: string; gradientTo: string }>`
  flex: 1;
  border: none;
  border-radius: 12px;
  padding: 0.9rem 0.4rem;
  color: #ffffff;
  font-weight: 700;
  font-size: 0.85rem;
  cursor: pointer;
  background: linear-gradient(135deg, ${({ gradientFrom }) => gradientFrom} 0%, ${({ gradientTo }) => gradientTo} 100%);
`;

// Servidor: matches Renewed-Banking's own bank.html/bank.css modal (.modal-backdrop/.modal-card/
// .form-group/.modal-actions) so the phone app's transaction dialogs read as the same product as
// the in-world ATM/teller UI, instead of a generic MUI dialog.
const Backdrop = styled.div`
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.55);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1300;
`;

const ModalCard = styled.div`
  width: 88%;
  max-width: 21rem;
  background: #ffffff;
  border-radius: 6px;
  padding: 1.6rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.18);
`;

const ModalTitle = styled.h3`
  font-size: 1.15rem;
  margin-bottom: 1.2rem;
  color: #1a201c;
`;

const FormGroup = styled.div`
  margin-bottom: 1rem;
`;

const Label = styled.label`
  display: block;
  font-size: 0.8rem;
  font-weight: 600;
  color: #6b7a72;
  margin-bottom: 0.35rem;
`;

const Input = styled.input`
  width: 100%;
  background: #f4f6f5;
  border: 1px solid rgba(0, 0, 0, 0.08);
  border-radius: 3px;
  padding: 0.75rem 0.9rem;
  font-size: 0.95rem;
  color: #1a201c;
  font-family: inherit;

  &:focus {
    outline: none;
    border-color: ${FLEECA_GREEN};
  }
`;

const ModalActions = styled.div`
  display: flex;
  gap: 0.7rem;
  margin-top: 1.4rem;
`;

const ModalButton = styled.button<{ variant: 'cancel' | 'confirm'; accent: string; accentDark: string }>`
  flex: 1;
  border: none;
  padding: 0.8rem;
  border-radius: 4px;
  font-weight: 700;
  font-size: 0.9rem;
  cursor: pointer;
  transition: 0.2s;
  background: ${({ variant, accent }) => (variant === 'confirm' ? accent : '#f4f6f5')};
  color: ${({ variant }) => (variant === 'confirm' ? '#ffffff' : '#6b7a72')};

  &:hover {
    background: ${({ variant, accentDark }) => (variant === 'confirm' ? accentDark : 'rgba(0, 0, 0, 0.08)')};
  }
`;

interface ActionButtonsProps {
  onSubmit: (action: ActionType, amount: number, targetId?: string, comment?: string) => void;
}

const LABELS: Record<ActionType, string> = {
  transfer: 'Transferir',
};

const ACCENTS: Record<ActionType, [string, string]> = {
  transfer: ['#2b3a33', '#16201c'],
};

export const ActionButtons = ({ onSubmit }: ActionButtonsProps) => {
  const [open, setOpen] = useState<ActionType | null>(null);
  const [amount, setAmount] = useState('');
  const [targetId, setTargetId] = useState('');
  const [comment, setComment] = useState('');

  const close = () => {
    setOpen(null);
    setAmount('');
    setTargetId('');
    setComment('');
  };

  const confirm = () => {
    const parsedAmount = parseInt(amount, 10);
    if (!open || !parsedAmount || parsedAmount < 1) return;
    if (open === 'transfer' && !targetId.trim()) return;

    onSubmit(open, parsedAmount, open === 'transfer' ? targetId.trim() : undefined, comment || undefined);
    close();
  };

  return (
    <>
      <Row>
        <ActionBtn gradientFrom="#2b3a33" gradientTo="#16201c" onClick={() => setOpen('transfer')}>
          Transferir
        </ActionBtn>
      </Row>

      {open && (
        <Backdrop
          onClick={(e) => {
            if (e.target === e.currentTarget) close();
          }}
        >
          <ModalCard>
            <ModalTitle>{LABELS[open]}</ModalTitle>

            <FormGroup>
              <Label>Valor:</Label>
              <Input
                type="number"
                min={1}
                step={1}
                placeholder="0"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
              />
            </FormGroup>

            {open === 'transfer' && (
              <FormGroup>
                <Label>Conta ou ID do cidadão de destino:</Label>
                <Input
                  type="text"
                  placeholder="Ex: 1001"
                  autoFocus
                  value={targetId}
                  onChange={(e) => setTargetId(e.target.value)}
                />
              </FormGroup>
            )}

            <FormGroup>
              <Label>Comentário (opcional):</Label>
              <Input
                type="text"
                placeholder="Ex: aluguel"
                value={comment}
                onChange={(e) => setComment(e.target.value)}
              />
            </FormGroup>

            <ModalActions>
              <ModalButton variant="cancel" accent={ACCENTS[open][0]} accentDark={ACCENTS[open][1]} onClick={close}>
                Cancelar
              </ModalButton>
              <ModalButton variant="confirm" accent={ACCENTS[open][0]} accentDark={ACCENTS[open][1]} onClick={confirm}>
                Confirmar
              </ModalButton>
            </ModalActions>
          </ModalCard>
        </Backdrop>
      )}
    </>
  );
};
