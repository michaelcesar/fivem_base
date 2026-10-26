import React, { useCallback, useEffect } from 'react';
import { MarketplaceResp, MarketplaceDatabaseLimits, MarketplaceEvents } from '@typings/marketplace';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { useTranslation } from 'react-i18next';
import { ImagePlus } from 'lucide-react';
import { useHistory, useLocation } from 'react-router-dom';
import qs from 'qs';
import { useQueryParams } from '@common/hooks/useQueryParams';
import { deleteQueryFromLocation } from '@common/utils/deleteQueryFromLocation';
import { NPWDInput, NPWDTextarea } from '@ui/components/Input';
import { NPWDButton } from '@npwd/keyos';
import fetchNui from '@utils/fetchNui';
import { ServerPromiseResp } from '@typings/common';
import { useForm } from '../../hooks/state';
import { useWordFilter } from '@os/wordfilter/hooks/useWordFilter';
import { MARKETPLACE_APP_PRIMARY_COLOR } from '../../marketplace.theme';

export const ListingForm: React.FC = () => {
  const [t] = useTranslation();
  const { addAlert } = useSnackbar();
  const history = useHistory();
  const { pathname, search } = useLocation();
  const query = useQueryParams();
  const [formState, setFormState] = useForm();
  const { clean } = useWordFilter();

  const areFieldsFilled = formState.title.trim() !== '' && formState.description.trim() !== '';

  const addListing = () => {
    if (!areFieldsFilled) {
      return addAlert({
        message: t('MARKETPLACE.FEEDBACK.REQUIRED_FIELDS'),
        type: 'error',
      });
    }

    fetchNui<ServerPromiseResp<MarketplaceResp>>(MarketplaceEvents.ADD_LISTING, {
      ...formState,
      title: clean(formState.title),
      description: clean(formState.description),
    }).then((resp) => {
      if (resp.status !== 'ok') {
        return addAlert({
          message: t(resp.errorMsg),
          type: 'error',
        });
      }

      addAlert({
        message: t('MARKETPLACE.FEEDBACK.CREATE_LISTING_SUCCESS'),
        type: 'success',
      });
      history.push('/marketplace');
      setFormState({
        title: '',
        description: '',
        url: '',
      });
    });
  };

  const handleChooseImage = useCallback(() => {
    history.push(
      `/camera?${qs.stringify({
        referal: encodeURIComponent(pathname + search),
      })}`,
    );
  }, [history, pathname, search]);

  const handleTitleChange: React.ChangeEventHandler<HTMLInputElement> = (e) => {
    const inputVal = e.currentTarget.value;
    if (inputVal.length === MarketplaceDatabaseLimits.title) return;
    setFormState({
      ...formState,
      title: e.currentTarget.value,
    });
  };

  const handleUrlChange: React.ChangeEventHandler<HTMLInputElement> = (e) => {
    const inputVal = e.currentTarget.value;
    if (inputVal.length === MarketplaceDatabaseLimits.url) return;
    setFormState({
      ...formState,
      url: e.currentTarget.value,
    });
  };

  const handleDescriptionChange: React.ChangeEventHandler<HTMLTextAreaElement> = (e) => {
    const inputVal = e.currentTarget.value;
    if (inputVal.length === MarketplaceDatabaseLimits.description) return;
    setFormState({
      ...formState,
      description: e.currentTarget.value,
    });
  };

  useEffect(() => {
    if (!query?.image) return;
    setFormState({
      ...formState,
      url: query.image,
    });
    history.replace(deleteQueryFromLocation({ pathname, search }, 'image'));
  }, [query?.image, history, pathname, search, setFormState, formState]);

  return (
    <div className="flex h-full flex-col gap-3 overflow-auto p-3">
      <span className="text-lg font-semibold text-black dark:text-white">
        {t('MARKETPLACE.NEW_LISTING')}
      </span>

      <div>
        <label className="text-sm font-medium text-neutral-500 dark:text-neutral-400">
          {t('GENERIC.REQUIRED')}
        </label>
        <NPWDInput
          value={formState.title}
          onChange={handleTitleChange}
          placeholder={t('MARKETPLACE.FORM_TITLE')}
          maxLength={MarketplaceDatabaseLimits.title}
        />
      </div>

      <div>
        <label className="text-sm font-medium text-neutral-500 dark:text-neutral-400">
          {t('MARKETPLACE.FORM_IMAGE')}
        </label>
        <div className="flex items-center gap-2">
          <NPWDInput
            value={formState.url}
            onChange={handleUrlChange}
            placeholder={t('MARKETPLACE.FORM_IMAGE')}
            maxLength={MarketplaceDatabaseLimits.url}
          />
          <button
            onClick={handleChooseImage}
            className="shrink-0 rounded-full p-2 text-neutral-500 hover:bg-black/5 dark:text-neutral-400 dark:hover:bg-white/10"
          >
            <ImagePlus size={20} />
          </button>
        </div>
      </div>

      <div>
        <label className="text-sm font-medium text-neutral-500 dark:text-neutral-400">
          {t('GENERIC.REQUIRED')}
        </label>
        <NPWDTextarea
          value={formState.description}
          onChange={handleDescriptionChange}
          placeholder={t('MARKETPLACE.FORM_DESCRIPTION')}
          maxLength={MarketplaceDatabaseLimits.description}
          rows={4}
          className="resize-none"
        />
      </div>

      <NPWDButton
        onClick={addListing}
        disabled={!areFieldsFilled}
        className="disabled:opacity-40"
        style={{ backgroundColor: MARKETPLACE_APP_PRIMARY_COLOR }}
      >
        {t('MARKETPLACE.POST_LISTING')}
      </NPWDButton>
    </div>
  );
};
