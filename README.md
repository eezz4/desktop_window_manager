# desktop_window_manager

![image](https://user-images.githubusercontent.com/4076516/197206669-f0a38e31-c4d8-47e0-8b50-875a398f82cd.png)
[pub.dev](https://pub.dev/packages/desktop_window_manager)

## 2.0.0

- Only Windows platforms have been implemented yet.

- IWindowsInfoProvider
  - makeWindowControlList
  - isCurrentWindow
  - getTitle
  - getIconHeadless
  - getModuleName
  - getPath
- IWindowControl
  - getId
  - isAlwaysOn
  - setAlwaysOn
  - getOpacity
  - setOpacity
  - isDisabled
  - setDisabled
  - isMinimized
  - setMinimize
