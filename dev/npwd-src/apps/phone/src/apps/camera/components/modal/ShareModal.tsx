import React from 'react';
import Modal from '../../../../ui/components/Modal';
import { NPWDButton } from '@npwd/keyos';
import { setClipboard } from '@os/phone/hooks/useClipboard';

import { useHistory } from 'react-router-dom';
import { GalleryPhoto } from '@typings/photo';
import { useTranslation } from 'react-i18next';
import { CAMERA_APP_PRIMARY_COLOR } from '../../camera.theme';

interface IShareModalProps {
  meta: GalleryPhoto;
  referal: string;
  onClose(): void;
}

export const ShareModal = ({ meta, onClose, referal }: IShareModalProps) => {
  const history = useHistory();
  const [t] = useTranslation();

  const handleCopyImage = () => {
    setClipboard(meta.image);
    history.push(referal);
  };

  // Server: was a bare <h4> and an outlined MUI Button reading a hardcoded English
  // "Copy image". Now the same title/full-width-action shape the rest of the phone uses
  // (ConfirmDialog, NoteModal), with the button in the Camera app's own colour.
  return (
    <Modal visible={!!meta} handleClose={onClose}>
      <div className="flex flex-col gap-4">
        <p className="text-base font-semibold text-neutral-900 dark:text-white">
          {t('CAMERA.COPY_IMAGE')}
        </p>
        <NPWDButton
          onClick={handleCopyImage}
          className="w-full text-white"
          style={{ backgroundColor: CAMERA_APP_PRIMARY_COLOR }}
        >
          {t('GENERIC.COPY')}
        </NPWDButton>
      </div>
    </Modal>
  );
};
