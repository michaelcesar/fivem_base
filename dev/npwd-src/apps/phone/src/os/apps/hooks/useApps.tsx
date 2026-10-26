import React, { useCallback, useMemo } from 'react';
import { useNotifications } from '@os/notifications/hooks/useNotifications';
import { createLazyAppIcon } from '../utils/createLazyAppIcon';
import { APPS, IApp } from '../config/apps';
import { SvgIconComponent } from '@mui/icons-material';
import { useTheme } from '@mui/material';
import { useSettingsValue } from '../../../apps/settings/hooks/useSettings';
import { IconSetObject } from '@typings/settings';
import { useRecoilValue } from 'recoil';
import { phoneState } from '@os/phone/hooks/state';

export const useApps = () => {
  const { icons } = useNotifications();
  const theme = useTheme();
  const curIconSet = useSettingsValue().iconSet.value as IconSetObject;
  // Read straight off the atom rather than through useConfig(), which fires its own fetch in an
  // effect - useApps is called from a dozen places and would multiply that fetch by all of them.
  const disabledApps = useRecoilValue(phoneState.resourceConfig)?.disabledApps ?? [];

  const apps: IApp[] = useMemo(() => {
    return APPS.map((app) => {
      const SvgIcon = React.lazy<SvgIconComponent>(() =>
        import(`../icons/${curIconSet.name}/svg/${app.id}.tsx`).catch(
          () => 'Was not able to find a dynamic import for icon from this icon set',
        ),
      );
      const AppIcon = React.lazy<SvgIconComponent>(() =>
        import(`../icons/${curIconSet.name}/app/${app.id}.tsx`).catch(
          () => 'Was not able to find a dynamic import for icon from this icon set',
        ),
      );

      const NotificationIcon = createLazyAppIcon(SvgIcon);
      const Icon = createLazyAppIcon(AppIcon);

      if (curIconSet.custom) {
        return {
          ...app,
          notification: icons.find((i) => i.key === app.id),
          NotificationIcon,
          Icon,
          notificationIcon: (
            <NotificationIcon htmlColor={theme.palette.text.primary} fontSize="small" />
          ),
          icon: <Icon />,
          isDisabled: app.disable,
        };
      }

      return {
        ...app,
        notification: icons.find((i) => i.key === app.id),
        NotificationIcon,
        notificationIcon: <NotificationIcon htmlColor={app.color} fontSize="small" />,
        isDisabled: app.disable,
      };
    });
  }, [icons, curIconSet, theme]);

  const allApps = useMemo(() => [...apps], [apps]);
  const getApp = useCallback(
    (id: string): IApp => {
      return allApps.find((a) => a.id === id) || null;
    },
    [allApps],
  );

  // Server: `disabledApps` in config.json had never done anything - the line that applied it
  // was left commented out upstream, so the setting was silently ignored. `apps` drives both the
  // home-screen grid and the route registration in Phone.tsx, so filtering here removes the icon
  // and makes the route unreachable, rather than just hiding it. `getApp` deliberately still
  // resolves against the unfiltered list, so anything looking an app up by id (notifications, an
  // app reading its own title) keeps working. The array is empty today - the Browser, its only
  // entry, was deleted outright instead (ADR-037) - but this is the lever for turning an app off
  // without a rebuild.
  const filteredApps = useMemo(
    () => apps.filter((app) => !disabledApps.includes(app.id)),
    [apps, disabledApps],
  );

  return { apps: filteredApps, getApp };
};

export const useApp = (id: string): IApp => {
  const { getApp } = useApps();
  return getApp(id);
};
