import 'dart:io';
import 'dart:typed_data';

import 'package:desktop_window_manager/window_control/window_control.dart';
import 'package:desktop_window_manager/windows_info_provider/impl_macos/impl_wip_macos.dart';
import 'package:desktop_window_manager/windows_info_provider/impl_winos/impl_wip_winos.dart';

abstract class IWindowsInfoProvider {
  factory IWindowsInfoProvider() {
    if (Platform.isWindows) return ImplWindowInfoProviderWinOS();
    if (Platform.isMacOS) return ImplWindowsInfoProviderMacOS();
    throw Exception('IWindowsInfoProvider: Unsupported platform');
  }

  List<IWindowControl> makeWindowControlList();

  bool isCurrentWindow(final IWindowControl wc);
  String getTitle(final IWindowControl wc);
  Uint8List getIconMemory(final IWindowControl wc);
  String getModuleName(final IWindowControl wc);
  String getPath(final IWindowControl wc);
}
