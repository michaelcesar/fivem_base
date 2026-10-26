export const formatMoney = (amount: number): string =>
  `R$ ${Math.round(amount || 0).toLocaleString('pt-BR')}`;
