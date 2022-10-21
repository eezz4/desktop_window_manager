//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <desktop_window_manager/desktop_window_manager_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) desktop_window_manager_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DesktopWindowManagerPlugin");
  desktop_window_manager_plugin_register_with_registrar(desktop_window_manager_registrar);
}
