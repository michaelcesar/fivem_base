// Quickly determine whether we are in browser
import { ServerPromiseResp } from '../types/common';

export const isEnvBrowser = (): boolean => import.meta.env.MODE === 'dev';

export const getResourceName = () =>
  (window as any).GetParentResourceName ? (window as any)?.GetParentResourceName() : 'npwd';

export const buildRespObj = (
  data: any,
  status?: 'ok' | 'error' | undefined,
  errorMsg?: string
): ServerPromiseResp<any> => ({
  data,
  status,
  errorMsg,
});

const DayFormatting = [
  'domingo',
  'segunda-feira',
  'terça-feira',
  'quarta-feira',
  'quinta-feira',
  'sexta-feira',
  'sábado',
];

const MonthFormatting = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

export const dateString = (mailDate: number) => {
  const date = new Date(mailDate);
  return (
    DayFormatting[date.getDay()] +
    ', ' +
    ('0' + date.getDate()).slice(-2) +
    ' de ' +
    MonthFormatting[date.getMonth()] +
    ' de ' +
    date.getFullYear() +
    ' ' +
    ('0' + date.getHours()).slice(-2) +
    ':' +
    ('0' + date.getMinutes()).slice(-2)
  );
};
