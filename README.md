# FrontBoardAppLauncher
Reference usage of FrontBoard &amp; UIKit private API to display external app scene.

This app implements multitasking.

## Supported iOS versions
Requires TrollStore.

iOS 15.0+ are supported.

iOS 14.x is not yet supported. There is an issue in FrontBoard.

## Known issues
- Apps stay running even after closing
- In-app keyboard offset may be off
- Keyboard doesn't work when windowed on top of SpringBoard yet
- Re-opening an app after closing may crash
- Single-scene apps may not work yet. You may see empty window in such cases.
