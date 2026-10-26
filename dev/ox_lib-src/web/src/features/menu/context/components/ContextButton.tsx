import { Button, createStyles, Group, HoverCard, Image, Progress, Stack, Text } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import { ContextMenuProps, Option } from '../../../../typings';
import { fetchNui } from '../../../../utils/fetchNui';
import { isIconUrl } from '../../../../utils/isIconUrl';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import MarkdownComponents from '../../../../config/MarkdownComponents';
import LibIcon from '../../../../components/LibIcon';
import { gfx, hudCorner } from '../../../../theme';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: false });
};

const clickContext = (id: string) => {
  fetchNui('clickContext', id);
};

const useStyles = createStyles((_theme, params: { disabled?: boolean; readOnly?: boolean; colorScheme?: string; focused?: boolean }) => ({
  inner: {
    justifyContent: 'flex-start',
  },
  // Server: a readOnly row differs from an actionable one by COLOUR ALONE. It used to also shrink
  // the title to 12.5px and drop it to weight 400 with normal letter-spacing, on the reasoning that
  // such a row reads as an informational note rather than an action. That was wrong once readOnly
  // rows started being used as titled cards (the dealers' quantity cards): sitting beside a normal
  // option, the smaller, lighter title read as a rendering fault rather than as a deliberate mute.
  // Reported exactly that way. The theme's own Button styles supply the size, weight (600) and
  // 0.06em letter-spacing, so removing the overrides is what makes a card title identical to every
  // other title. See ADR-091.
  label: {
    width: '100%',
    whiteSpace: 'pre-wrap',
    ...(params.readOnly && {
      color: gfx.textLow,
    }),
  },
  button: {
    height: 'fit-content',
    width: '100%',
    padding: 10,
    // Server: a readOnly row is a plaque, not a button - filled and borderless, against the
    // outlined look every actionable row has. This is the affordance that replaced shrinking its
    // text (ADR-091): type now matches everywhere, so the "you cannot press this" signal has to
    // come from the surface instead.
    //
    // It has to differ from BOTH neighbours, which is why a filled background rather than just a
    // dimmer border: the theme already dims the border of a `:disabled` row, so an unavailable
    // action ("Comprar saquinho" with no stock) and an informational card would otherwise look
    // identical. Three states now read apart - outlined bright (available), outlined dim
    // (unavailable), filled (not an action at all).
    //
    // `&:disabled` is required, not belt-and-braces: ContextButton renders readOnly rows as
    // disabled buttons, and the theme's own `&:disabled` block is a pseudo-class selector, so it
    // outranks a plain class and would win against a bare `background` here. See ADR-092.
    // Server: the fill is a white overlay, not a palette tone. The first attempt used `gfx.bg2`
    // (#141414) against the menu's `gfx.panel` (#0f0f0f) - five points apart, which read as the same
    // surface in game and defeated the point. An alpha overlay lifts the row off whatever is behind
    // it by a fixed amount instead of hoping two near-identical hex values look different.
    //
    // `colorScheme` tints that surface where a row has a state worth carrying (a completed
    // certificate, a warning). It deliberately does NOT drive the text here - ADR-087 settled that
    // a status readout keeps the standard grey, and the description rule below is what honours it.
    ...(params.readOnly && {
      '&, &:disabled': {
        background:
          params.colorScheme === 'green'
            ? 'rgba(62, 207, 126, 0.10)'
            : params.colorScheme === 'red'
              ? 'rgba(224, 85, 74, 0.10)'
              : 'rgba(255, 255, 255, 0.06)',
        borderColor: 'transparent',
        color: gfx.textLow,
      },
    }),
    // Server: arrow-key navigation's own highlight (`ContextMenu.tsx`'s `focusedIndex`) - an
    // inset ring so it never shifts layout the way a thicker border would, and layers cleanly over
    // both the outlined actionable look and the filled readOnly one above. Restores what
    // `lib.registerMenu`'s own list always showed for its current selection.
    ...(params.focused && {
      boxShadow: `inset 0 0 0 1px ${gfx.blueBright}`,
    }),
  },
  iconImage: {
    maxWidth: '25px',
  },
  // colorScheme 'green' marks a positive readOnly state (e.g. a certificate already
  // earned), so it stays legible instead of being dimmed like a locked/disabled row.
  // Server: the description is always exactly one line. Requested so every card in a context
  // menu is the same height - a two-line description made its own card taller than its
  // neighbours (reported from the clothing shop menu, but it happens anywhere a description runs
  // long). ReactMarkdown renders the text into a <p>, so the clamp has to target that, not this
  // wrapper. This is a guarantee, not a substitute for sensible text: the project's own overly
  // long descriptions were shortened in the same pass so the ellipsis is a safety net rather
  // than something players actually see. See ADR-079.
  // Server: the description follows the same rule as the label above - one size for every row,
  // readOnly or not. It used to shrink to 10.5px at 55% opacity, which paired with the shrunken
  // title to make a readOnly card look like a half-rendered one. See ADR-091.
  description: {
    fontSize: 12,
    color: params.colorScheme === 'green' ? gfx.green : gfx.textLow,
    opacity: 1,
    '& p': {
      margin: 0,
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
    },
  },
  // Server: this project's own HUD card look (same treatment TextUI.tsx's prompt and
  // CircleProgressbar.tsx's badge already use) instead of Mantine's default white popover -
  // requested once the vehicle-preview hover card (ADR-075) was the first thing in this project
  // to actually show it. Background is `gfx.panel`'s own tone at reduced alpha rather than the
  // fully opaque panel every other card uses - a translucent look was asked for specifically
  // here, letting the game world read through slightly behind a secondary hover popup.
  // NOTE: do NOT add `position` here. Mantine positions this dropdown with `position: absolute`
  // from its own default dropdown class, and feeds it the floating-ui result as inline
  // `top`/`left`. Overriding position with `relative` (added here once, to anchor hudCorner's
  // ::before) makes those inline offsets shift the card from its normal-flow spot instead - and
  // since `withinPortal` puts that spot at the end of <body>, the card lands off at the screen
  // edge. hudCorner's ::before anchors fine without it: Mantine's own `absolute` already makes
  // this element a containing block.
  dropdown: {
    padding: 10,
    color: gfx.textHi,
    fontSize: 14,
    maxWidth: 256,
    width: 'fit-content',
    background: 'rgba(15, 15, 15, 0.82)',
    border: `1px solid ${gfx.line}`,
    borderRadius: 3,
    boxShadow: '0 14px 28px rgba(0,0,0,0.4)',
    ...hudCorner,
  },
  buttonStack: {
    gap: 4,
    flex: '1',
    // Server: without this the description's ellipsis above can never trigger - a flex item's
    // default `min-width: auto` is its own content width, so the text refuses to shrink and
    // overflows instead of clipping. Same trap as the `min-height: 0` that fixes flex scrolling
    // (docs/conventions.md), on the other axis. See ADR-079.
    minWidth: 0,
  },
  buttonGroup: {
    gap: 4,
    flexWrap: 'nowrap',
  },
  buttonIconContainer: {
    width: 25,
    height: 25,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonTitleText: {
    overflowWrap: 'break-word',
  },
  buttonArrowContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    width: 25,
    height: 25,
  },
}));

const ContextButton: React.FC<{
  option: [string, Option];
  focused?: boolean;
}> = ({ option, focused }) => {
  const button = option[1];
  const buttonKey = option[0];
  const { classes } = useStyles({
    disabled: button.disabled,
    readOnly: button.readOnly,
    focused,
    colorScheme: button.colorScheme,
  });

  return (
    <>
      <HoverCard
        // Server: the actual bug, found after zIndex and position both failed to help: Mantine
        // v5's HoverCard defaults `withinPortal` to FALSE, so the dropdown rendered as a normal
        // DOM child inside ContextMenu.tsx's own `contentSection` - which has `overflowY:
        // 'scroll'`. That clips ANY descendant positioned outside its box, before z-index or
        // position ever come into play; changing either one was treating a symptom of the wrong
        // cause. `withinPortal` moves the dropdown to a portal outside that scrolling container
        // entirely, which is what actually needed to happen. See ADR-075.
        withinPortal
        // Server: was 'right-start' - ContextMenu.tsx's own container sits at `right: 20%` (see
        // its `container` style), so opening further right pushed the card toward/past the
        // screen edge. Still correct now that withinPortal fixed the real bug - kept.
        position="left-start"
        disabled={button.disabled || button.readOnly || !(button.metadata || button.image)}
        openDelay={200}
        // Server: needed now that withinPortal is on - a portalled dropdown escapes this app's
        // own stacking context entirely, so it needs its own explicit z-index to sit above
        // everything else (in-game HUD included). 1000 clears every zIndex this app sets
        // deliberately (1/2 on the menu's own sections) while staying under the grain overlay's
        // 9999 (which has pointer-events:none anyway, so draw order there doesn't matter).
        zIndex={1000}
      >
        <HoverCard.Target>
          <Button
            // Server: lets ContextMenu.tsx find the arrow-key-focused row in the DOM and scroll
            // it into view. Moving `focusedIndex` highlighted a row but never moved the list, so
            // arrowing past the visible area left the highlight offscreen and the menu looking
            // like the arrows did nothing - only the mouse wheel scrolled. See ADR-143.
            data-focused={focused ? 'true' : undefined}
            classNames={{ inner: classes.inner, label: classes.label, root: classes.button }}
            onClick={() =>
              !button.disabled && !button.readOnly
                ? button.menu
                  ? openMenu(button.menu)
                  : clickContext(buttonKey)
                : null
            }
            variant="filled"
            color={button.colorScheme === 'red' ? 'red' : undefined}
            disabled={button.disabled || button.readOnly}
          >
            <Group position="apart" w="100%" noWrap>
              <Stack className={classes.buttonStack}>
                {(button.title || Number.isNaN(+buttonKey)) && (
                  <Group className={classes.buttonGroup}>
                    {button?.icon && (
                      <Stack className={classes.buttonIconContainer}>
                        {typeof button.icon === 'string' && isIconUrl(button.icon) ? (
                          <img src={button.icon} className={classes.iconImage} alt="Missing img" />
                        ) : (
                          <LibIcon
                            icon={button.icon as IconProp}
                            fixedWidth
                            size="lg"
                            style={{ color: button.iconColor }}
                            animation={button.iconAnimation}
                          />
                        )}
                      </Stack>
                    )}
                    <Text className={classes.buttonTitleText}>
                      <ReactMarkdown components={MarkdownComponents}>{button.title || buttonKey}</ReactMarkdown>
                    </Text>
                  </Group>
                )}
                {button.description && (
                  <Text className={classes.description}>
                    <ReactMarkdown components={MarkdownComponents}>{button.description}</ReactMarkdown>
                  </Text>
                )}
                {button.progress !== undefined && (
                  <Progress value={button.progress} size="sm" color={button.colorScheme || 'dark.3'} />
                )}
              </Stack>
              {(button.menu || button.arrow) && button.arrow !== false && (
                <Stack className={classes.buttonArrowContainer}>
                  <LibIcon icon="chevron-right" fixedWidth />
                </Stack>
              )}
            </Group>
          </Button>
        </HoverCard.Target>
        <HoverCard.Dropdown className={classes.dropdown}>
          {button.image && <Image src={button.image} />}
          {Array.isArray(button.metadata) ? (
            button.metadata.map(
              (
                metadata: string | { label: string; value?: any; progress?: number; colorScheme?: string },
                index: number
              ) => (
                <>
                  <Text key={`context-metadata-${index}`}>
                    {typeof metadata === 'string' ? `${metadata}` : `${metadata.label}: ${metadata?.value ?? ''}`}
                  </Text>

                  {typeof metadata === 'object' && metadata.progress !== undefined && (
                    <Progress
                      value={metadata.progress}
                      size="sm"
                      color={metadata.colorScheme || button.colorScheme || 'dark.3'}
                    />
                  )}
                </>
              )
            )
          ) : (
            <>
              {typeof button.metadata === 'object' &&
                Object.entries(button.metadata).map((metadata: { [key: string]: any }, index) => (
                  <Text key={`context-metadata-${index}`}>
                    {metadata[0]}: {metadata[1]}
                  </Text>
                ))}
            </>
          )}
        </HoverCard.Dropdown>
      </HoverCard>
    </>
  );
};

export default ContextButton;
