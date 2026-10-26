import { PhotoEvents } from '@typings/photo';
import { Delay } from '../utils/fivem';
import { sendCameraEvent, sendMessage } from '../utils/messages';
import { PhoneEvents } from '@typings/phone';
import { ClUtils } from './client';
import { animationService } from './animations/animation.controller';
import { RegisterNuiCB, RegisterNuiProxy } from './cl_utils';

let inCameraMode = false;
let canToggleHUD = false;
let canToggleRadar = false;

function closePhoneTemp() {
  SetNuiFocus(false, false);
  sendMessage('PHONE', PhoneEvents.SET_VISIBILITY, false);
}

function openPhoneTemp() {
  SetNuiFocus(true, true);
  sendMessage('PHONE', PhoneEvents.SET_VISIBILITY, true);
}

function CellFrontCamActivate(activate: boolean) {
  return Citizen.invokeNative('0x2491A93618B7D838', activate);
}

// Server: GTA's own help box (BeginTextCommandDisplayHelp) is top-left furniture that matches
// nothing else on this server, and it sat right over the shot. Replaced with our own panel in
// the top-right corner: a translucent dark plate, the key in the phone's green accent, the
// action in white.
//
// The keys are read off the control ids the loop below actually checks, not from GTA's
// ~INPUT_*~ tokens, so the hint can never drift from the binding it describes.
// Key names are plain Latin text on purpose. GTA's own fonts have no glyph for "↑", so an arrow
// character renders as a broken box - accented Latin (câmera) is fine, arbitrary symbols are not.
// Each action ends with a period, matching the project-wide punctuation rule for `[E]` prompts.
const CAMERA_HINTS: { key: string; action: string }[] = [
  { key: 'Seta cima', action: 'Trocar câmera.' },
  { key: 'Enter', action: 'Tirar foto.' },
  { key: 'Backspace', action: 'Sair.' },
];

const HINT_RIGHT_EDGE = 0.982;
const HINT_PLATE_WIDTH = 0.2;
const HINT_PLATE_HEIGHT = 0.032;
const HINT_FIRST_LINE_Y = 0.03;
// Gap between plates, so each hint reads as its own prompt rather than one merged block.
const HINT_LINE_STEP = HINT_PLATE_HEIGHT + 0.008;

const displayHelperText = () => {
  CAMERA_HINTS.forEach(({ key, action }, index) => {
    const plateCentreY = HINT_FIRST_LINE_Y + index * HINT_LINE_STEP;

    // One plate per hint, all the same width - a fixed width rather than a measured one, so the
    // stack stays aligned without depending on the text-width natives.
    DrawRect(
      HINT_RIGHT_EDGE - HINT_PLATE_WIDTH / 2 + 0.008,
      plateCentreY,
      HINT_PLATE_WIDTH,
      HINT_PLATE_HEIGHT,
      0,
      0,
      0,
      160,
    );

    SetTextFont(4);
    SetTextScale(0.0, 0.36);
    SetTextColour(255, 255, 255, 235);
    SetTextRightJustify(true);
    SetTextWrap(0.0, HINT_RIGHT_EDGE);
    BeginTextCommandDisplayText('STRING');
    // `[key] action`, matching the `[E] <label>` prompt convention used everywhere in-world.
    AddTextComponentString(`~g~[${key}]~s~ ${action}`);
    EndTextCommandDisplayText(0.0, plateCentreY - 0.011);
  });
};

// TODO: The flow here seems a little convuluted, we need to take a look at it.
RegisterNuiCB<void>(PhotoEvents.TAKE_PHOTO, async (_, cb) => {
  await animationService.openCamera();
  emit('npwd:disableControlActions', false);
  // Create Phone Prop
  let frontCam = false;
  CreateMobilePhone(1);
  // Active Camera Change
  CellCamActivate(true, true);
  // Hide phone from rendering temporary
  closePhoneTemp();
  SetNuiFocus(false, false);

  inCameraMode = true;

  // If hud is not already hidden (by another resource), Hide the hud
  if (!IsHudHidden()) {
    canToggleHUD = true;
    DisplayHud(false);
  } else {
    canToggleHUD = false;
  }

  // If radar is not already hidden (by another resource), Hide the radar
  if (!IsRadarHidden()) {
    canToggleRadar = true;
    DisplayRadar(false);
  } else {
    canToggleRadar = false;
  }

  // We want to emit this event for UI handling in other resources
  // We hide nothing in NPWD by default
  emit(PhotoEvents.NPWD_PHOTO_MODE_STARTED);

  while (inCameraMode) {
    await Delay(0);

    // Arrow Up Key, Toggle Front/Back Camera
    if (IsControlJustPressed(1, 27)) {
      frontCam = !frontCam;
      CellFrontCamActivate(frontCam);
      // Enter Key, Take Photo
    } else if (IsControlJustPressed(1, 176)) {
      const resp = await handleTakePicture();
      cb(resp);
      break;
    } else if (IsControlJustPressed(1, 194)) {
      await handleCameraExit();
      break;
    }
    displayHelperText();
  }

  // We can now signal to other resources for ending photo mode
  // and redisplaying HUD components
  emit(PhotoEvents.NPWD_PHOTO_MODE_ENDED);

  emit('npwd:disableControlActions', true);
  await animationService.closeCamera();
});

const handleTakePicture = async () => {
  // Wait a frame so the hint panel is not in the shot - the loop that draws it has already
  // broken out by the time this runs, so one frame is enough for it to disappear.
  await Delay(0);
  /*
   * If we don't do this janky work around players get stuck in their camera
   * until the entire server callback has happened, which doesn't matter for
   * people with fast internet but a lot of people still have slow internet
   */

  const resp = await ClUtils.emitNetPromise(PhotoEvents.UPLOAD_PHOTO);
  DestroyMobilePhone();
  CellCamActivate(false, false);
  openPhoneTemp();
  animationService.openPhone();
  emit('npwd:disableControlActions', true);
  inCameraMode = false;

  // If hud is already hidden (by this resource), Show the hud
  if (canToggleHUD) {
    DisplayHud(true);
    canToggleHUD = false;
  }

  // If radar is already hidden (by this resource), Show the radar
  if (canToggleRadar) {
    DisplayRadar(true);
    canToggleRadar = false;
  }

  return resp;
};

const handleCameraExit = async () => {
  sendCameraEvent(PhotoEvents.CAMERA_EXITED);
  await animationService.closeCamera();
  emit('npwd:disableControlActions', true);
  DestroyMobilePhone();
  CellCamActivate(false, false);
  openPhoneTemp();
  inCameraMode = false;

  // If hud is already hidden (by this resource), Show the hud
  if (canToggleHUD) {
    DisplayHud(true);
    canToggleHUD = false;
  }

  // If radar is already hidden (by this resource), Show the radar
  if (canToggleRadar) {
    DisplayRadar(true);
    canToggleRadar = false;
  }
};

RegisterNuiProxy(PhotoEvents.FETCH_PHOTOS);
RegisterNuiProxy(PhotoEvents.DELETE_PHOTO);
RegisterNuiProxy(PhotoEvents.SAVE_IMAGE);
RegisterNuiProxy(PhotoEvents.DELETE_MULTIPLE_PHOTOS);
