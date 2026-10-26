import { forwardRef } from 'react';
import { NPWDInput, NPWDTextarea } from './Input';

interface ProfileFieldProps {
  label: string;
  value: string;
  handleChange?: (val: string) => void;
  allowChange?: boolean;
  multiline?: boolean;
  maxLength?: number;
}

const ProfileField = forwardRef<HTMLInputElement, ProfileFieldProps>(
  ({ label, value, handleChange, allowChange, multiline, maxLength }, ref) => {
    const _handleChange = (e) => handleChange(e.target.value);

    return (
      <div className="mt-[8px] w-full">
        <label className="text-sm font-medium text-neutral-500 dark:text-neutral-400">
          {label}
        </label>
        {multiline ? (
          <NPWDTextarea
            className="resize-none"
            rows={4}
            value={value}
            onChange={_handleChange}
            disabled={!allowChange}
            maxLength={maxLength}
          />
        ) : (
          <NPWDInput
            value={value}
            onChange={_handleChange}
            disabled={!allowChange}
            maxLength={maxLength}
          />
        )}
      </div>
    );
  },
);

ProfileField.defaultProps = {
  allowChange: true,
  maxLength: 200,
  multiline: false,
};

export default ProfileField;
