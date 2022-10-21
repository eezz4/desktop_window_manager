# desktop_window_manager
![image](https://user-images.githubusercontent.com/4076516/197206669-f0a38e31-c4d8-47e0-8b50-875a398f82cd.png)

## 1.0.0

* initial release.
  - Only the Windows platform was implemented.

* IWindowsInfoProvider
  - makeWindowControlList
  - isCurrentWindow
  - getTitle
  - getIconMemory
  - getModuleName
  - getPath
  
* IWindowControl 
  - getId
  - isAlwaysOn
  - setAlwaysOn  
  - getOpacity
  - setOpacity
  - isDisabled
  - setDisabled
  - isMinimized
  - setMinimize
