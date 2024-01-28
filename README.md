# XCSoar-LK8000-hotkeys
Map joystick controls/buttons, or keys, to control XCSoar or LK8000. Great for VR.

This script controls XCSoar/LK8000 without losing focus (except to toggle mouse control) on your active app (ie. Condor).

![Screen Image](screen.png)

Besides switching pages or zooming in/out, here are some of the other things you can do in XCsoar / LK8000 without leaving Condor or VR:
- Go to the F1 Menu, access menus and adjust settings (eg: add ballast in "Flight Setup")
- Go to Pan Mode, look around the map and zoom in/out to plan out your route
- Go to next or prev waypoint
- Change MC setting
- Toggle between XCSoar/LK8000 and Condor as the active application, so you can use your mouse as needed.
- In LK8000, navigate between bottom bar fields and data pages, use multi-target, custom menu buttons,etc.


To use this:
1. Download the AHK script (requires you have AutoHotKey 1.1 installed) or the .exe file (does not require AHK) from releases: https://github.com/ryanwoodie/XCSoar-LK8000-hotkeys/releases (if you use the .exe you will get warnings from your browser and computer about it. It is safe to use.)
2. **XCSoar**: Copy the custom_keys.xci file to your XCSoar directory. In XCSoar go to config > system > language/input > events and choose this xci file.

   **LK8000**: Copy the DEFAULT_MENU.TXT file into the _System directory (rename or overwrite the existing file). Go to config > LK8000 Setup > Device Setup > Add a Device Model QWERTY Keyboard with Device Name Generic.
3. Run the AutoHotKey script and map keys/buttons or joystick axes, d-pad or HAT/POV to the various functions. Keep in mind that any keys you assign will not be available to other programs. So don't use the same keys that you do in Condor.


LK8000 can use a lot more keys, there is an extra tab for all these LK8000 keys, such as toggling the bottom bar fields. For XCsoar, you can use these for extra functions into your XCI file if you want to add your own (in the "global commandMappings" array in the AHK code you can see what hotkeys are being passed with the extra keys).

# Hard coded version
If know the AHK names for the keys/buttons you want to use, you can also modify the hard-coded-version.ahk script and use that instead.
