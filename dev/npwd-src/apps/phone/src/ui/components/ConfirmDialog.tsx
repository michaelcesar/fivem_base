import React from 'react';
import { Dialog } from '@mui/material';

// Server: shared "are you sure?" modal - centred dialog, near-square corners, destructive
// action in red - for any destructive action on the phone that skips confirmation today.
interface ConfirmDialogProps {
  open: boolean;
  title: string;
  description?: string;
  confirmLabel: string;
  cancelLabel: string;
  onConfirm: () => void;
  onCancel: () => void;
}

export const ConfirmDialog: React.FC<ConfirmDialogProps> = ({
  open,
  title,
  description,
  confirmLabel,
  cancelLabel,
  onConfirm,
  onCancel,
}) => (
  <Dialog
    open={open}
    onClose={onCancel}
    container={() => document.getElementById('phone')}
    PaperProps={{ className: 'rounded-lg bg-white dark:bg-neutral-900 p-1' }}
  >
    <div className="w-72 p-4">
      <p className="text-base font-semibold text-neutral-900 dark:text-white">{title}</p>
      {description && (
        <p className="mt-1 text-sm text-neutral-500 dark:text-neutral-400">{description}</p>
      )}
      <div className="mt-4 flex justify-end gap-2">
        <button
          onClick={onCancel}
          className="rounded-md px-3 py-1.5 text-sm font-medium text-neutral-700 hover:bg-neutral-100 dark:text-neutral-300 dark:hover:bg-neutral-800"
        >
          {cancelLabel}
        </button>
        <button
          onClick={onConfirm}
          className="rounded-md bg-red-500 px-3 py-1.5 text-sm font-medium text-white hover:bg-red-600"
        >
          {confirmLabel}
        </button>
      </div>
    </div>
  </Dialog>
);
