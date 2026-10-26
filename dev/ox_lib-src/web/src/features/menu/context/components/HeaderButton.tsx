import { Button, createStyles } from '@mantine/core';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import LibIcon from '../../../../components/LibIcon';
import { gfx } from '../../../../theme';

interface Props {
  icon: IconProp;
  canClose?: boolean;
  iconSize: number;
  handleClick: () => void;
}

// Small, understated icon button - used for the back/close controls in a card's label
// section. Deliberately NOT the same visual weight as a regular action Button (no
// gradient/border/glow), so it never competes with the label/sublabel for attention.
const useStyles = createStyles((_theme, params: { canClose?: boolean }) => ({
  root: {
    width: 22,
    height: 22,
    minHeight: 22,
    padding: 0,
    border: 'none',
    background: 'transparent',
    color: params.canClose === false ? gfx.textLow : gfx.textMid,
    animation: 'none',
    '&::after': {
      display: 'none',
    },
    '&:hover': {
      background: 'rgba(255,255,255,0.06)',
      color: params.canClose === false ? gfx.textLow : gfx.textHi,
      transform: 'none',
      boxShadow: 'none',
    },
  },
  label: {
    fontSize: 11,
  },
}));

const HeaderButton: React.FC<Props> = ({ icon, canClose, iconSize, handleClick }) => {
  const { classes } = useStyles({ canClose });

  return (
    <Button
      variant="default"
      classNames={{ label: classes.label, root: classes.root }}
      disabled={canClose === false}
      onClick={handleClick}
    >
      <LibIcon icon={icon} fontSize={iconSize} fixedWidth />
    </Button>
  );
};

export default HeaderButton;
