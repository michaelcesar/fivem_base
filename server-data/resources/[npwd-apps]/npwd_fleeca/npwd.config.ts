import App from './src/App';
import { FleecaIcon, NotificationIcon } from './icon';

export const path = '/npwd_fleeca';
export default () => ({
  id: 'npwd_fleeca',
  nameLocale: 'Fleeca',
  color: '#fff',
  backgroundColor: '#16a84f',
  path,
  icon: FleecaIcon,
  app: App,
  notificationIcon: NotificationIcon,
});
