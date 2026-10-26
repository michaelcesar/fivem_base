// Servidor: mirrors the exact shape Renewed-Banking's own server already returns (see
// server/main.lua's `getBankData`/`handleTransaction`) - this app is a second front end on
// top of the same accounts, not a parallel banking system.

export interface Transaction {
  trans_id: string;
  title: string;
  amount: number;
  trans_type: 'deposit' | 'withdraw';
  receiver: string;
  message: string;
  issuer: string;
  time: number;
}

export interface Account {
  id: string;
  type: string;
  name: string;
  frozen: boolean | number;
  amount: number;
  cash?: number;
  transactions: Transaction[];
}
