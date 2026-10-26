import styled from 'styled-components';

export const Wrapper = styled.div`
  height: 100vh;
  width: 100vw;

  display: flex;
  align-items: flex-start;
  justify-content: flex-start;
  overflow: hidden;
`;

export const Container = styled.div`
  height: 100%;
  width: 20%;
  max-width: 400px;

  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: flex-start;

  padding: 40px 10px;

  /*
    Server: this panel and the Options toolbar beside it both start their content 40px from the
    top (Options.tsx's own Container uses the same 40px top padding), so they should line up -
    but every candidate first child carries its own top margin for sibling spacing: CardGrid
    10px, CategoryDetail and Item 0.5rem, Section 10px via its adjacent-sibling rule. Whichever
    one rendered first added that margin on top of the 40px and pushed the whole left column
    below the toolbar's first button - reported, then confirmed with a screenshot marking where
    the cards should have begun. Zeroed here, on the shared parent that owns the 40px, rather
    than in each child: those margins are still correct between siblings, they were only ever
    wrong on the first one. See ADR-078.
  */
  > *:first-child {
    margin-top: 0;
  }

  background: linear-gradient(
    to right,
    rgba(${props => props.theme.secondaryBackground || '0, 0, 0'}, 0.8),
    rgba(${props => props.theme.secondaryBackground || '0, 0, 0'}, 0)
  );

  overflow-y: scroll;

  ::-webkit-scrollbar {
    width: 0px;
  }

  ::-webkit-scrollbar-track {
    background: rgba(${props => props.theme.primaryBackground || '0, 0, 0'}, 0.2);
  }

  ::-webkit-scrollbar-thumb {
    background: rgba(${props => props.theme.primaryBackground || '0, 0, 0'}, 0.2);
    border-radius: 3vh;
  }

  ::-webkit-scrollbar-thumb:hover {
    background: rgba(${props => props.theme.primaryBackground || '0, 0, 0'}, 0.2);
  }
`;

export const FlexWrapper = styled.div`
  width: 100%;

  display: flex;

  > div {
    & + div {
      margin-left: 10px;
    }
  }
`;
