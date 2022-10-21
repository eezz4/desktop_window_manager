import 'package:desktop_window_manager/window_control/window_control.dart';

class ImplWindowControlLinux implements IWindowControl {
  @override
  int getId() {
    throw UnimplementedError();
  }

  @override
  double getOpacity() {
    throw UnimplementedError();
  }

  @override
  bool isAlwaysOn() {
    throw UnimplementedError();
  }

  @override
  bool isDisabled() {
    throw UnimplementedError();
  }

  @override
  bool isMinimized() {
    throw UnimplementedError();
  }

  @override
  void setAlwaysOn(bool turnOn) {}

  @override
  void setDisabled(bool turnOn) {}

  @override
  void setMinimize(bool turnOn) {}

  @override
  void setOpacity(double opacity) {}
}
