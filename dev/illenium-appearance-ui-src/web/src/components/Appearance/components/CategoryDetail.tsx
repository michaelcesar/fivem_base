import { ReactNode } from 'react';
import styled from 'styled-components';
import { FiChevronLeft } from 'react-icons/fi';

// Server: the screen shown after entering a CategoryCard - a back row (chevron + the category's
// own title) above whatever the caller renders (DrawableGrid + texture Input, in practice).
// See ADR-078.
const Container = styled.div`
  width: 100%;
  margin-top: 0.5rem;

  display: flex;
  flex-direction: column;

  padding: 10px;
  border-radius: 2px;

  background: rgba(${props => props.theme.secondayBackground || '0, 0, 0'}, 0.3);
`;

const BackRow = styled.button`
  display: flex;
  align-items: center;
  gap: 4px;

  outline: 0;
  border: none;
  background: none;
  padding: 0;
  cursor: pointer;

  color: rgba(${props => props.theme.fontColor || '255, 255, 255'}, 1);

  &:hover {
    color: rgba(${props => props.theme.fontColorHover || '255, 255, 255'}, 1);
  }

  span {
    font-size: 15px;
    font-weight: ${props => props.theme.sectionFontWeight || 'normal'};
  }
`;

const CategoryDetail: React.FC<{ title: string; onBack: () => void; children: ReactNode }> = ({
  title,
  onBack,
  children,
}) => (
  <Container>
    <BackRow type="button" onClick={onBack}>
      <FiChevronLeft size={20} />
      <span>{title}</span>
    </BackRow>
    {children}
  </Container>
);

export default CategoryDetail;
