# XCSoar-LK8000-LXSim-hotkeys

NOTE: Script needs modification for non-QWERTY keyboards to work with LXSim (see issues tab).

Map joystick controls/buttons, or keys, to control XCSoar, LK8000, or LXSim. Great for VR.

This script controls XCSoar/LK8000/LXSim without losing focus (except to toggle mouse control) on your active app (ie. Condor).

![Screen Image](screen.png)

Besides switching pages or zooming in/out, here are some of the other things you can do in XCsoar / LK8000 / LXSim without leaving Condor or VR:
- Go to the F1 Menu, access menus and adjust settings (eg: add ballast in "Flight Setup")
- Go to Pan Mode, look around the map and zoom in/out to plan out your route
- Go to next or prev waypoint
- Change MC setting
- Toggle between XCSoar/LK8000/LXSim and Condor as the active application, so you can use your mouse as needed
- In LK8000, navigate between bottom bar fields and data pages, use multi-target, custom menu buttons, etc.
- In LXSim, control all dials and buttons just like the physical device

To use this:
1. Download the AHK script (requires you have AutoHotKey 1.1 installed) or the .exe file (does not require AHK) from releases: https://github.com/ryanwoodie/XCSoar-LK8000-hotkeys/releases (if you use the .exe you will get warnings from your browser and computer about it. It is safe to use.)
2. **XCSoar**: Copy the custom_keys.xci file to your XCSoar directory. In XCSoar go to config > system > language/input > events and choose this xci file.

   **LK8000**: Copy the DEFAULT_MENU.TXT file into the _System directory (rename or overwrite the existing file). Go to config > LK8000 Setup > Device Setup > Add a Device Model QWERTY Keyboard with Device Name Generic.
   
   **LXSim**: No additional configuration required. The script will send the appropriate keystrokes directly to LXSim.
3. Run the AutoHotKey script and map keys/buttons or joystick axes, d-pad or HAT/POV to the various functions. Keep in mind that any keys you assign will not be available to other programs. So don't use the same keys that you do in Condor.

## Additional Controls

**LK8000**: There is an extra tab for all LK8000 keys, such as toggling the bottom bar fields. For XCsoar, you can use these for extra functions into your XCI file if you want to add your own (in the "global commandMappings" array in the AHK code you can see what hotkeys are being passed with the extra keys).

**LXSim**: The LXSim tab provides controls for:
- Top Right Dial (Page Up/Down)
- Bottom Right Dial (Up/Down)
- Bottom Left Dial (Zoom In/Out)
- Top Buttons 1-4
- Bottom Buttons 1-4
- OK and Cancel buttons
- The toggle mouse hotkey on the XCsoar tab will also toggle to LXSim for mouse control

## New Features

### Restart Flight Function
The script now includes a Restart Flight function that can be assigned to any key or joystick button. This feature allows you to:
- Quickly restart a flight in Condor without using the mouse
- Switch focus to Condor automatically
- Navigate the menu and click the restart button

You can assign this function in two ways:
1. Through the main GUI under the "Mouse / Restart" tab
2. Using the standalone script `restart flight.ahk` (includes both restart and exit flight functions)

The function works by:
1. Switching focus to Condor
2. Opening the menu with Esc
3. Clicking the restart button automatically

Note: The function assumes Condor resets the mouse to position (900,540) when focused, which is used as a reference point for the menu navigation.

# Hard coded version
If you know the AHK names for the keys/buttons you want to use, you can also modify the hard-coded-version.ahk script and use that instead.
