import React from 'react';

// Server: every phone app that shows a contact (Contacts, Messages, the dialer/call history)
// uses this same circle-with-initials avatar - no profile pictures, matching the iPhone-style
// look requested for the phone as a whole. Colour is deterministic per name/number so the same
// person always gets the same colour across every app.
const AVATAR_COLORS = [
  '#FF3B30',
  '#FF9500',
  '#FFCC00',
  '#34C759',
  '#00C7BE',
  '#30B0C7',
  '#32ADE6',
  '#007AFF',
  '#5856D6',
  '#AF52DE',
  '#FF2D55',
];

function colorFor(seed: string): string {
  let hash = 0;
  for (let i = 0; i < seed.length; i++) {
    hash = (hash << 5) - hash + seed.charCodeAt(i);
    hash |= 0;
  }
  return AVATAR_COLORS[Math.abs(hash) % AVATAR_COLORS.length];
}

export function initialsOf(name: string): string {
  if (!name) return '?';
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '?';
  const first = parts[0].charAt(0);
  const last = parts.length > 1 ? parts[parts.length - 1].charAt(0) : '';
  return `${first}${last}`.toUpperCase();
}

interface ContactAvatarProps {
  name: string;
  size?: number;
}

export const ContactAvatar: React.FC<ContactAvatarProps> = ({ name, size = 40 }) => {
  const background = colorFor(name || '?');

  return (
    <div
      className="flex shrink-0 items-center justify-center rounded-full font-semibold text-white"
      style={{
        width: size,
        height: size,
        background,
        fontSize: size * 0.4,
      }}
    >
      {initialsOf(name)}
    </div>
  );
};
