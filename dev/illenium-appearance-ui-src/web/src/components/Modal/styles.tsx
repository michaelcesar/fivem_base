import styled from 'styled-components';

// Server: was a bare full-screen dim backdrop with floating text and no card at all - every
// other panel in this project (DrawableGrid's tiles, CategoryCard, TextureControl) uses a dark
// HUD card (rgba(15, 15, 15, 0.82) background, thin rgba(255,255,255,.14) border, sharp 3px
// corners, a soft drop shadow). Restyled this confirmation dialog to match: the backdrop stays
// full-screen and centers content, but the text now sits inside an actual `Panel` card instead
// of floating directly over the darkened game view. See ADR-078.
export const Wrapper = styled.div`
  width: 100vw;
  height: 100vh;

  position: absolute;

  left: 0;
  top: 0;

  display: flex;
  align-items: center;
  justify-content: center;

  user-select: none;

  background: rgba(0, 0, 0, 0.6);
`;

export const Panel = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;

  width: 360px;
  padding: 24px;

  border-radius: 3px;
  border: 1px solid rgba(255, 255, 255, 0.14);
  background: rgba(15, 15, 15, 0.82);
  box-shadow: 0 14px 28px rgba(0, 0, 0, 0.4);

  text-align: center;

  p {
    margin: 0;
    font-size: 18px;
    font-weight: 700;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    color: rgba(${props => props.theme.fontColor || '255, 255, 255'}, 1);
  }

  span {
    margin-top: 6px;
    font-size: 13px;
    color: rgba(${props => props.theme.fontColor || '255, 255, 255'}, 0.55);
  }
`;

export const Buttons = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;

  margin-top: 20px;
  width: 100%;

  button {
    flex: 1;
    height: 36px;

    display: flex;
    justify-content: center;
    align-items: center;

    border-radius: 3px;
    border: 1px solid rgba(255, 255, 255, 0.14);
    background: rgba(255, 255, 255, 0.03);

    color: rgba(${props => props.theme.fontColor || '255, 255, 255'}, 1);
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.04em;
    text-transform: uppercase;

    cursor: pointer;
    transition: background 0.1s;

    &:hover {
      color: rgba(${props => props.theme.fontColorHover || '255, 255, 255'}, 1);
      background: rgba(${props => props.theme.primaryBackground || '0, 0, 0'}, 0.9);
      ${props => (props.theme.smoothBackgroundTransition ? 'transition: background 0.2s;' : '')}
    }
  }
`;
