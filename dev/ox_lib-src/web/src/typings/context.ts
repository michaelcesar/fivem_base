import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { IconAnimation } from '../components/LibIcon';

export interface Option {
  menu?: string;
  title?: string;
  description?: string;
  arrow?: boolean;
  image?: string;
  icon?: IconProp | string;
  iconColor?: string;
  iconAnimation?: IconAnimation;
  progress?: number;
  colorScheme?: string;
  readOnly?: boolean;
  // Server: renders this option side by side with the adjacent options that also set it, instead
  // of on its own full-width row. Consecutive `inline` options share one flex row and split its
  // width evenly; a non-inline option ends the row. Added for the drug dealers' two quantity
  // cards, which are read as a pair and were asked for side by side. See ADR-088.
  //
  // Half a row is genuinely half the width, and `description` is clamped to a single line - so an
  // inline option's text has to be short or it will ellipsis. That is a property of the caller's
  // strings, not something this flag can fix.
  inline?: boolean;
  metadata?:
    | string[]
    | { [key: string]: any }
    | { label: string; value: any; progress?: number; colorScheme?: string }[];
  disabled?: boolean;
  event?: string;
  serverEvent?: string;
  args?: any;
}

export interface Options {
  [key: string]: Option;
}

export interface ContextMenuProps {
  title: string;
  description?: string;
  menu?: string;
  canClose?: boolean;
  options: Options | Option[];
}
