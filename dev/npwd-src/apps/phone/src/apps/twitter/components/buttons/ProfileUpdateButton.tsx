import UpdateButton from '@ui/components/UpdateButton';

interface IProps {
  handleClick: () => void;
}

export function ProfileUpdateButton({ handleClick }: IProps) {
  return <UpdateButton handleClick={handleClick} accentClassName="bg-sky-500" />;
}

export default ProfileUpdateButton;