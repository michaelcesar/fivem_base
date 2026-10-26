import React from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import makeStyles from '@mui/styles/makeStyles';
import { BottomNavigation, BottomNavigationAction } from '@mui/material';
import { Flame, Users, UserRound } from 'lucide-react';

// Server: rebuilt on DialerNavBar's shape, which is the one that renders correctly.
//
// Three differences mattered, and the first is the bug that was reported: without `showLabels`,
// MUI gives the *selected* action a different padding from the others, so the active tab drew a
// taller box than its neighbours - a stray light patch behind the first icon. The Dialer sets
// `showLabels` and every tab keeps one height.
//
// The other two: an explicit `background.paper` (the bar had no background of its own, so it
// inherited whatever sat behind it), and the active tab derived from the pathname rather than
// from a separate index. The index version could disagree with the route - navigating by link
// left it pointing at the first tab regardless of where you actually were.
const useStyles = makeStyles(() => ({
  root: {
    width: '100%',
    // Server: `transparent`, not a colour of its own. MUI defaults this bar to
    // `background.paper` - pure white in the light theme - while AppContent above it is
    // neutral-100 (#f5f5f5). That one-shade step reads as a line across the top of the bar.
    // Transparent shows whatever is behind it, which is .PhoneScreen painted with exactly the
    // neutral-100/neutral-900 pair AppContent uses, so the two cannot disagree in either theme.
    backgroundColor: 'transparent',
    // A flex child with a fixed height has to say it does not shrink, or a tall view above it
    // squeezes and clips it. See ADR-039.
    flexShrink: 0,
  },
}));

export function MatchBottomNavigation() {
  const classes = useStyles();
  const { pathname } = useLocation();

  return (
    <BottomNavigation value={pathname} showLabels className={classes.root}>
      <BottomNavigationAction value="/match" component={NavLink} to="/match" icon={<Flame />} />
      <BottomNavigationAction
        value="/match/matches"
        component={NavLink}
        to="/match/matches"
        icon={<Users />}
      />
      <BottomNavigationAction
        value="/match/profile"
        component={NavLink}
        to="/match/profile"
        icon={<UserRound />}
      />
    </BottomNavigation>
  );
}

export default MatchBottomNavigation;
