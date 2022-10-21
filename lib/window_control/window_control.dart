abstract class IWindowControl {
  int getId();

  bool isAlwaysOn();
  void setAlwaysOn(final bool turnOn);

  // opacity 0.0 ~ 1.0
  double getOpacity();
  void setOpacity(final double opacity);

  bool isDisabled();
  void setDisabled(final bool turnOn);

  bool isMinimized();
  void setMinimize(final bool turnOn);
}
