import React, { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Circle, Square, Play, Pause, SendHorizontal, X, Loader2 } from 'lucide-react';
import { useRecorder } from '@os/audio/hooks/useRecorder';
import dayjs from 'dayjs';
import duration from 'dayjs/plugin/duration';
import { useAudioMessageAPI } from '@apps/messages/hooks/useAudioMessageAPI';

dayjs.extend(duration);

interface AudioContextMenuProps {
  onClose: () => void;
}

const AudioContextMenu: React.FC<AudioContextMenuProps> = ({ onClose }) => {
  const [t] = useTranslation();
  const {
    blob,
    audio: recordedAudio,
    recordingState,
    startRecording,
    stopRecording,
  } = useRecorder();
  const [currentTime, setCurrentTime] = useState<number | null>(null);
  const { uploadRecording } = useAudioMessageAPI();
  const [isSending, setIsSending] = useState<boolean>(false);
  const [playing, setPlaying] = useState<boolean>(false);

  const audioRef = useRef(new Audio());

  const audioDuration = audioRef.current.duration;

  useEffect(() => {
    audioRef.current.src = recordedAudio;
  }, [recordedAudio]);

  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.ontimeupdate = () => {
        // we need to trunc becuase dayjs does not like decimals
        setCurrentTime(Math.trunc(audioRef.current.currentTime));
      };
    }
  });

  const play = async () => {
    await audioRef.current.play();
    setPlaying(true);
  };

  const pause = () => {
    audioRef.current.pause();
    setPlaying(false);
  };

  const handleSendRecording = async () => {
    try {
      if (!blob) return;
      setIsSending(true);
      await uploadRecording(blob, onClose);
    } catch (err) {
      setIsSending(false);
      console.error(err);
    }
  };

  const statusText = !recordedAudio
    ? t('GENERIC.RECORD_VOICE_MESSAGE')
    : recordingState.isRecording
      ? t('GENERIC.RECORDING')
      : !isNaN(audioDuration)
        ? `${dayjs.duration(currentTime * 1000).format('mm:ss')}${
            audioDuration === Infinity
              ? ''
              : ` - ${dayjs.duration(Math.trunc(audioDuration) * 1000).format('mm:ss')}`
          }`
        : t('GENERIC.CLICK_TO_PLAY_VOICE_MESSAGE');

  return (
    <div className="flex items-center gap-2 bg-[#F7F7F7] px-3 py-2 dark:bg-[#202C33]">
      {isSending ? (
        <Loader2 size={22} className="animate-spin text-neutral-500 dark:text-neutral-400" />
      ) : recordedAudio && !recordingState.isRecording ? (
        <button
          onClick={playing ? pause : play}
          className="rounded-full p-1.5 text-neutral-600 hover:bg-black/5 dark:text-neutral-300 dark:hover:bg-white/10"
        >
          {playing ? <Pause size={20} /> : <Play size={20} />}
        </button>
      ) : recordingState.isRecording ? (
        <button onClick={stopRecording} className="rounded-full p-1.5 text-red-500 hover:bg-red-500/10">
          <Square size={20} fill="currentColor" />
        </button>
      ) : (
        <button onClick={startRecording} className="rounded-full p-1.5 text-red-500 hover:bg-red-500/10">
          <Circle size={20} fill="currentColor" />
        </button>
      )}

      <p className="flex-1 text-sm text-neutral-700 dark:text-neutral-300">{statusText}</p>

      {!isSending && !recordingState.isRecording && recordedAudio && blob && (
        <button
          onClick={handleSendRecording}
          className="rounded-full p-1.5 text-[#25D366] hover:bg-[#25D366]/10"
        >
          <SendHorizontal size={20} />
        </button>
      )}
      {!isSending && (
        <button
          disabled={recordingState.isRecording}
          onClick={onClose}
          className="rounded-full p-1.5 text-neutral-500 hover:bg-black/5 disabled:opacity-30 dark:text-neutral-400 dark:hover:bg-white/10"
        >
          <X size={20} />
        </button>
      )}
    </div>
  );
};

export default AudioContextMenu;
