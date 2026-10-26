import React, { useCallback, useEffect, useState } from 'react';
import makeStyles from '@mui/styles/makeStyles';
import { useTranslation } from 'react-i18next';
import { Profile as IProfile, FormattedProfile, MatchEvents } from '@typings/match';
import ProfileField from '@ui/components/ProfileField';
import { ProfileAvatar } from '@ui/components/ProfileAvatar';
import UpdateButton from '@ui/components/UpdateButton';
import { Box } from '@mui/material';
import { usePhone } from '@os/phone/hooks/usePhone';
import PageText from '../PageText';
import fetchNui from '@utils/fetchNui';
import { ServerPromiseResp } from '@typings/common';
import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { useSetMyProfile } from '../../hooks/state';
import { NPWDButton } from '@npwd/keyos';
import { useHistory, useLocation } from 'react-router-dom';
import qs from 'qs';
import { useQueryParams } from '@common/hooks/useQueryParams';
import { deleteQueryFromLocation } from '@common/utils/deleteQueryFromLocation';
import { stripPlaceholderImageUrl } from '@utils/placeholderImages';

const useStyles = makeStyles({
  root: {
    display: 'flex',
    flexDirection: 'column',
    width: '100%',
    height: '100%',
    minHeight: 0,
  },
  // Server: the Save bar used to be `position: absolute`, pinned to this component's own box
  // regardless of how much content was actually visible above it - on a tall profile that just
  // floated it over whatever field ended up at the bottom instead of below all of them. Only
  // this inner area scrolls now; the Save bar sits after it in normal flow, so it can never
  // overlap a field again.
  scrollArea: {
    flex: '1 1 auto',
    minHeight: 0,
    overflowY: 'auto',
    padding: '15px',
    boxSizing: 'border-box',
  },
  spacer: {
    height: '8px',
  },
});

interface IProps {
  profile: FormattedProfile;
}

export function ProfileForm({ profile }: IProps) {
  const classes = useStyles();
  const [t] = useTranslation();
  const { ResourceConfig } = usePhone();
  const { addAlert } = useSnackbar();
  const setMyProfile = useSetMyProfile();
  const history = useHistory();
  const { pathname, search } = useLocation();
  const query = useQueryParams();

  // note that this assumes we are defensively checking
  // that profile is not null in a parent above this component.
  // Annoyingling adding conditionals above this line to not render
  // when profile === null results in a react error that different
  // amounts of hooks are rendering
  const [image, setImage] = useState(stripPlaceholderImageUrl(profile?.image));
  const [name, setName] = useState(profile?.name || '');
  const [bio, setBio] = useState(profile?.bio || '');
  const [job, setJob] = useState(profile?.job || '');
  const [location, setLocation] = useState(profile?.location || '');
  const [tags, setTags] = useState(profile?.tags || '');

  const handleOpenGallery = useCallback(() => {
    history.push(`/camera?${qs.stringify({ referal: encodeURIComponent(pathname + search) })}`);
  }, [history, pathname, search]);

  const update: FormattedProfile = {
    ...profile,
    image,
    name,
    bio,
    location,
    job,
    tagList: tags.split(',').map((tag) => tag.trim()),
  };

  const handleUpdate = () => {
    const updatedProfile: IProfile = {
      ...update,
      name: update.name.trim(),
      image: update.image.trim(),
      tags: update.tagList.join(','),
      voiceMessage: profile?.voiceMessage ?? null,
    };

    const event = profile ? MatchEvents.UPDATE_MY_PROFILE : MatchEvents.CREATE_MY_PROFILE;
    fetchNui<ServerPromiseResp<FormattedProfile>>(event, updatedProfile).then((resp) => {
      if (resp.status !== 'ok') {
        return addAlert({
          message: t(resp.errorMsg),
          type: 'error',
        });
      }

      setMyProfile(resp.data);

      addAlert({
        message: t('MATCH.FEEDBACK.UPDATE_PROFILE_SUCCEEDED'),
        type: 'success',
      });
    });
  };

  useEffect(() => {
    if (!query?.image) return;
    setImage(query.image);
    history.replace(deleteQueryFromLocation({ pathname, search }, 'image'));
  }, [query, history, setImage, pathname, search]);

  if (!profile && !ResourceConfig.match.allowEditableProfileName) {
    return <PageText text={t('MATCH.PROFILE_CONFIGURATION')} />;
  }

  return (
    <div className={classes.root}>
      <div className={classes.scrollArea}>
        <Box>
          <Box display="flex" mb={1}>
            <ProfileAvatar src={update.image} size={80} onClick={handleOpenGallery} className="cursor-pointer" />
          </Box>
          <ProfileField
            label={t('MATCH.EDIT_PROFILE_IMAGE')}
            value={update.image}
            handleChange={setImage}
            allowChange
          />
          <Box mt={1} mb={2}>
            <NPWDButton onClick={handleOpenGallery} className="bg-[#FE3B73]">
              {t('MATCH.CHOOSE_IMAGE')}
            </NPWDButton>
          </Box>
        </Box>
        <ProfileField
          label={t('MATCH.EDIT_PROFILE_NAME')}
          value={name}
          handleChange={setName}
          allowChange={ResourceConfig.match.allowEditableProfileName}
        />
        <ProfileField
          label={t('MATCH.EDIT_PROFILE_BIO')}
          value={update.bio}
          handleChange={setBio}
          multiline
          maxLength={250}
        />
        <ProfileField
          label={t('MATCH.EDIT_PROFILE_LOCATION')}
          value={update.location}
          handleChange={setLocation}
        />
        <ProfileField
          label={t('MATCH.EDIT_PROFILE_JOB')}
          value={update.job}
          handleChange={setJob}
          maxLength={50}
        />
        <ProfileField label={t('MATCH.EDIT_PROFILE_TAGS')} value={tags} handleChange={setTags} />
      </div>

      <div className="px-[15px] pb-[15px]">
        <UpdateButton handleClick={handleUpdate} accentClassName="bg-[#FE3B73]" />
      </div>
    </div>
  );
}

export default ProfileForm;
