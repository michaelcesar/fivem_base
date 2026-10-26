import { useEffect, useState } from 'react';
import {
  GiBalaclava,
  GiGemNecklace,
  GiMonclerJacket,
  GiTShirt,
  GiArmorVest,
  GiBackpack,
  GiSleevelessJacket,
  GiTrousers,
  GiConverseShoe,
  GiStamper,
  GiTopHat,
  GiSunglasses,
  GiHumanEar,
  GiWatch,
  GiRing,
} from 'react-icons/gi';
import { IconType } from 'react-icons';

import { useNuiState } from '../../hooks/nuiState';

import CategoryCard, { CardGrid } from './components/CategoryCard';
import CategoryDetail from './components/CategoryDetail';
import DrawableGrid from './components/DrawableGrid';
import Input from './components/Input';
import TextureControl from './components/TextureControl';
import { clothingComponentImage, clothingPropImage, componentDrawables, propDrawables } from '../../utils/clothingImage';

import { ComponentSettings, PedComponent, PropSettings, PedProp } from './interfaces';

// Server: Components.tsx and Props.tsx used to be two separate screens, each with its own card
// grid - reported as reading like two sections when it should read as one: entering a card from
// either used to leave the OTHER screen's cards still showing underneath, since each kept its own
// independent `openId` state. Merged into a single component with one shared "what's open" state
// so opening any card - component or prop - replaces the entire grid with just that category's
// detail, nothing left over. `kind` disambiguates the two id spaces (component 1 and prop 1 both
// exist and mean different things). See ADR-078.
type Kind = 'component' | 'prop';
type Open = { kind: Kind; id: number } | null;

interface DataById<T> {
  [key: number]: T;
}

interface ClothingPickerProps {
  // Server: independently toggleable in this resource's own Config.NewCharacterSections (both
  // default true, but a server operator can set either false on its own - e.g. the "new
  // character" flow, unlike the always-both-true clothing shop path) - so the merged card grid
  // still needs to filter by which half is actually enabled, not just gate the whole component on
  // "either." See ADR-078.
  showComponents: boolean;
  showProps: boolean;
  componentSettings: ComponentSettings[];
  componentData: PedComponent[];
  componentStoredData: PedComponent[];
  handleComponentDrawableChange: (component_id: number, drawable: number) => void;
  handleComponentTextureChange: (component_id: number, texture: number) => void;
  propSettings: PropSettings[];
  propData: PedProp[];
  propStoredData: PedProp[];
  handlePropDrawableChange: (prop_id: number, drawable: number) => void;
  handlePropTextureChange: (prop_id: number, texture: number) => void;
  isPedFreemodeModel?: boolean;
  isPedMale?: boolean;
}

// Server: one detail view for both components and props - identical shape (drawable grid or
// fallback stepper, plus a texture stepper), differing only in which image/drawable-list
// functions and which settings/data slice they read. See ADR-078.
const ClothingDetail: React.FC<{
  kind: Kind;
  id: number;
  title: string;
  settings: { drawable: { min: number; max: number }; texture: { min: number; max: number }; blacklist: { drawables: number[]; textures: number[] } };
  data: { drawable: number; texture: number };
  storedData: { drawable: number; texture: number };
  onDrawableChange: (value: number) => void;
  onTextureChange: (value: number) => void;
  onBack: () => void;
  isPedFreemodeModel?: boolean;
  isPedMale?: boolean;
}> = ({ kind, id, title, settings, data, storedData, onDrawableChange, onTextureChange, onBack, isPedFreemodeModel, isPedMale }) => {
  const { locales } = useNuiState();
  const [drawables, setDrawables] = useState<number[]>([]);

  useEffect(() => {
    let cancelled = false;
    if (isPedFreemodeModel) {
      const fetcher = kind === 'component' ? componentDrawables : propDrawables;
      fetcher(id, isPedMale).then(list => {
        if (!cancelled) setDrawables(list);
      });
    } else {
      setDrawables([]);
    }
    return () => {
      cancelled = true;
    };
  }, [kind, id, isPedFreemodeModel, isPedMale]);

  const drawableLabel = kind === 'component' ? locales?.components.drawable : locales?.props.drawable;
  const textureLabel = kind === 'component' ? locales?.components.texture : locales?.props.texture;

  return (
    <CategoryDetail title={title} onBack={onBack}>
      {drawables.length > 0 ? (
        <DrawableGrid
          drawables={drawables}
          blacklisted={settings.blacklist.drawables}
          current={data.drawable}
          onSelect={onDrawableChange}
          imageSrc={drawable =>
            kind === 'component'
              ? clothingComponentImage(id, isPedFreemodeModel, isPedMale, drawable)
              : clothingPropImage(id, isPedFreemodeModel, isPedMale, drawable)
          }
        />
      ) : (
        <Input
          title={drawableLabel}
          min={settings.drawable.min}
          max={settings.drawable.max}
          blacklisted={settings.blacklist.drawables}
          defaultValue={data.drawable}
          clientValue={storedData.drawable}
          onChange={onDrawableChange}
        />
      )}
      <TextureControl
        title={textureLabel}
        min={settings.texture.min}
        max={settings.texture.max}
        blacklisted={settings.blacklist.textures}
        value={data.texture}
        onChange={onTextureChange}
      />
    </CategoryDetail>
  );
};

const ClothingPicker = ({
  showComponents,
  showProps,
  componentSettings,
  componentData,
  componentStoredData,
  handleComponentDrawableChange,
  handleComponentTextureChange,
  propSettings,
  propData,
  propStoredData,
  handlePropDrawableChange,
  handlePropTextureChange,
  isPedFreemodeModel,
  isPedMale,
}: ClothingPickerProps) => {
  const { locales } = useNuiState();
  const [open, setOpen] = useState<Open>(null);

  const componentSettingsById = componentSettings.reduce((object, { component_id, drawable, texture, blacklist }) => {
    return { ...object, [component_id]: { drawable, texture, blacklist } };
  }, {} as DataById<Omit<ComponentSettings, 'component_id'>>);
  const componentDataById: any = componentData.reduce((object, { component_id, drawable, texture }) => {
    return { ...object, [component_id]: { drawable, texture } };
  }, {} as DataById<Omit<PedComponent, 'component_id'>>);
  const componentStoredById: any = componentStoredData.reduce((object, { component_id, drawable, texture }) => {
    return { ...object, [component_id]: { drawable, texture } };
  }, {} as DataById<Omit<PedComponent, 'component_id'>>);

  const propSettingsById = propSettings.reduce((object, { prop_id, drawable, texture, blacklist }) => {
    return { ...object, [prop_id]: { drawable, texture, blacklist } };
  }, {} as DataById<Omit<PropSettings, 'prop_id'>>);
  const propDataById: any = propData.reduce((object, { prop_id, drawable, texture }) => {
    return { ...object, [prop_id]: { drawable, texture } };
  }, {} as DataById<Omit<PedProp, 'prop_id'>>);
  const propStoredById: any = propStoredData.reduce((object, { prop_id, drawable, texture }) => {
    return { ...object, [prop_id]: { drawable, texture } };
  }, {} as DataById<Omit<PedProp, 'prop_id'>>);

  if (!locales) {
    return null;
  }

  const categories: Array<{ kind: Kind; id: number; title: string; icon: IconType }> = [
    ...(showComponents
      ? [
          { kind: 'component' as const, id: 1, title: locales.components.mask, icon: GiBalaclava },
          { kind: 'component' as const, id: 7, title: locales.components.scarfAndChains, icon: GiGemNecklace },
          { kind: 'component' as const, id: 11, title: locales.components.jackets, icon: GiMonclerJacket },
          { kind: 'component' as const, id: 8, title: locales.components.shirt, icon: GiTShirt },
          { kind: 'component' as const, id: 9, title: locales.components.bodyArmor, icon: GiArmorVest },
          { kind: 'component' as const, id: 5, title: locales.components.bags, icon: GiBackpack },
          { kind: 'component' as const, id: 3, title: locales.components.upperBody, icon: GiSleevelessJacket },
          { kind: 'component' as const, id: 4, title: locales.components.lowerBody, icon: GiTrousers },
          { kind: 'component' as const, id: 6, title: locales.components.shoes, icon: GiConverseShoe },
          { kind: 'component' as const, id: 10, title: locales.components.decals, icon: GiStamper },
        ]
      : []),
    ...(showProps
      ? [
          { kind: 'prop' as const, id: 0, title: locales.props.hats, icon: GiTopHat },
          { kind: 'prop' as const, id: 1, title: locales.props.glasses, icon: GiSunglasses },
          { kind: 'prop' as const, id: 2, title: locales.props.ear, icon: GiHumanEar },
          { kind: 'prop' as const, id: 6, title: locales.props.watches, icon: GiWatch },
          { kind: 'prop' as const, id: 7, title: locales.props.bracelets, icon: GiRing },
        ]
      : []),
  ];

  if (open !== null) {
    const category = categories.find(c => c.kind === open.kind && c.id === open.id)!;
    const isComponent = open.kind === 'component';

    return (
      <ClothingDetail
        kind={open.kind}
        id={open.id}
        title={category.title}
        settings={isComponent ? componentSettingsById[open.id] : propSettingsById[open.id]}
        data={isComponent ? componentDataById[open.id] : propDataById[open.id]}
        storedData={isComponent ? componentStoredById[open.id] : propStoredById[open.id]}
        onDrawableChange={value =>
          isComponent ? handleComponentDrawableChange(open.id, value) : handlePropDrawableChange(open.id, value)
        }
        onTextureChange={value =>
          isComponent ? handleComponentTextureChange(open.id, value) : handlePropTextureChange(open.id, value)
        }
        onBack={() => setOpen(null)}
        isPedFreemodeModel={isPedFreemodeModel}
        isPedMale={isPedMale}
      />
    );
  }

  return (
    <CardGrid>
      {categories.map(({ kind, id, title, icon }) => (
        <CategoryCard key={`${kind}-${id}`} icon={icon} label={title} onClick={() => setOpen({ kind, id })} />
      ))}
    </CardGrid>
  );
};

export default ClothingPicker;
