import { useEffect } from 'react';
import styled from 'styled-components';
import { FiChevronLeft, FiChevronRight } from 'react-icons/fi';

import { stepValue } from '../../../utils/stepValue';

interface TextureControlProps {
  title?: string;
  min?: number;
  max?: number;
  blacklisted?: number[];
  value: number;
  onChange: (value: number) => void;
}

// Server: replaces the clickable ◀ ▶ buttons (still used everywhere else - HeadBlend,
// HeadOverlays, the drawable fallback stepper) with the keyboard's own arrow keys, for texture
// changes specifically within the clothing picker. This is a caption, not a control: no button
// here does anything on click, it only shows which keys change the value. Requested: "ao invés
// de mudar os tipos nas setas, vamos mudar com alguma tecla, aí só a legenda ali informando qual
// a tecla apertar." See ADR-078.
const Row = styled.div`
  width: 100%;
  margin-top: 10px;

  display: flex;
  align-items: center;
  justify-content: space-between;

  span {
    font-size: 14px;
    font-weight: 200;
    color: rgba(${props => props.theme.fontColor || '255, 255, 255'}, 1);
  }
`;

const Hint = styled.div`
  display: flex;
  align-items: center;
  gap: 4px;

  color: rgba(${props => props.theme.fontColor || '255, 255, 255'}, 0.7);

  small {
    font-size: 13px;
    min-width: 42px;
    text-align: center;
  }
`;

const TextureControl: React.FC<TextureControlProps> = ({ title, min = 0, max = 255, blacklisted = [], value, onChange }) => {
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight') {
        onChange(stepValue(value, 1, min, max, blacklisted));
      } else if (e.key === 'ArrowLeft') {
        onChange(stepValue(value, -1, min, max, blacklisted));
      }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [value, min, max, blacklisted, onChange]);

  return (
    <Row>
      <span>{title}</span>
      <Hint>
        <FiChevronLeft size={18} />
        <small>{value} / {max}</small>
        <FiChevronRight size={18} />
      </Hint>
    </Row>
  );
};

export default TextureControl;
