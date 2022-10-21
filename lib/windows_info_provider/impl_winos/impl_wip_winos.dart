import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';
import 'package:desktop_window_manager/window_control/impl_winos/impl_wc_winos.dart';
import 'package:desktop_window_manager/window_control/window_control.dart';
import 'package:desktop_window_manager/windows_info_provider/windows_info_provider.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'win32.constant.dart';

class ImplWindowInfoProviderWinOS implements IWindowsInfoProvider {
  late final String _currentTitleForSafe;

  ImplWindowInfoProviderWinOS() {
    final idList = _getIdList();
    final currentWindowId = idList.firstWhere(
        (windowId) => _isCurrentWindow(windowId),
        orElse: () =>
            throw Exception('ImpWindowInfoProviderWinOS: not found id.'));

    _currentTitleForSafe = _getTitle(true, currentWindowId);
  }

  @override
  List<IWindowControl> makeWindowControlList() {
    return _getIdList()
        .where((windowId) => _getTitle(false, windowId).isNotEmpty)
        .map((windowId) => ImplWindowControlWinOS(windowId))
        .toList();
  }

  @override
  String getModuleName(final IWindowControl wc) {
    final windowId = wc.getId();
    return _getModuleName(windowId, false);
  }

  @override
  String getPath(final IWindowControl wc) {
    final windowId = wc.getId();
    return _getModuleName(windowId, true);
  }

  @override
  String getTitle(final IWindowControl wc) {
    final windowId = wc.getId();
    return _getTitle(false, windowId);
  }

  @override
  Uint8List getIconMemory(final IWindowControl wc) {
    final windowId = wc.getId();
    final hIcon = _getIcon(windowId);

    const width = 36, height = 36;
    const x = 0, y = 0;

    final pScreenHDC = GetDC(0); // 바탕 화면.
    final pMemoryHDC = CreateCompatibleDC(pScreenHDC);
    final pMemoryHBITMAP = CreateCompatibleBitmap(pScreenHDC, width, height);
    try {
      SelectObject(pMemoryHDC, pMemoryHBITMAP);

      // DrawIcon(pScreenHDC, x, y, hIcon); // test
      DrawIcon(pMemoryHDC, x, y, hIcon); // 메모리에 그림.

      final lpBmp = calloc<BITMAP>();
      GetObject(pMemoryHBITMAP, sizeOf<BITMAP>(), lpBmp);

      final lpBitmapInfoHeader = calloc<BITMAPINFOHEADER>();
      _initBitmapInfoHeader(lpBitmapInfoHeader, lpBmp);

      final dwBmpSize = _getDwBmpSize(lpBitmapInfoHeader);
      final lpBitmap = calloc<Uint8>(dwBmpSize);
      try {
        GetDIBits(
            pMemoryHDC,
            pMemoryHBITMAP,
            0,
            lpBitmapInfoHeader.ref.biHeight,
            lpBitmap,
            lpBitmapInfoHeader.cast(),
            DIB_RGB_COLORS);

        final bitList = lpBitmap.asTypedList(dwBmpSize);
        final bitmap = Bitmap.fromHeadless(
            width, height, Uint8List.fromList(bitList.reversed.toList()));

        final modBitmap = bitmap.applyBatch([BitmapFlip.horizontal()]);
        return modBitmap.buildHeaded();
      } catch (e) {
        log(e.toString());
      } finally {
        calloc.free(lpBmp);
        calloc.free(lpBitmapInfoHeader);
        calloc.free(lpBitmap);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      DeleteObject(pMemoryHBITMAP);
      DeleteDC(pMemoryHDC);
      ReleaseDC(0, pScreenHDC);
    }
    return Uint8List.fromList([]);
  }

  @override
  bool isCurrentWindow(final IWindowControl wc) {
    final windowId = wc.getId();
    return _isCurrentWindow(windowId);
  }

  ///////////////////////
  List<int> _getIdList() {
    List<int> windowIdList = [];
    final lpString = wsalloc(MAX_PATH);
    try {
      int windowId = 0;
      do {
        windowId = FindWindowEx(0, windowId, nullptr, nullptr);
        // Determines whether the specified window handle identifies an existing window.
        if (0 == IsWindow(windowId)) continue;
        // Determines the visibility state of the specified window
        if (0 == IsWindowVisible(windowId)) continue;

        windowIdList.add(windowId);
      } while (windowId != 0);
    } catch (e) {
      log(e.toString());
    } finally {
      free(lpString);
    }

    return windowIdList;
  }

  String _getTitle(bool ensureInitCall, final int windowId) {
    // 1
    if (_isCurrentWindow(windowId) && ensureInitCall == false) {
      return _currentTitleForSafe;
    }

    // 2
    final lpString = wsalloc(MAX_PATH);
    try {
      sendMessageTimeoutSafe(windowId, WM_GETTEXT, MAX_PATH, lpString.address);
      return lpString.toDartString();
    } finally {
      free(lpString);
    }
  }
}

int sendMessageTimeoutSafe(int windowId, int msg, int wParam, int lParam) {
  return SendMessageTimeout(
      windowId, msg, wParam, lParam, SMTO_BLOCK, 10, nullptr);
  // SMTO_NORMAL, 0 : dead, 1~ : wait 1 sec
  // SMTO_BLOCK, 0 : dead, x000 : wait x sec
  // SMTO_ABORTIFHUNG,
  // SMTO_NOTIMEOUTIFNOTHUNG,
  // SMTO_ERRORONEXIT,
}

int _getHInstance(final int windowId) {
  return GetWindowLongPtr(windowId, GWL_HINSTANCE);
}

bool _isCurrentWindow(final int windowId) {
  return GetModuleHandle(nullptr) == _getHInstance(windowId);
}

int _getIcon(final int windowId) {
  var hIcon = 0;
  hIcon = GetClassLongPtr(windowId, GCL_HICON);
  if (hIcon != 0) return hIcon;
  hIcon = SendMessage(windowId, WM_GETICON, ICON_BIG, 0);
  if (hIcon != 0) return hIcon;
  hIcon = SendMessage(windowId, WM_GETICON, ICON_SMALL2, 0);
  if (hIcon != 0) return hIcon;
  hIcon = SendMessage(windowId, WM_GETICON, ICON_SMALL, 0);
  return hIcon;
}

void _initBitmapInfoHeader(final Pointer<BITMAPINFOHEADER> lpBitmapInfoHeader,
    final Pointer<BITMAP> pBmp) {
  lpBitmapInfoHeader.ref.biSize = sizeOf<BITMAPINFOHEADER>();
  lpBitmapInfoHeader.ref.biWidth = pBmp.ref.bmWidth;
  lpBitmapInfoHeader.ref.biHeight = pBmp.ref.bmHeight;
  lpBitmapInfoHeader.ref.biPlanes = 1;
  lpBitmapInfoHeader.ref.biBitCount = 32;
  lpBitmapInfoHeader.ref.biCompression = BI_RGB;
}

int _getDwBmpSize(final Pointer<BITMAPINFOHEADER> bitmapInfoHeader) {
  final widths =
      (bitmapInfoHeader.ref.biWidth * bitmapInfoHeader.ref.biBitCount + 31);
  return (widths / 32 * 4 * bitmapInfoHeader.ref.biHeight).toInt();
}

String _getModuleName(final int windowId, final bool addPath) {
  String ret = '';
  final lpdwProcessId = calloc<Uint32>();
  final lpName = wsalloc(MAX_PATH);
  GetWindowThreadProcessId(windowId, lpdwProcessId);
  try {
    final pHANDLE = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
        FALSE, lpdwProcessId.value);
    try {
      if (addPath) {
        GetModuleFileNameEx(pHANDLE, NULL, lpName, MAX_PATH);
      } else {
        GetModuleBaseName(pHANDLE, NULL, lpName, MAX_PATH);
      }

      ret = lpName.toDartString();
    } catch (e) {
      log(e.toString());
    } finally {
      CloseHandle(pHANDLE);
    }
  } catch (e) {
    log(e.toString());
  } finally {
    free(lpdwProcessId);
    free(lpName);
  }

  return ret;
}
