import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { Box, createStyles, Group, Stack } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import ScaleFade from '../../transitions/ScaleFade';
import remarkGfm from 'remark-gfm';
import type { TextUiPosition, TextUiProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';
import LibIcon from '../../components/LibIcon';
import { gfx, hudCorner } from '../../theme';

// A leading "[X]" (e.g. "[E] Fazer curso") is parsed off and rendered as a keycap
// badge instead of plain text, matching the reference HUD's prompt convention.
const KEY_PREFIX = /^\[([^\]]+)\]\s*/;

const useStyles = createStyles((theme, params: { position?: TextUiPosition }) => ({
  wrapper: {
    height: '100%',
    width: '100%',
    position: 'absolute',
    display: 'flex',
    alignItems:
      params.position === 'top-center' ? 'baseline' :
      params.position === 'bottom-center' ? 'flex-end' : 'center',
    justifyContent:
      params.position === 'right-center' ? 'flex-end' :
      params.position === 'left-center' ? 'flex-start' : 'center',
  },
  // Server: several prompts can be on screen at once now (see the Lua side), so they stack in a
  // column rather than overwriting each other. `alignItems` follows the shared position so a
  // right-anchored group stays flush right no matter how wide each prompt is.
  stack: {
    gap: 0,
    alignItems:
      params.position === 'right-center' ? 'flex-end' :
      params.position === 'left-center' ? 'flex-start' : 'center',
  },
  container: {
    position: 'relative',
    fontSize: 14,
    padding: '10px 16px',
    margin: 8,
    background: gfx.panel,
    color: gfx.textHi,
    fontFamily: 'Inter, sans-serif',
    border: `1px solid ${gfx.line}`,
    borderRadius: 3,
    boxShadow: '0 14px 28px rgba(0,0,0,0.4)',
    ...hudCorner,
  },
  keycap: {
    flexShrink: 0,
    minWidth: 22,
    height: 22,
    padding: '0 6px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: gfx.bg2,
    border: `1px solid rgba(255,255,255,.3)`,
    borderRadius: 2,
    fontFamily: 'Rajdhani, sans-serif',
    fontWeight: 700,
    fontSize: 13,
    lineHeight: 1,
    color: gfx.textHi,
    letterSpacing: '0.02em',
  },
}));

/** One prompt. Split out because the component now renders a list of them rather than a single one. */
const Prompt: React.FC<{ data: TextUiProps; classes: Record<string, string> }> = ({ data, classes }) => {
  const keyMatch = data.text.match(KEY_PREFIX);
  const key = keyMatch?.[1];
  const text = keyMatch ? data.text.slice(keyMatch[0].length) : data.text;

  return (
    <Box style={data.style} className={classes.container}>
      <Group spacing={10} noWrap>
        {key && <Box className={classes.keycap}>{key}</Box>}
        {data.icon && (
          <LibIcon
            icon={data.icon}
            fixedWidth
            size="lg"
            animation={data.iconAnimation}
            style={{
              color: data.iconColor,
              alignSelf: !data.alignIcon || data.alignIcon === 'center' ? 'center' : 'start',
            }}
          />
        )}
        <ReactMarkdown components={MarkdownComponents} remarkPlugins={[remarkGfm]}>
          {text}
        </ReactMarkdown>
      </Group>
    </Box>
  );
};

/** One anchor position, and every prompt currently asking for it. */
const PromptGroup: React.FC<{ position: TextUiPosition; prompts: TextUiProps[] }> = ({ position, prompts }) => {
  const { classes } = useStyles({ position });

  return (
    <Box className={classes.wrapper}>
      <ScaleFade visible={prompts.length > 0}>
        <Stack className={classes.stack}>
          {prompts.map((prompt) => (
            <Prompt key={prompt.id} data={prompt} classes={classes} />
          ))}
        </Stack>
      </ScaleFade>
    </Box>
  );
};

const TextUI: React.FC = () => {
  // Server: keyed by the resource that raised each prompt, so two resources pointing at the same
  // spot both get shown instead of the second silently replacing the first. Insertion order is
  // preserved by string-keyed objects, so prompts stack in the order they appeared rather than
  // reshuffling as they update. See ADR-098.
  const [prompts, setPrompts] = React.useState<Record<string, TextUiProps>>({});

  useNuiEvent<TextUiProps>('textUi', (data) => {
    if (!data.position) data.position = 'right-center';

    setPrompts((current) => ({ ...current, [data.id ?? 'default']: data }));
  });

  useNuiEvent<{ id?: string }>('textUiHide', (data) => {
    setPrompts((current) => {
      const id = data?.id ?? 'default';
      if (!(id in current)) return current;

      const next = { ...current };
      delete next[id];
      return next;
    });
  });

  // Prompts are grouped by where they asked to be anchored, so two resources choosing different
  // positions do not end up stacked on top of each other in one corner.
  const byPosition = Object.values(prompts).reduce<Record<string, TextUiProps[]>>((acc, prompt) => {
    const position = prompt.position ?? 'right-center';
    (acc[position] ||= []).push(prompt);
    return acc;
  }, {});

  return (
    <>
      {Object.entries(byPosition).map(([position, group]) => (
        <PromptGroup key={position} position={position as TextUiPosition} prompts={group} />
      ))}
    </>
  );
};

export default TextUI;
