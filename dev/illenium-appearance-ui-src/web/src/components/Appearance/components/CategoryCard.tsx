import styled from 'styled-components';
import { IconType } from 'react-icons';

// Server: the entry screen for Components/Props - one card per clothing type (mask, tops, legs,
// hat, glasses...), a generic category icon rather than a clothing photo (no single drawable
// represents "shoes" as a category), following this project's own card look (same palette as
// DrawableGrid's tiles). Clicking a card enters that category's DrawableGrid + texture stepper.
// Requested as a redesign of the first version's per-category `Section` accordion. See ADR-078.
// Server: `1fr` tracks, deliberately - and note that an earlier pass here replaced them with
// fixed `minmax(84px, 84px)` tracks on a WRONG diagnosis, then had to come back. `auto-fill`
// (unlike `auto-fit`) keeps empty tracks, so the track count and therefore every track's width is
// decided by the container, identically for every row - a partial last row does NOT get wider
// columns, which is what that earlier pass believed. The real cost of fixed tracks was this: 4
// columns of 84px + gaps is 360px inside a container whose content width is `min(20vw, 400px)`
// minus padding, so the leftover (up to ~20px, resolution-dependent) piled up on the right and
// left the whole grid visibly short of the panel edge next to the Options toolbar. `1fr` spends
// that leftover across the tracks instead, so the grid fills the panel and its margins stay
// symmetric. See ADR-078.
export const CardGrid = styled.div`
  width: 100%;
  margin-top: 10px;

  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(84px, 1fr));
  gap: 8px;
`;

const Card = styled.button`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  width: 100%;
  height: 84px;

  padding: 8px;
  outline: 0;
  border-radius: 3px;
  border: 1px solid rgba(255, 255, 255, 0.14);
  background: rgba(15, 15, 15, 0.82);
  color: rgba(${props => props.theme.fontColor || '255, 255, 255'}, 1);
  cursor: pointer;

  transition: background 0.1s;

  &:hover {
    color: rgba(${props => props.theme.fontColorHover || '255, 255, 255'}, 1);
    background: rgba(${props => props.theme.primaryBackground || '0, 0, 0'}, 0.9);
    ${props => (props.theme.smoothBackgroundTransition ? 'transition: background 0.2s;' : '')}
    ${props => (props.theme.scaleOnHover ? 'transform: scale(1.05);' : '')}
  }
`;

// Server: both slots are fixed-height on purpose. Reported "desalinhado" a second time, after the
// card *boxes* were already all 84px: the misalignment left was inside them. Labels are 1 line
// ("Sapatos") or 2 ("Chapéus e capacetes"), and with the card's `justify-content: center` around a
// variable-height label, a 2-line card's total content is taller, so centering pushed its icon
// visibly higher than its 1-line neighbours in the same row. Fixed heights make total content
// height identical for every card, so icons and labels land on the same baseline everywhere.
// See ADR-078.
const IconSlot = styled.span`
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
`;

// 28px fits two lines at 11px/1.2 (~26.4px); a hypothetical third line clips rather than
// re-introducing the variable height this whole change exists to remove.
const Label = styled.span`
  height: 28px;
  margin-top: 6px;
  overflow: hidden;

  display: flex;
  align-items: flex-start;
  justify-content: center;

  font-size: 11px;
  text-align: center;
  line-height: 1.2;
  font-weight: ${props => props.theme.sectionFontWeight || 'normal'};
`;

interface CategoryCardProps {
  icon: IconType;
  label: string;
  onClick: () => void;
}

const CategoryCard: React.FC<CategoryCardProps> = ({ icon: Icon, label, onClick }) => (
  <Card type="button" onClick={onClick}>
    <IconSlot>
      <Icon size={24} />
    </IconSlot>
    <Label>{label}</Label>
  </Card>
);

export default CategoryCard;
