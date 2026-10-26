import { IconProp } from '@fortawesome/fontawesome-svg-core';
import React from 'react';
import { IconAnimation } from '../components/LibIcon';

export type TextUiPosition = 'right-center' | 'left-center' | 'top-center' | 'bottom-center';

export interface TextUiProps {
  // Server: which resource raised this prompt. Several can be on screen at once now, stacked, and
  // this is what keeps them apart - the Lua side fills it in from `cache.resource` automatically, so
  // no caller had to change. Optional because a payload from an older build would not carry it.
  // See ADR-098.
  id?: string;
  text: string;
  position?: TextUiPosition;
  icon?: IconProp;
  iconColor?: string;
  iconAnimation?: IconAnimation;
  style?: React.CSSProperties;
  alignIcon?: 'top' | 'center';
}
