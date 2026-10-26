import React from 'react';
import { createPortal } from 'react-dom';
import { Slide } from '@mui/material';
import { ListItem, List } from '@npwd/keyos';
import { X } from 'lucide-react';

export interface IContextMenuOption {
  onClick(e, option): void;
  label: string;
  description?: string;
  selected?: boolean;
  icon?: React.ReactNode;
  key?: string;
  // Server: marks a destructive action (delete message/conversation/etc) - renders its icon
  // and label in red instead of the neutral default, so delete reads as delete at a glance.
  danger?: boolean;
}

interface ContextMenuProps {
  open: boolean;
  onClose: () => void;
  options: Array<IContextMenuOption>;
  settingLabel: string;
}

export const ContextMenu: React.FC<ContextMenuProps> = ({
  open,
  onClose,
  options,
  settingLabel,
}) => {
  const _options = options;
  const phoneEl = document.getElementById('phone');

  if (!phoneEl) return null;

  // Server: portaled directly onto `#phone` (the visible, correctly-inset phone screen) and
  // pinned with `position: absolute` (not `fixed`). `#phone` is itself `position: absolute` and
  // ~100px smaller on every side than `.Phone` (the box `fixed` positioning would otherwise
  // resolve against, per PhoneWrapper.tsx/Phone.css) - pinning to the bigger box put this sheet's
  // bottom edge behind the phone's own frame graphic instead of flush with the visible screen.
  // Portaling (rather than relying on in-place `absolute`) also sidesteps any scroll container
  // between this menu and `#phone` that has its own `position: relative`, which used to clip it.
  return createPortal(
    <Slide
      direction="up"
      in={open}
      style={{ position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 9999 }}
      mountOnEnter
      unmountOnExit
    >
      <div className="max-h-[70%] min-h-[10%] w-full overflow-hidden rounded-t-2xl bg-neutral-100 p-2 dark:bg-neutral-900">
        <div className="flex items-center justify-between px-2">
          <p className="text-base font-medium text-neutral-900 dark:text-neutral-50">
            {settingLabel}
          </p>
          <button onClick={onClose} className="text-neutral-900 dark:text-neutral-50">
            <X size={24} />
          </button>
        </div>
        <div className="overflow-auto max-h-[500px] pb-4">
          <List>
            {_options.map((option) => (
              <ListItem
                startElement={
                  option.icon && (
                    <span className={option.danger ? 'text-red-500' : undefined}>{option.icon}</span>
                  )
                }
                primaryText={
                  <span className={option.danger ? 'text-red-500' : undefined}>{option.label}</span>
                }
                secondaryText={option.description}
                button
                selected={option.selected}
                onClick={(e) => {
                  option.onClick(e, option);
                  onClose();
                }}
              />
            ))}
          </List>
        </div>
      </div>
    </Slide>,
    phoneEl,
  );
};
