import React from 'react';
import { AppWrapper } from '@ui/components';
import { AppContent } from '@ui/components/AppContent';
import { GalleryGrid } from './grid/GalleryGrid';
import { GalleryModal } from './modal/GalleryModal';
import { Route, Switch } from 'react-router-dom';
import { LoadingSpinner } from '@ui/components/LoadingSpinner';
import { AppTitle } from '@ui/components/AppTitle';
import { useApp } from '@os/apps/hooks/useApps';
import NewPhotoButton from './NewPhotoButton';
import { useTranslation } from 'react-i18next';

const CameraApp: React.FC = () => {
  const camera = useApp('CAMERA');
  const [t] = useTranslation();

  return (
    <AppWrapper id="camera-app">
      {/* Server: the title is the gallery's header, not the photo viewer's - an open photo
          should be the photo and a back arrow, nothing else. Scoped to the exact gallery route,
          the same way NewPhotoButton below already is. */}
      <Route exact path="/camera">
        <AppTitle app={camera} sublabel={t('CAMERA.SUBLABEL')} />
      </Route>
      <AppContent>
        <Switch>
          <React.Suspense fallback={<LoadingSpinner />}>
            <Route path="/camera" exact component={GalleryGrid} />
            <Route path="/camera/image" exact component={GalleryModal} />
          </React.Suspense>
        </Switch>
      </AppContent>
      <Route exact path="/camera">
        <NewPhotoButton />
      </Route>
    </AppWrapper>
  );
};

export default CameraApp;
