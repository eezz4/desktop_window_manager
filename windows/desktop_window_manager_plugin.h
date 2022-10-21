#ifndef FLUTTER_PLUGIN_DESKTOP_WINDOW_MANAGER_PLUGIN_H_
#define FLUTTER_PLUGIN_DESKTOP_WINDOW_MANAGER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace desktop_window_manager {

class DesktopWindowManagerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DesktopWindowManagerPlugin();

  virtual ~DesktopWindowManagerPlugin();

  // Disallow copy and assign.
  DesktopWindowManagerPlugin(const DesktopWindowManagerPlugin&) = delete;
  DesktopWindowManagerPlugin& operator=(const DesktopWindowManagerPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace desktop_window_manager

#endif  // FLUTTER_PLUGIN_DESKTOP_WINDOW_MANAGER_PLUGIN_H_
