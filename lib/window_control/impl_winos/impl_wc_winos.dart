import 'dart:developer';
import 'dart:ffi';

import 'package:desktop_window_manager/window_control/window_control.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class ImplWindowControlWinOS implements IWindowControl {
  final int _windowId;
  ImplWindowControlWinOS(this._windowId);

  @override
  int getId() {
    return _windowId;
  }

  @override
  bool isAlwaysOn() {
    final exStyle = GetWindowLongPtr(_windowId, GWL_EXSTYLE);
    return exStyle & WS_EX_TOPMOST != 0;
  }

  @override
  void setAlwaysOn(final bool turnOn) {
    if (true == turnOn) {
      final style = GetWindowLongPtr(_windowId, GWL_STYLE);
      if (style & WS_MINIMIZE > 0) ShowWindow(_windowId, SW_RESTORE);
      _setTopMost(_windowId);
      _setTop(_windowId);
    } else {
      _setNoTopMost(_windowId);
    }
  }

  @override
  double getOpacity() {
    var exStyle = GetWindowLongPtr(_windowId, GWL_EXSTYLE);
    if (0 == exStyle & WS_EX_LAYERED) return 1.0;

    const maxAlpha = 255;
    double retOpacity = 255;

    final lpcrKey = malloc<Uint32>();
    final lpbAlpha = malloc<Uint8>();
    final lpdwFlags = malloc<Uint32>();
    try {
      GetLayeredWindowAttributes(_windowId, nullptr, lpbAlpha, nullptr);
      retOpacity = lpbAlpha.value / maxAlpha;
    } catch (e) {
      log(e.toString());
    } finally {
      malloc.free(lpcrKey);
      malloc.free(lpbAlpha);
      malloc.free(lpdwFlags);
    }
    return retOpacity;
  }

  @override
  void setOpacity(final double opacity) {
    if (opacity < 0 || 1 < opacity) {
      throw Exception(
          'ImplWindowControlWinOS::setOpacity(), opacity accepts values between 0 and 1.');
    }

    var exStyle = GetWindowLongPtr(_windowId, GWL_EXSTYLE);
    exStyle |= WS_EX_LAYERED;
    SetWindowLongPtr(_windowId, GWL_EXSTYLE, exStyle);

    const maxAlpha = 255;
    SetLayeredWindowAttributes(
        _windowId, 0, (maxAlpha * opacity).toInt(), LWA_ALPHA);
  }

  @override
  bool isDisabled() {
    var exStyle = GetWindowLongPtr(_windowId, GWL_EXSTYLE);
    return exStyle & WS_EX_TRANSPARENT > 0;
  }

  @override
  void setDisabled(final bool turnOn) {
    // setDisabled() needs to add WS_EX_LAYERED,
    // Fix an issue where the initial opacity value appears to be 0 because there is no value.
    setOpacity(getOpacity());

    var exStyle = GetWindowLongPtr(_windowId, GWL_EXSTYLE);
    if (turnOn) {
      exStyle |= WS_EX_TRANSPARENT;
    } else {
      exStyle &= ~WS_EX_TRANSPARENT;
    }
    SetWindowLongPtr(_windowId, GWL_EXSTYLE, exStyle);
  }

  @override
  bool isMinimized() {
    return IsIconic(_windowId) > 0;
  }

  @override
  void setMinimize(final bool turnOn) {
    if (turnOn) {
      ShowWindow(_windowId, SW_MINIMIZE);
    } else {
      ShowWindow(_windowId, SW_RESTORE);
    }
  }
}

_setTopMost(final int windowId) {
  SetWindowPos(windowId, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
}

_setTop(final int windowId) {
  SetWindowPos(windowId, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
}

_setNoTopMost(final int windowId) {
  SetWindowPos(windowId, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
}
