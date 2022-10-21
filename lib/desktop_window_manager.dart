library desktop_window_manager;

import 'package:desktop_window_manager/windows_info_provider/windows_info_provider.dart';

class DesktopWindowManager {
  DesktopWindowManager._();
  static late final IWindowsInfoProvider wiProvider;
  static void ensureInitialized() {
    wiProvider = IWindowsInfoProvider();
  }
}
