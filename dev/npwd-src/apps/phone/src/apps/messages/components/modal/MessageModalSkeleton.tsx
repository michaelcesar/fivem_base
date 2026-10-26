import React from 'react';
import Skeleton from '@mui/material/Skeleton';
import MessageSkeletonList from './MessageSkeletonList';

// Server: mirrors the real MessageModal layout (header bar, message bubbles, input bar) so the
// loading state never drops a whole section of the screen - it used to fall back to a single
// bare spinner with no header or input bar while waiting for the conversation itself to load.
export const MessageModalSkeleton: React.FC = () => (
  <div className="flex h-full w-full flex-col">
    <div className="flex shrink-0 items-center gap-2 border-b border-neutral-200 bg-[#F7F7F7] px-2 py-2 dark:border-neutral-700 dark:bg-[#202C33]">
      <Skeleton variant="circular" width={36} height={36} />
      <div className="flex flex-1 flex-col gap-1">
        <Skeleton variant="text" width="40%" height={16} />
        <Skeleton variant="text" width="25%" height={12} />
      </div>
    </div>
    {/* Server: `min-h-0 flex-1 overflow-hidden` - the skeleton bubbles below add up to more than
        the space between the header and the input bar, and this is the trio that lets the middle
        section give way instead of pushing the input off screen. Note that this alone was *not*
        enough: the same minimum was missing from `AppContent`'s inner div, one level up and
        outside this app, which is what actually kept losing the input bar. See ADR-043. */}
    <div className="min-h-0 flex-1 overflow-hidden">
      <MessageSkeletonList />
    </div>
    <div className="flex shrink-0 items-center gap-2 bg-[#F7F7F7] px-2 py-2 dark:bg-[#202C33]">
      <Skeleton variant="circular" width={24} height={24} />
      <Skeleton variant="rounded" className="flex-1" height={36} />
      <Skeleton variant="circular" width={24} height={24} />
    </div>
  </div>
);

export default MessageModalSkeleton;
