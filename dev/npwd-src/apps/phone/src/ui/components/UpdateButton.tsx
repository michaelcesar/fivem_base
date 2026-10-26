import React from 'react';
import { useTranslation } from 'react-i18next';
import { NPWDButton } from '@npwd/keyos';

interface ProfileUpdateButtonProps {
  handleClick: () => void;
  accentClassName?: string;
}

// Server: apps with their own established brand colour (Match's pink, Twitter's sky blue) pass
// it in via accentClassName so their save button matches the rest of that app, instead of every
// app defaulting to the site-wide green primary accent.
//
// Rendered in normal flow (not `position: absolute`) on purpose - an absolutely positioned bar
// pins to its containing block's own box, not to "wherever the scrollable content actually
// ends", so on a form tall enough to scroll it just floated over whatever field ended up
// underneath it instead of sitting below everything. Callers with scrollable content put this
// after their own scroll container so it naturally lands below it.
//
// No horizontal padding of its own on purpose - it's meant to span exactly the same width as
// the fields above it, which get their horizontal inset entirely from the caller's own padded
// container. Adding padding here too used to double up with that container's padding, shrinking
// the button and making it noticeably narrower than the fields it sat under.
export const ProfileUpdateButton: React.FC<ProfileUpdateButtonProps> = ({
  handleClick,
  accentClassName = 'bg-[#25D366]',
}) => {
  const [t] = useTranslation();

  return (
    <div className="mt-2">
      <NPWDButton onClick={handleClick} className={`w-full ${accentClassName}`}>
        {t('GENERIC.SAVE')}
      </NPWDButton>
    </div>
  );
};

export default ProfileUpdateButton;
