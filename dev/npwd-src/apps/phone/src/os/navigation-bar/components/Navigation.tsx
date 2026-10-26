import React from 'react';
import { useHistory, useRouteMatch } from 'react-router-dom';
import { usePhone } from '@os/phone/hooks/usePhone';
import { ChevronLeft, Circle, LayoutGrid } from 'lucide-react';

export const Navigation: React.FC = () => {
  const history = useHistory();
  const { isExact } = useRouteMatch('/');
  const { closePhone } = usePhone();

  const handleGoToMenu = () => {
    if (isExact) return;
    history.push('/');
  };

  // Server: `history.goBack()` never actually navigated anywhere in this environment (see
  // ADR-029) - this button uses the same direct `push('/')` every other back button on the
  // phone was switched to, instead of the broken goBack().
  const handleBack = () => {
    if (isExact) return;
    history.push('/');
  };

  return (
    // `shrink-0` so the phone's own bar keeps its 56px whatever the app above it asks for -
    // the height ADR-039's `flex: 1` calculation depends on.
    <div className="bg-neutral-100 dark:bg-neutral-900 w-full h-14 shrink-0 px-12">
      <div className="flex justify-between items-center h-full">
        <button onClick={handleGoToMenu}>
          <LayoutGrid className="text-neutral-400 hover:dark:text-neutral-100 h-6 w-6 hover:text-neutral-900 " />
        </button>
        <button onClick={closePhone}>
          <Circle className="text-neutral-400 hover:dark:text-neutral-100 h-6 w-6 hover:text-neutral-900 " />
        </button>
        <button onClick={handleBack}>
          <ChevronLeft className="text-neutral-400 hover:dark:text-neutral-100 hover:text-neutral-900 h-6 w-6" />
        </button>
      </div>
    </div>
  );
};
