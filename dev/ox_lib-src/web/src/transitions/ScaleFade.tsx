import { AnimatePresence, motion } from 'framer-motion';

// Server: `className` added so a caller can size this wrapper. It renders a plain div with no
// height of its own, which silently breaks any child relying on `height: 100%` - a percentage
// height against an auto-height parent does not resolve, so the child falls back to its content
// size. ContextMenu.tsx needs it (see that file's `fadeWrapper`); the other four callers
// (radial, both progress bars, TextUI) are deliberately content-sized and must NOT get a height.
const ScaleFade: React.FC<{
  visible: boolean;
  children: React.ReactNode;
  onExitComplete?: () => void;
  className?: string;
}> = ({ visible, children, onExitComplete, className }) => {
  return (
    <>
      <AnimatePresence onExitComplete={onExitComplete}>
        {visible && (
          <motion.div
            className={className}
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1, transition: { duration: 0.2, ease: [0, 0, 0.2, 1] } }}
            exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.1, ease: [0.4, 0, 1, 1] } }}
          >
            {children}
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};

export default ScaleFade;
