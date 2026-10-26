import { Wrapper, Panel, Buttons } from './styles';

interface ModalProps {
  title: string;
  description: string;
  accept: string;
  decline: string;
  handleAccept: () => Promise<void> | void;
  handleDecline: () => Promise<void> | void;
}

const Modal = ({ title, description, accept, decline, handleAccept, handleDecline }: ModalProps) => {
  return (
    <Wrapper>
      <Panel>
        <p>{title}</p>
        <span>{description}</span>
        <Buttons>
          <button type="button" onClick={handleAccept}>
            {accept}
          </button>
          <button type="button" onClick={handleDecline}>
            {decline}
          </button>
        </Buttons>
      </Panel>
    </Wrapper>
  );
};

export default Modal;
