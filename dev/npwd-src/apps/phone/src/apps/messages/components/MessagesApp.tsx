import React from 'react';
import {AppWrapper} from '@ui/components';
import {AppTitle} from '@ui/components/AppTitle';
import {AppContent} from '@ui/components/AppContent';
import {useApp} from '@os/apps/hooks/useApps';
import MessageGroupModal from './modal/MessageGroupModal';
import MessagesList from './list/MessagesList';
import {Route, Switch, useHistory, useLocation} from 'react-router-dom';
import {MessageModal} from './modal/MessageModal';
import MessageModalSkeleton from './modal/MessageModalSkeleton';
import NewMessageGroupButton from './form/NewMessageGroupButton';
import {MessagesThemeProvider} from '../providers/MessagesThemeProvider';
import {LoadingSpinner} from '@ui/components/LoadingSpinner';
import {WordFilterProvider} from '@os/wordfilter/providers/WordFilterProvider';
import {useTranslation} from 'react-i18next';
import useMessages from '../hooks/useMessages';

export const MessagesApp = () => {
    const messages = useApp('MESSAGES');
    const history = useHistory();
    const {pathname} = useLocation();
    const [t] = useTranslation();
    const {conversations} = useMessages();
    const conversationCount = conversations?.length ?? 0;

    return (
        <MessagesThemeProvider>
            <AppWrapper id="messages-app">
                <WordFilterProvider>
                    {pathname === '/messages' && (
                        <AppTitle
                            app={messages}
                            sublabel={t('MESSAGES.CONVERSATIONS_COUNT', {count: conversationCount})}
                        />
                    )}
                    <AppContent>
                        <React.Suspense fallback={<LoadingSpinner/>}>
                            <Switch>
                                <Route path="/messages/conversations/:groupId">
                                    {/* Server: its own Suspense boundary, falling back to the
                                        conversation skeleton rather than the bare spinner the
                                        outer boundary uses. While MessageModal was suspended the
                                        outer fallback replaced the entire screen with a spinner -
                                        no header, no input bar - which is the "broken skeleton"
                                        that survived two earlier fixes: both of them were inside
                                        MessageModal, which had not mounted yet. */}
                                    <React.Suspense fallback={<MessageModalSkeleton/>}>
                                        <MessageModal/>
                                    </React.Suspense>
                                </Route>
                                <Route exact path="/messages">
                                    <MessagesList/>
                                </Route>
                            </Switch>
                            <Switch>
                                <Route exact path={['/messages/new/:phoneNumber', '/messages/new']}>
                                    <MessageGroupModal/>
                                </Route>
                            </Switch>
                        </React.Suspense>
                    </AppContent>
                    <Route exact path="/messages">
                        {/* Server: opens the real Contacts list (avatars, names) instead of the
                        manual number-entry autocomplete form - tapping a contact's own message
                        icon there already routes correctly into composing to them. */}
                        <NewMessageGroupButton onClick={() => history.push('/contacts')}/>
                    </Route>
                </WordFilterProvider>
            </AppWrapper>
        </MessagesThemeProvider>
    );
};
