import React from 'react';
import { createPortal } from 'react-dom';
import { Slide } from '@mui/material';
import { Image as ImageIcon, SendHorizontal, X } from 'lucide-react';
import { useHistory, useLocation } from 'react-router-dom';
import qs from 'qs';
import { useModal } from '../../hooks/useModal';
import { isImageValid } from '../../../../common/utils/isImageValid';
import { useDarkchatAPI } from '../../hooks/useDarkchatAPI';
import { useActiveDarkchatValue } from '../../state/state';
import { useMyPhoneNumber } from '../../../../os/simcard/hooks/useMyPhoneNumber';
import { useTranslation } from 'react-i18next';
import { NPWDInput } from '@ui/components/Input';
import { DEEPWEB_SURFACE } from '../../darkchat.theme';

// Server: rebuilt as a bottom sheet, matching ContextMenu - the sheet Messages uses for its own
// attach picker. Was the shared `Modal`, a card floating 80px from the top of the screen with no
// animation, which is not a pattern used anywhere else on this phone any more.
//
// The mechanics are ContextMenu's and are load-bearing: portal onto `#phone` (the visible screen)
// and pin with `position: absolute`, not `fixed`. `fixed` resolves against `.Phone`, the larger
// 500x1000 box, which puts the sheet's bottom edge behind the phone's frame graphic.
export const UploadMediaModal = () => {
  const { modalVisible, setModalVisible, modalMedia, setModalMedia } = useModal();
  const history = useHistory();
  const { pathname, search } = useLocation();
  const { sendMessage } = useDarkchatAPI();
  const { id: channelId } = useActiveDarkchatValue();
  const phoneNumber = useMyPhoneNumber();
  const [t] = useTranslation();

  const phoneEl = document.getElementById('phone');
  if (!phoneEl) return null;

  const handleImageGallery = () => {
    history.push(
      `/camera?${qs.stringify({
        referal: encodeURIComponent(pathname + search),
      })}`,
    );
  };

  const handleSendImage = () => {
    const link = modalMedia;
    // Strip whitespace
    link.replace('/ /g', '');

    isImageValid(link)
      .then(() => {
        sendMessage({
          type: 'image',
          message: modalMedia,
          channelId,
          phoneNumber,
        });
        setModalVisible(false);
        setModalMedia('');
      })
      .catch(console.error);
  };

  return createPortal(
    <Slide
      direction="up"
      in={modalVisible}
      style={{ position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 9999 }}
      mountOnEnter
      unmountOnExit
    >
      <div
        className="w-full overflow-hidden rounded-t-2xl p-3"
        style={{ backgroundColor: DEEPWEB_SURFACE }}
      >
        <div className="mb-3 flex items-center justify-between">
          <p className="m-0 text-base font-medium text-white">{t('DARKCHAT.MEDIA_UPLOAD')}</p>
          <button onClick={() => setModalVisible(false)} className="text-neutral-400">
            <X size={22} />
          </button>
        </div>

        <NPWDInput
          placeholder={t('DARKCHAT.MEDIA_PLACEHOLDER')}
          className="!bg-[#242424] !text-white placeholder:text-neutral-500"
          value={modalMedia}
          onChange={(e) => setModalMedia(e.target.value)}
        />

        <div className="mt-3 flex items-center justify-between">
          <button
            onClick={handleImageGallery}
            className="flex items-center gap-2 rounded-md px-2 py-2 text-sm text-neutral-300 hover:bg-white/5"
          >
            <ImageIcon size={20} />
            {t('DARKCHAT.MEDIA_GALLERY')}
          </button>
          <button
            onClick={handleSendImage}
            className="flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium text-white"
            style={{ backgroundColor: '#1f7a3d' }}
          >
            <SendHorizontal size={18} />
            {t('GENERIC.SEND')}
          </button>
        </div>
      </div>
    </Slide>,
    phoneEl,
  );
};
