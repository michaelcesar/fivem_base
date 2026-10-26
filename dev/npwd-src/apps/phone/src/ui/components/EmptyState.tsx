import React from 'react';

// Server: shared empty-state layout - grey circle badge with an icon, a bold label, and a
// muted sublabel underneath. Matches the icon-in-a-circle convention already used for contact
// avatars (ContactAvatar) instead of an emoji.
interface EmptyStateProps {
  icon: React.ReactNode;
  label: string;
  sublabel?: string;
}

export const EmptyState: React.FC<EmptyStateProps> = ({ icon, label, sublabel }) => (
  <div className="flex flex-col items-center gap-2 pt-24 text-center">
    <div className="flex h-16 w-16 items-center justify-center rounded-full bg-neutral-200 text-neutral-400 dark:bg-neutral-800 dark:text-neutral-500">
      {icon}
    </div>
    <p className="text-base font-medium text-neutral-900 dark:text-neutral-100">{label}</p>
    {sublabel && <p className="max-w-[80%] text-sm text-neutral-400">{sublabel}</p>}
  </div>
);
