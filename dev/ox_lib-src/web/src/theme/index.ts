import { MantineThemeOverride } from '@mantine/core';

// Ilha RP theme, ported from the "GFX" installer's HUD/sci-fi design language,
// recolored to a monochrome black/white/gray palette for a more premium feel:
// near-black panels, a silver-to-white accent, thin 1px borders, HUD corner
// brackets on cards, Rajdhani for display text + Inter for body text.

export const gfx = {
  bg0: '#050505',
  bg1: '#0c0c0c',
  bg2: '#141414',
  panel: '#0f0f0f',
  line: 'rgba(255,255,255,0.14)',
  blue: '#b5b5b5', // silver accent (idle state) - kept the "blue" key name to minimize churn
  blueBright: '#ffffff', // hover/active accent
  blueDim: '#5c5c5c',
  textHi: '#f2f2f2',
  textMid: '#a3a3a3',
  textLow: '#6b6b6b',
  green: '#3ecf7e',
  red: '#e0554a',
};

// Small HUD corner bracket (top-left) used on panels/cards throughout the reference design.
export const hudCorner = {
  '&::before': {
    content: '""',
    position: 'absolute' as const,
    width: 14,
    height: 14,
    top: -1,
    left: -1,
    borderTop: `2px solid rgba(255,255,255,.35)`,
    borderLeft: `2px solid rgba(255,255,255,.35)`,
    pointerEvents: 'none' as const,
  },
};

// The panel/card look: dark surface, thin border, sharp corners, HUD bracket accent.
export const cardWrapperSx = {
  position: 'relative' as const,
  // No overflow:hidden here - Select/DatePicker dropdowns would otherwise get clipped
  // by this card when they're not (or can't be) rendered in a portal.
  background: gfx.panel,
  border: `1px solid ${gfx.line}`,
  borderRadius: 3,
  boxShadow: '0 14px 28px rgba(0,0,0,0.4)',
  ...hudCorner,
};

// "Panel title" treatment - the main label of a wrapper section, with the
// trailing gradient rule the reference design uses after section headings.
export const cardMainLabelSx = {
  fontFamily: 'Rajdhani, sans-serif',
  fontWeight: 700,
  fontSize: 15,
  color: gfx.textHi,
  textTransform: 'uppercase' as const,
  letterSpacing: '0.08em',
  textAlign: 'left' as const,
  position: 'relative' as const,
  zIndex: 1,
  display: 'flex',
  alignItems: 'center',
  '&::after': {
    content: '""',
    flex: 1,
    height: 1,
    marginLeft: 10,
    background: `linear-gradient(90deg, rgba(255,255,255,.35), transparent)`,
  },
};

export const cardMainSublabelSx = {
  fontFamily: 'Inter, sans-serif',
  fontSize: 11,
  color: gfx.textLow,
  textAlign: 'left' as const,
  marginTop: 4,
  letterSpacing: '0.02em',
  position: 'relative' as const,
  zIndex: 1,
};

// Faint film-grain overlay, matching the reference app's ".grain" texture.
const grainDataUri =
  'url(\'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120"><filter id="n"><feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" stitchTiles="stitch"/></filter><rect width="100%25" height="100%25" filter="url(%23n)"/></svg>\')';

export const theme: MantineThemeOverride = {
  colorScheme: 'dark',
  fontFamily: 'Inter, sans-serif',
  headings: {
    fontFamily: 'Rajdhani, sans-serif',
    fontWeight: 700,
  },
  shadows: { sm: '0 8px 20px rgba(0,0,0,0.35)' },
  colors: {
    // Monochrome silver ramp, light (0) -> near-black (9).
    ocean: [
      '#f5f5f5',
      '#e0e0e0',
      '#cccccc',
      '#b8b8b8',
      '#a3a3a3',
      '#8f8f8f',
      '#737373',
      '#595959',
      '#404040',
      '#262626',
    ],
  },
  primaryColor: 'ocean',
  primaryShade: 5,
  components: {
    Button: {
      styles: (_theme, params) => {
        const isDanger = params.color === 'red';
        const accent = isDanger ? gfx.red : gfx.blue;
        const accentBright = isDanger ? '#ff8a80' : gfx.blueBright;

        return {
          root: {
            position: 'relative',
            border: `1px solid ${isDanger ? 'rgba(224,85,74,.4)' : 'rgba(255,255,255,.3)'}`,
            background: 'transparent',
            color: accent,
            borderRadius: 2,
            fontFamily: 'Inter, sans-serif',
            fontWeight: 600,
            letterSpacing: '0.06em',
            transition: 'background 150ms ease, transform 150ms ease, box-shadow 150ms ease, color 150ms ease',
            '&:hover': {
              background: isDanger ? 'rgba(224,85,74,.12)' : 'rgba(255,255,255,.12)',
              color: accentBright,
              transform: 'translateY(-1px)',
              boxShadow: `0 6px 18px ${isDanger ? 'rgba(224,85,74,.18)' : 'rgba(255,255,255,.16)'}`,
            },
            '&:active': {
              transform: 'translateY(0)',
            },
            '&:disabled': {
              background: 'transparent',
              borderColor: gfx.line,
              color: gfx.textLow,
            },
          },
          label: {
            letterSpacing: '0.06em',
          },
        };
      },
    },
    // NOTE: Mantine's InputLabel/InputDescription/InputError components resolve their
    // theme override under the "InputWrapper" name (not their own component name), so
    // label/description/required/error all have to live here for overrides to apply.
    InputWrapper: {
      styles: {
        root: {
          ...cardWrapperSx,
          padding: '12px 16px 16px',
          marginBottom: 10,
        },
        label: {
          background: 'none',
          textAlign: 'left',
          // display:flex lets us use `order` to place the ":" between the label text
          // and Mantine's own required-asterisk span, which always renders last in the DOM.
          display: 'flex',
          alignItems: 'baseline',
          fontFamily: 'Rajdhani, sans-serif',
          fontSize: 15,
          fontWeight: 700,
          color: gfx.textHi,
          textTransform: 'uppercase',
          letterSpacing: '0.06em',
          paddingBottom: 2,
          position: 'relative',
          zIndex: 1,
          '&::after': {
            content: '":"',
            order: 2,
          },
        },
        required: {
          color: gfx.red,
          order: 3,
        },
        description: {
          textAlign: 'left',
          fontFamily: 'Inter, sans-serif',
          fontSize: 11,
          color: gfx.textLow,
          marginTop: 0,
          marginBottom: 8,
          textTransform: 'none',
          position: 'relative',
          zIndex: 1,
        },
      },
    },
    // Inputs themselves (text field, select, etc) match the reference's dark inset fields.
    Input: {
      styles: {
        input: {
          background: gfx.bg2,
          border: `1px solid ${gfx.line}`,
          borderRadius: 2,
          color: gfx.textHi,
          '&:focus, &:focus-within': {
            borderColor: 'rgba(255,255,255,.5)',
          },
          '&::placeholder': {
            color: gfx.textLow,
          },
        },
      },
    },
    Checkbox: {
      styles: {
        body: {
          position: 'relative',
          background: gfx.panel,
          border: `1px solid ${gfx.line}`,
          borderRadius: 3,
          padding: '10px 14px',
        },
        label: {
          textAlign: 'left',
          fontFamily: 'Rajdhani, sans-serif',
          fontSize: 15,
          fontWeight: 700,
          color: gfx.textHi,
          textTransform: 'uppercase',
          letterSpacing: '0.06em',
        },
        description: {
          fontFamily: 'Inter, sans-serif',
          fontSize: 11,
          color: gfx.textLow,
          textTransform: 'none',
        },
        input: {
          background: gfx.bg2,
          borderColor: gfx.line,
          '&:checked': {
            background: gfx.blue,
            borderColor: gfx.blue,
          },
        },
      },
    },
  },
  globalStyles: () => ({
    body: {
      backgroundColor: 'transparent',
    },
    '#root::after': {
      content: '""',
      position: 'fixed',
      inset: 0,
      pointerEvents: 'none',
      zIndex: 9999,
      opacity: 0.035,
      mixBlendMode: 'overlay',
      backgroundImage: grainDataUri,
    },
    label: {
      fontFamily: 'Rajdhani, sans-serif',
      textTransform: 'uppercase',
      letterSpacing: '0.06em',
      fontSize: 14,
      textAlign: 'left',
      color: gfx.textHi,
    },
    button: {
      textTransform: 'uppercase',
    },
  }),
};
