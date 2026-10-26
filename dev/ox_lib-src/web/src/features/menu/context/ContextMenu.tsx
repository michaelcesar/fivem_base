import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { Box, createStyles, Flex, Stack, Text, TextInput } from '@mantine/core';
import { useEffect, useRef, useState } from 'react';
import { ContextMenuProps } from '../../../typings';
import ContextButton from './components/ContextButton';
import { fetchNui } from '../../../utils/fetchNui';
import ReactMarkdown from 'react-markdown';
import HeaderButton from './components/HeaderButton';
import LibIcon from '../../../components/LibIcon';
import ScaleFade from '../../../transitions/ScaleFade';
import MarkdownComponents from '../../../config/MarkdownComponents';
import { useLocales } from '../../../providers/LocaleProvider';
import { cardWrapperSx, cardMainLabelSx, cardMainSublabelSx, gfx } from '../../../theme';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: true });
};

// Server: same shape as `ContextButton.tsx`'s own local `clickContext` - duplicated rather than
// shared, matching how `openMenu` above is already duplicated between the two files. Needed here
// too so Enter can fire the exact same NUI callback a mouse click on the focused row would.
const clickContext = (id: string) => {
  fetchNui('clickContext', id);
};

const useStyles = createStyles(() => ({
  container: {
    position: 'absolute',
    top: '15%',
    right: '20%',
    width: 460,
    height: 580,
  },
  // Server: ScaleFade renders a bare div between `container` and `mainWrapper`. Without a
  // height here, `mainWrapper`'s `height: 100%` resolves against an auto-height parent - which
  // means it does not resolve at all, and the card grows to fit its content instead of being
  // capped at container's 580. `contentSection` then never has a constrained height to scroll
  // inside, and a long list just runs off the bottom of the screen. Reported as "tá sem o
  // scroll, quebrando lá embaixo"; `minHeight: 0` below is necessary but was not sufficient
  // on its own, because the break in the height chain is up here.
  fadeWrapper: {
    height: '100%',
  },
  // The single card that wraps both the label section and the content section.
  mainWrapper: {
    ...cardWrapperSx,
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    // Server: the gutter between the last visible row and the card's bottom border. It has to be
    // HERE, on the card, rather than inside the scrolling section: padding inside a scroll box is
    // part of the scrolled content, so it only shows once you have scrolled all the way down - and
    // mid-list the rows still ran flush into the border. Reported twice for that reason; the first
    // attempt put it on the content and looked unchanged.
    //
    // 12 mirrors `labelSection`'s own top padding, so the card is inset by the same amount at both
    // ends.
    paddingBottom: 12,
  },
  // Section 1: main label (+ optional sublabel) and the back/close controls.
  labelSection: {
    alignItems: 'center',
    gap: 6,
    padding: '12px 30px 12px 14px', // extra right padding clears the absolutely-positioned close button
    borderBottom: `1px solid ${gfx.line}`,
    position: 'relative',
    zIndex: 1,
  },
  closeButton: {
    position: 'absolute',
    top: 6,
    right: 6,
    zIndex: 2,
  },
  // Server: sits between the label and the option list, same horizontal rhythm as
  // `contentSection`'s own padding so the input edges line up with the cards below it.
  searchSection: {
    padding: '8px 14px',
    borderBottom: `1px solid ${gfx.line}`,
  },
  labelBlock: {
    flex: 1,
    minWidth: 0,
  },
  mainLabel: {
    ...cardMainLabelSx,
  },
  mainSublabel: {
    ...cardMainSublabelSx,
  },
  // Section 2: the actual content (character rows, menu options, etc).
  contentSection: {
    flex: 1,
    // Server: without this, a flex child's default min-height is its own content size, not 0 -
    // so a long list (16 cars in qbx_vehicleshop's "sports" category, first menu in this project
    // big enough to expose it) grows the box past mainWrapper's fixed height instead of
    // shrinking and actually engaging `overflowY: scroll` below. Reported as "sem scroll, fica
    // cortado" - the exact shape CLAUDE.md's own rule 10 already names (a missing min-height in
    // a shared flex container, not a bug in whatever menu happens to be long enough to show it).
    minHeight: 0,
    overflowY: 'scroll',
    // Server: no bottom padding HERE on purpose - see `buttonsFlexWrapper` below. A scrolling
    // container's own `padding-bottom` is not reliably drawn past the end of overflowing content,
    // so the last row ended up flush against the card's edge while the first row had clear space
    // above it. Reported as the bottom of the list looking cut off.
    padding: '10px 14px 0',
    position: 'relative',
    zIndex: 1,
  },
  buttonsFlexWrapper: {
    gap: 6,
    // A small amount inside the scroll box too, so the LAST row still clears the fade at the end of
    // the list rather than stopping exactly at it. The visible gutter is `mainWrapper`'s
    // `paddingBottom`; this is only about where the scrolled content ends.
    paddingBottom: 4,
  },
  // Server: one row of side-by-side options (see `inline` in typings/context.ts). `stretch` is
  // what makes two cards of unequal text length still end up the same height, which is the whole
  // reason to put them side by side rather than stacked.
  inlineRow: {
    gap: 6,
    alignItems: 'stretch',
  },
  // Each inline option takes an equal share of the row. `minWidth: 0` is required, not cosmetic:
  // a flex item's default `min-width: auto` is its content size, so a long label would push its
  // neighbour narrower instead of ellipsising inside its own half. The `& button` rule makes the
  // button fill the cell it was given, since ContextButton's own root is `height: fit-content`
  // and would otherwise leave the shorter card floating at the top of a taller row.
  inlineItem: {
    flex: 1,
    minWidth: 0,
    display: 'flex',
    '& button': {
      height: '100%',
    },
  },
  // Server: shown instead of an empty list when a menu has no options at all. Mirrors the
  // phone's own EmptyState (dev/npwd-src/apps/phone/src/ui/components/EmptyState.tsx - circle
  // badge, bold label, muted sublabel, centred) so "no items" reads the same everywhere on the
  // server, translated into this HUD's palette rather than the phone's Tailwind neutrals.
  // Requested after a menu with no saved outfits opened as a plain black void. See ADR-080.
  emptyState: {
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
    padding: '0 24px',
    textAlign: 'center',
  },
  emptyBadge: {
    width: 56,
    height: 56,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: '50%',
    background: gfx.bg2,
    border: `1px solid ${gfx.line}`,
    color: gfx.textLow,
  },
  emptyLabel: {
    fontFamily: 'Rajdhani, sans-serif',
    fontWeight: 700,
    fontSize: 15,
    letterSpacing: '0.06em',
    textTransform: 'uppercase',
    color: gfx.textHi,
  },
  emptySublabel: {
    fontSize: 12,
    lineHeight: 1.45,
    color: gfx.textLow,
  },
}));

const ContextMenu: React.FC = () => {
  const { classes } = useStyles();
  const { locale } = useLocales();
  const [visible, setVisible] = useState(false);
  const [contextMenu, setContextMenu] = useState<ContextMenuProps>({
    title: '',
    options: { '': { description: '', metadata: [] } },
  });
  // Server: real-time filtering for long lists (the admin item-give picker runs past 200 rows) -
  // requested as an actual live search box, not a dialog-then-confirm round trip through Lua. Pure
  // client-side state: every keystroke re-filters instantly, no NUI callback involved.
  const [search, setSearch] = useState('');
  // Server: which row arrow-key navigation currently sits on - `lib.registerMenu`'s own list
  // supported Up/Down/Enter/Backspace, and converting every screen in `qbx_adminmenu` to
  // `lib.registerContext` (ADR-118) dropped that for mouse-only. Restored here instead of per
  // menu, so every context menu in the project gets it back at once.
  const [focusedIndex, setFocusedIndex] = useState(0);

  // Server: the scrolling container, so the arrow-key highlight can drag the list with it.
  const contentRef = useRef<HTMLDivElement>(null);

  // Arrow keys moved `focusedIndex` but nothing ever scrolled - the highlight simply walked off
  // the bottom of the visible area and the menu looked frozen unless you used the mouse wheel.
  // Reported exactly that way. `nearest` rather than `center` so a short list does not jump.
  useEffect(() => {
    const focused = contentRef.current?.querySelector('[data-focused="true"]');

    focused?.scrollIntoView({ block: 'nearest' });
  }, [focusedIndex]);

  const closeContext = () => {
    if (contextMenu.canClose === false) return;
    setVisible(false);
    fetchNui('closeContext');
  };

  // Hides on ESC; Up/Down move the highlighted row; Enter fires it, identically to a mouse click;
  // Backspace goes back a level, the same as clicking the header's own back arrow - but ONLY when
  // focus isn't inside the search box, where Backspace has to keep deleting a character instead.
  useEffect(() => {
    if (!visible) return;

    const keyHandler = (e: KeyboardEvent) => {
      if (e.code === 'Escape') {
        closeContext();
        return;
      }

      if (e.code === 'ArrowDown' || e.code === 'ArrowUp') {
        e.preventDefault();
        setFocusedIndex((current) => {
          const count = options.length;
          if (count === 0) return 0;

          // Server: wraps rather than clamps - Down on the last row goes to the first, Up on the
          // first goes to the last. `lib.registerMenu`'s own list behaved this way and the
          // conversion to `lib.registerContext` lost it along with the arrow keys themselves;
          // restoring the keys (ADR-118) restored the movement but not the wrap. On a long list,
          // reaching the bottom item and pressing Down again did nothing at all, which reads as
          // the key having stopped working.
          const delta = e.code === 'ArrowDown' ? 1 : -1;
          return (current + delta + count) % count;
        });
        return;
      }

      if (e.code === 'Enter') {
        const focused = options[focusedIndex];
        if (!focused) return;
        const [key, option] = focused;
        if (option.disabled || option.readOnly) return;
        e.preventDefault();
        option.menu ? openMenu(option.menu) : clickContext(key);
        return;
      }

      if (e.code === 'Backspace') {
        const activeTag = document.activeElement?.tagName;
        if (activeTag === 'INPUT' || activeTag === 'TEXTAREA') return;
        e.preventDefault();
        // Server: a submenu goes back one level; the ROOT menu (no `menu` back-target at all)
        // closes outright instead of doing nothing - the same thing `lib.registerMenu`'s own
        // top-level `onClose` already did for any key when there was nowhere left to go back to.
        // Reported: pressing Backspace on `/admin`'s own first screen did nothing.
        if (contextMenu.menu) {
          openMenu(contextMenu.menu);
        } else {
          closeContext();
        }
      }
    };

    window.addEventListener('keydown', keyHandler);

    return () => window.removeEventListener('keydown', keyHandler);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [visible, focusedIndex, contextMenu.menu]);

  useNuiEvent('hideContext', () => setVisible(false));

  useNuiEvent<ContextMenuProps>('showContext', async (data) => {
    if (visible) {
      setVisible(false);
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
    setContextMenu(data);
    setSearch('');
    setFocusedIndex(0);
    setVisible(true);
  });

  // Server: computed once so the empty check and the list render can never disagree about what
  // "no options" means. The initial state seeds a single blank-key placeholder entry, so this is
  // also what keeps the empty state from flashing before the first real payload arrives.
  const allOptions = Object.entries(contextMenu.options).filter(([key, option]) => key !== '' || option.title);

  // Server: only shown past 8 rows - a short confirm-style menu (2-4 options) never needs it, and
  // an always-present empty box on those would just be clutter. Matches on the title AND the
  // description, since the item picker's real catalog key lives in the description line, not the
  // title (`weapon_part` vs `Peça de Arma`) - searching either has to find it.
  const needle = search.trim().toLowerCase();
  const options =
    allOptions.length > 8 && needle
      ? allOptions.filter(([, option]) => {
          const haystack = `${option.title ?? ''} ${option.description ?? ''}`.toLowerCase();
          return haystack.includes(needle);
        })
      : allOptions;

  // Server: group consecutive `inline` options into shared rows. Everything else stays one option
  // per row, so a menu that never sets the flag renders exactly as it did before. Grouping happens
  // here rather than in ContextButton because a button cannot know what sits next to it. See
  // ADR-088. Each item keeps its own flat position (`focusIndex`) from BEFORE grouping - that is
  // what arrow-key navigation above counts against, so an inline pair still gets highlighted one
  // at a time, in the same left-to-right order Up/Down was already moving through.
  type FlatEntry = { entry: (typeof options)[number]; focusIndex: number };
  const rows: { inline: boolean; items: FlatEntry[] }[] = [];
  options.forEach((entry, focusIndex) => {
    const isInline = !!entry[1].inline;
    const current = rows[rows.length - 1];
    const flat: FlatEntry = { entry, focusIndex };

    if (current && current.inline && isInline) current.items.push(flat);
    else rows.push({ inline: isInline, items: [flat] });
  });

  return (
    <Box className={classes.container}>
      <ScaleFade visible={visible} className={classes.fadeWrapper}>
        <Box className={classes.mainWrapper}>
          <Flex className={classes.labelSection}>
            {contextMenu.menu && (
              <HeaderButton icon="chevron-left" iconSize={16} handleClick={() => openMenu(contextMenu.menu)} />
            )}
            <Box className={classes.labelBlock}>
              <Text className={classes.mainLabel}>
                <ReactMarkdown components={MarkdownComponents}>{contextMenu.title}</ReactMarkdown>
                <span>:</span>
              </Text>
              {contextMenu.description && (
                <Text className={classes.mainSublabel}>
                  <ReactMarkdown components={MarkdownComponents}>{contextMenu.description}</ReactMarkdown>
                </Text>
              )}
            </Box>
          </Flex>
          {contextMenu.canClose !== false && (
            <Box className={classes.closeButton}>
              <HeaderButton icon="xmark" canClose={contextMenu.canClose} iconSize={12} handleClick={closeContext} />
            </Box>
          )}
          {allOptions.length > 8 && (
            <Box className={classes.searchSection}>
              <TextInput
                value={search}
                onChange={(e) => setSearch(e.currentTarget.value)}
                placeholder="Buscar..."
                icon={<LibIcon icon="magnifying-glass" fixedWidth />}
                size="xs"
                autoFocus
              />
            </Box>
          )}
          <Box className={classes.contentSection} ref={contentRef}>
            {options.length === 0 ? (
              <Box className={classes.emptyState}>
                <Box className={classes.emptyBadge}>
                  <LibIcon icon="inbox" fixedWidth size="lg" />
                </Box>
                <Text className={classes.emptyLabel}>{locale.ui.empty_title}</Text>
                <Text className={classes.emptySublabel}>{locale.ui.empty_description}</Text>
              </Box>
            ) : (
              <Stack className={classes.buttonsFlexWrapper}>
                {rows.map((row, rowIndex) =>
                  row.inline ? (
                    <Flex className={classes.inlineRow} key={`context-row-${rowIndex}`}>
                      {row.items.map(({ entry, focusIndex }, index) => (
                        <Box className={classes.inlineItem} key={`context-item-${rowIndex}-${index}`}>
                          <ContextButton option={entry} focused={focusIndex === focusedIndex} />
                        </Box>
                      ))}
                    </Flex>
                  ) : (
                    row.items.map(({ entry, focusIndex }, index) => (
                      <ContextButton option={entry} focused={focusIndex === focusedIndex} key={`context-item-${rowIndex}-${index}`} />
                    ))
                  )
                )}
              </Stack>
            )}
          </Box>
        </Box>
      </ScaleFade>
    </Box>
  );
};

export default ContextMenu;
