import { useState } from 'react';
import styled from 'styled-components';

interface DrawableGridProps {
  drawables: number[];
  blacklisted?: number[];
  current: number;
  onSelect: (drawable: number) => void;
  imageSrc: (drawable: number) => string | undefined;
}

// Server: this project's own HUD panel look, matching Input.tsx's single-preview `Preview` -
// same palette (rgba(15, 15, 15, 0.82) background, rgba(255,255,255,.14) border, 3px radius) so
// the grid and the older single-thumbnail view read as the same visual language. See ADR-078.
//
// `1fr` tracks, same reasoning as CategoryCard.tsx's CardGrid (see the longer note there): with
// `auto-fill` the track count comes from the container, identically for every row, so a partial
// last row does not get wider columns - and `1fr` spends the container's leftover width across
// the tracks rather than letting it pile up on one side, which is what left the grid short of
// the panel edge when this briefly used fixed tracks. See ADR-078.
const Grid = styled.div`
  width: 100%;
  max-height: 280px;
  overflow-y: auto;
  margin-top: 10px;

  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(76px, 1fr));
  gap: 8px;
`;

const Tile = styled.button<{ selected: boolean }>`
  position: relative;
  width: 100%;
  height: 76px;

  display: flex;
  align-items: center;
  justify-content: center;

  padding: 3px;
  outline: 0;
  border-radius: 3px;
  border: 1px solid ${({ selected }) => (selected ? 'rgba(255, 255, 255, 0.8)' : 'rgba(255, 255, 255, 0.14)')};
  background: rgba(15, 15, 15, 0.82);
  cursor: pointer;

  &:hover {
    border-color: rgba(255, 255, 255, 0.5);
  }

  img {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
  }
`;

const Fallback = styled.span`
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
`;

// Server: one tile, its own `imageFailed` state - a 404 on this specific drawable hides its
// picture without affecting the rest of the grid. Falls back to the bare drawable number so the
// tile stays selectable (and identifiable) even without a thumbnail. See ADR-078.
const DrawableTile: React.FC<{
  drawable: number;
  selected: boolean;
  imageSrc?: string;
  onClick: () => void;
}> = ({ drawable, selected, imageSrc, onClick }) => {
  const [imageFailed, setImageFailed] = useState(false);

  return (
    <Tile type="button" selected={selected} onClick={onClick} title={String(drawable)}>
      {imageSrc && !imageFailed ? (
        <img src={imageSrc} onError={() => setImageFailed(true)} alt="" />
      ) : (
        <Fallback>{drawable}</Fallback>
      )}
    </Tile>
  );
};

// Server: replaces the drawable stepper with a grid of every real, covered item ("todas as
// roupas") - requested once the single live-preview thumbnail (this file's sibling, `Input.tsx`)
// wasn't enough; texture selection is kept below this grid by the caller (`ClothingPicker.tsx`),
// matching "as setas debaixo pra trocar a textura dela". See ADR-078.
const DrawableGrid: React.FC<DrawableGridProps> = ({ drawables, blacklisted = [], current, onSelect, imageSrc }) => {
  const visible = drawables.filter(d => !blacklisted.includes(d));

  return (
    <Grid>
      {visible.map(drawable => (
        <DrawableTile
          key={drawable}
          drawable={drawable}
          selected={drawable === current}
          imageSrc={imageSrc(drawable)}
          onClick={() => onSelect(drawable)}
        />
      ))}
    </Grid>
  );
};

export default DrawableGrid;
