import 'dart:typed_data';

import 'package:desktop_window_manager/window_control/window_control.dart';
import 'package:desktop_window_manager/windows_info_provider/windows_info_provider.dart';

class ImplWindowsInfoProviderLinux implements IWindowsInfoProvider {
  @override
  Uint8List getIconHeadless(IWindowControl wc) {
    throw UnimplementedError();
  }

  @override
  String getModuleName(IWindowControl wc) {
    throw UnimplementedError();
  }

  @override
  String getPath(IWindowControl wc) {
    throw UnimplementedError();
  }

  @override
  String getTitle(IWindowControl wc) {
    throw UnimplementedError();
  }

  @override
  bool isCurrentWindow(IWindowControl wc) {
    throw UnimplementedError();
  }

  @override
  List<IWindowControl> makeWindowControlList() {
    throw UnimplementedError();
  }
}
