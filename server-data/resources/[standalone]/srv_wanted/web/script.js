/*
  Servidor: draws the countdown badge and nothing else - client.lua decides when someone is marked
  and how many seconds are left; this file only ever displays the last message it received.
*/

const badge = document.getElementById('wanted');
const timeEl = document.getElementById('wanted-time');

let hideTimeout = null;

const formatTime = (totalSeconds) => {
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${String(seconds).padStart(2, '0')}`;
};

window.addEventListener('message', (event) => {
  const data = event.data;

  if (data.action === 'srv_wanted:show') {
    clearTimeout(hideTimeout);
    timeEl.textContent = formatTime(data.secondsLeft);
    badge.classList.remove('hidden');
    // Servidor: the fade-in transition needs `hidden` (display:none) gone for a frame before
    // `visible` is added, or the browser collapses the two class changes into one and never
    // animates - the same reason ox_lib's own ScaleFade waits a tick before mounting content.
    requestAnimationFrame(() => badge.classList.add('visible'));
  } else if (data.action === 'srv_wanted:hide') {
    badge.classList.remove('visible');
    hideTimeout = setTimeout(() => badge.classList.add('hidden'), 200);
  }
});
