import React, { memo, useCallback, useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { NPWDInput } from '@ui/components/Input';
import { ImagePlus } from 'lucide-react';
import { Tooltip } from '@ui/components/Tooltip';
import { useHistory, useLocation } from 'react-router-dom';
import { deleteQueryFromLocation } from '@common/utils/deleteQueryFromLocation';
import qs from 'qs';
import { useQueryParams } from '@common/hooks/useQueryParams';

export const ImagePrompt = ({ visible, value, handleChange }) => {
  const textFieldRef = useRef(null);
  const [t] = useTranslation();
  const history = useHistory();
  const { pathname, search } = useLocation();
  const query = useQueryParams();

  useEffect(() => {
    textFieldRef.current && textFieldRef.current.focus();
  }, [visible]);

  const handleImageChange = useCallback(
    (e, shouldSubmit) => handleChange(e.target.value, shouldSubmit),
    [handleChange],
  );

  const handleChooseImage = useCallback(() => {
    history.push(
      `/camera?${qs.stringify({
        referal: encodeURIComponent(pathname + search),
      })}`,
    );
  }, [history, pathname, search]);

  useEffect(() => {
    if (!query?.image) return;
    handleChange(query.image, true);
    history.replace(deleteQueryFromLocation({ pathname, search }, 'image'));
  }, [query?.image, history, pathname, search, handleChange]);

  if (!visible) return null;
  return (
    <div className="mt-2 flex items-center gap-2">
      <NPWDInput
        value={value}
        onChange={(e) => handleImageChange(e, false)}
        placeholder={t('TWITTER.IMAGE_PLACEHOLDER')}
        ref={textFieldRef}
      />
      <Tooltip placement="left" title={t('TWITTER.SELECT_IMAGE_TOOLTIP')}>
        <button
          onClick={handleChooseImage}
          className="rounded-full p-2 text-neutral-500 hover:bg-black/5 dark:text-neutral-400 dark:hover:bg-white/10"
        >
          <ImagePlus size={20} />
        </button>
      </Tooltip>
    </div>
  );
};

export default memo(ImagePrompt);
