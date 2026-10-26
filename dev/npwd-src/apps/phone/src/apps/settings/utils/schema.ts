import { Schema, Validator } from 'jsonschema';
import { NPWD_STORAGE_KEY } from './constants';

const v = new Validator();

// Server: schema ids/$refs must be well-formed absolute URIs - jsonschema 1.5.0 resolves them
// through the WHATWG URL constructor (see its lib/helpers.js `resolveUrl`), and CEF's URL
// parser throws "Failed to construct 'URL': Invalid URL" on the bare `/Foo`-style relative ids
// this file used to have. This ran at module-evaluation time (the `v.addSchema` calls below are
// top-level), so it crashed the whole phone NUI on load, before the player ever opened Settings.
const SCHEMA_BASE = 'https://npwd.internal/schemas/';

const settingOptionSchema: Schema = {
  id: `${SCHEMA_BASE}SettingOption`,
  type: 'object',
  properties: {
    label: { type: 'string' },
    val: { type: 'string' },
  },
  required: true,
};

const iconSetValueSchema: Schema = {
  id: `${SCHEMA_BASE}IconSetValue`,
  type: 'object',
  properties: {
    name: { type: 'string' },
    custom: { type: 'boolean' },
  },
  required: true,
};

const settingOptionIconSet: Schema = {
  id: `${SCHEMA_BASE}SettingOptionIconSet`,
  type: 'object',
  properties: {
    label: { type: 'string' },
    value: { $ref: `${SCHEMA_BASE}IconSetValue` },
  },
  required: true,
};

v.addSchema(iconSetValueSchema, `${SCHEMA_BASE}IconSetValue`);
v.addSchema(settingOptionIconSet, `${SCHEMA_BASE}SettingOptionIconSet`);

const settingsSchema: Schema = {
  type: 'object',
  properties: {
    callVolume: { type: 'number', required: true },
    iconSet: { $ref: `${SCHEMA_BASE}SettingOptionIconSet`, required: true },
    language: { $ref: `${SCHEMA_BASE}SettingOption`, required: true },
    wallpaper: { $ref: `${SCHEMA_BASE}SettingOption`, required: true },
    frame: { $ref: `${SCHEMA_BASE}SettingOption`, required: true },
    theme: { $ref: `${SCHEMA_BASE}SettingOption`, required: true },
    zoom: { $ref: `${SCHEMA_BASE}SettingOption`, required: true },
    streamerMode: { type: 'boolean', required: true },
    ringtone: { $ref: `${SCHEMA_BASE}SettingOption`, required: true },
    notiSound: { $ref: `${SCHEMA_BASE}SettingOption`, required: true },
    TWITTER_notiFilter: { $ref: `${SCHEMA_BASE}SettingOption`, required: true },
    TWITTER_notiSound: { $ref: `${SCHEMA_BASE}SettingOption`, required: true },
    TWITTER_notiSoundVol: { type: 'number', required: true },
    TWITTER_notifyNewFeedTweet: { type: 'boolean', required: true },
    MARKETPLACE_notifyNewListing: { type: 'boolean', required: true },
  },
};

v.addSchema(settingOptionSchema, `${SCHEMA_BASE}SettingOption`);

export function isSchemaValid(schema: string): boolean {
  const storedSettings = JSON.parse(schema);
  const resp = v.validate(storedSettings, settingsSchema);
  return resp.valid;
}

export function isSettingsSchemaValid(): boolean {
  const localStore = localStorage.getItem(NPWD_STORAGE_KEY);
  if (localStore) {
    try {
      const parsedSettings = JSON.parse(localStore);
      return v.validate(parsedSettings, settingsSchema).valid;
    } catch (e) {
      console.error(
        'JSON eror encountered while parsing the NPWD localStorage JSON string, using default schema as a fall back.',
        e,
      );
    }
  }
  return true;
}
