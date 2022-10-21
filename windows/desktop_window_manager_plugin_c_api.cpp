#include "include/desktop_window_manager/desktop_window_manager_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "desktop_window_manager_plugin.h"

void DesktopWindowManagerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  desktop_window_manager::DesktopWindowManagerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
