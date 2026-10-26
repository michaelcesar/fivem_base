import { NavLink, useLocation } from 'react-router-dom';
import { BottomNavigation, BottomNavigationAction, styled } from '@mui/material';
import { Home, Search, UserRound } from 'lucide-react';

// Server: same shape as DialerNavBar and Match's own bar. `showLabels` is the important one -
// without it MUI pads the selected action differently from its neighbours, so the active tab
// draws a taller box behind its icon. The active tab comes from the pathname rather than a
// separate index, which could disagree with the route after navigating by link.
const Navigation = styled(BottomNavigation)(({ theme }) => ({
  width: '100%',
  backgroundColor: theme.palette.background.paper,
  boxShadow: 'none',
  borderTop: 'none',
  // A flex child with a fixed height has to say it does not shrink, or a tall view above it
  // squeezes and clips it. See ADR-039.
  flexShrink: 0,
}));

export function TwitterBottomNavigation() {
  const { pathname } = useLocation();

  return (
    <Navigation value={pathname} showLabels>
      <BottomNavigationAction
        value="/twitter"
        component={NavLink}
        to="/twitter"
        icon={<Home size={20} />}
      />
      <BottomNavigationAction
        value="/twitter/search"
        component={NavLink}
        to="/twitter/search"
        icon={<Search size={20} />}
      />
      <BottomNavigationAction
        value="/twitter/profile"
        component={NavLink}
        to="/twitter/profile"
        icon={<UserRound size={20} />}
      />
    </Navigation>
  );
}

export default TwitterBottomNavigation;
