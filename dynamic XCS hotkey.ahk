#InstallKeybdHook
#Persistent
#NoEnv
#SingleInstance, force
SendMode Input
SetWorkingDir %A_ScriptDir%
;#Warn
SetTimer, joy_check, 150
SetTitleMatchMode, 2
DetectHiddenWindows, On


; Global variables and mappings
global iniFilePath := A_ScriptDir . "\settings.ini"
global commandList := ["Enter", "Esc", "F1_Quick_Menu", "Up", "Down", "Left", "Right", "Zoom_Out", "Zoom_In", "Pan_Mode", "Auto_MC", "MC_Up", "MC_Down", "Task_Next", "Task_Previous", "Toggle_Mouse", "Extra_LK_Bottom_Bar_L", "Extra_LK_Bottom_Bar_R", "Extra_LK_Prev_Page", "Extra_LK_Next_Page", "Extra_LK_Top_Left", "Extra_LK_Top_Right", "Extra_LK_custom_menu_q", "Extra_LK_custom_menu_w", "Extra_LK_custom_menu_e", "Extra_LK_custom_menu_r", "Extra_LK_custom_menu_t", "Extra_LK_custom_menu_y", "Extra_LK_custom_menu_u", "Extra_LK_custom_menu_i", "Extra_LK_custom_menu_o", "Extra_LK_custom_menu_p", "LXSim_Top_Dial_PageUp", "LXSim_Top_Dial_PageDown", "LXSim_Bottom_Right_Up", "LXSim_Bottom_Right_Down", "LXSim_Bottom_Left_Left_Zoom_Out", "LXSim_Bottom_Left_Right_Zoom_In", "LXSim_Top_Button_1", "LXSim_Top_Button_2", "LXSim_Top_Button_3", "LXSim_Top_Button_4", "LXSim_Bottom_Button_1", "LXSim_Bottom_Button_2", "LXSim_Bottom_Button_3", "LXSim_Bottom_Button_4", "LXSim_OK", "LXSim_Cancel"]

global commandMappings := {"Enter": "{Enter}", "Esc": "{Escape}", "F1_Quick_Menu": "{F1}", "Up": "{Up}", "Down": "{Down}", "Left": "{Left}", "Right": "{Right}", "Zoom_Out": "{F3}", "Zoom_In": "{F4}", "Pan_Mode": "{F2}", "Auto_MC": "{F6}", "MC_Up": "{F7}", "MC_Down": "{F8}", "Task_Next": "{F9}", "Task_Previous": "{F10}", "Toggle_Mouse": "{F13}", "Extra_LK_Bottom_Bar_L": "{a}", "Extra_LK_Bottom_Bar_R": "{s}", "Extra_LK_Prev_Page": "{d}", "Extra_LK_Next_Page": "{f}", "Extra_LK_Top_Left": "{g}", "Extra_LK_Top_Right": "{h}", "Extra_LK_custom_menu_q": "{q}", "Extra_LK_custom_menu_w": "{w}", "Extra_LK_custom_menu_e": "{e}", "Extra_LK_custom_menu_r": "{r}", "Extra_LK_custom_menu_t": "{t}", "Extra_LK_custom_menu_y": "{y}", "Extra_LK_custom_menu_u": "{u}", "Extra_LK_custom_menu_i": "{i}", "Extra_LK_custom_menu_o": "{o}", "Extra_LK_custom_menu_p": "{p}", "LXSim_Top_Dial_PageUp": "{PgUp}", "LXSim_Top_Dial_PageDown": "{PgDn}", "LXSim_Bottom_Right_Up": "{Up}", "LXSim_Bottom_Right_Down": "{Down}", "LXSim_Bottom_Left_Left": "{Left}", "LXSim_Bottom_Left_Right": "{Right}", "LXSim_Top_Button_1": "{1}", "LXSim_Top_Button_2": "{2}", "LXSim_Top_Button_3": "{3}", "LXSim_Top_Button_4": "{4}", "LXSim_Bottom_Button_1": "{q}", "LXSim_Bottom_Button_2": "{w}", "LXSim_Bottom_Button_3": "{e}", "LXSim_Bottom_Button_4": "{r}","LXSim_OK": "{l}", "LXSim_Cancel": "{j}"}

global joystickBindings := {}
global hotkeyCommands := {}
global JoystickNumber = 0
global UserInput := ""
global currentTab := 1

Loop 16  ; Query each joystick number to find out which ones exist.
{
    GetKeyState, JoyName, %A_Index%JoyName
    if JoyName <>
    {
        JoystickNumber = %A_Index%
    }
}

; Initialize key assignments
createKeys()
gosub,config

; Hotkey to start the configuration
^i::
    Gosub, config
return

; Function to create keys
createKeys() {
    for index, commandName in commandList {
        IniRead, keyAssignment, %iniFilePath%, InputBindings, %commandName%
        if (keyAssignment != "ERROR") {
            if InStr(keyAssignment, ",") {
                ; Handle joystick input
                bindingParts := StrSplit(keyAssignment, ",")
                joystickBindings[commandName] := {"axis": bindingParts[1], "trigger": bindingParts[2]}
                axis := joystickBindings[commandName]["axis"]
                trigger := joystickBindings[commandName]["trigger"]
            } else {
                ; Treat it as a hotkey
                hotkeyCommands[keyAssignment] := commandName
                Hotkey, % keyAssignment, DynamicHotkeyFunction
            }
        }
    }
}

GetXCSoarWindows() {
    windows := []
    WinGet, id, list,,,
    Loop, %id%
    {
        this_id := id%A_Index%
        WinGet, this_exe, ProcessName, ahk_id %this_id%
        if (InStr(this_exe, "XCSoar", true) || InStr(this_exe, "LXSim", true) || InStr(this_exe, "LK8000-PC", true)) {
            windows.Push({"id": this_id, "process": this_exe})
        }
    }
    return windows
}

; Generic function for dynamic hotkeys
DynamicHotkeyFunction:
    global hotkeyCommands, commandMappings
    commandName := hotkeyCommands[A_ThisHotkey]
    if (commandName != "") {
        sendString := commandMappings[commandName]
        if (sendString != "") {
            SendToXCS(sendString)
        } else {
            Tooltip, % "No command string found for: " . commandName
        }
    } else {
        Tooltip, % "Unknown hotkey: " . A_ThisHotkey
    }
return

; Handles piping individual keys to all supported programs
SendToXCS(keys) {
    static toggleState := 1

    if (keys = "{F13}") {
        toggleState := !toggleState

        if (toggleState = 1) {
            if WinExist("ahk_exe CONDOR.EXE") {
                WinActivate
            }
        } else {
            ; Try to find and activate any supported executable
            xcsoarWindows := GetXCSoarWindows()
            if (xcsoarWindows.Length() > 0) {
                ; Activate the first window found
                WinID := xcsoarWindows[1].id
                WinActivate, ahk_id %WinID%
                sleep 200
                CoordMode, Mouse, Screen
                WinGetPos, X, Y, W, H, A
                Horz := X + (W / 2)
                Vert := Y + (H / 2)
                DllCall("SetCursorPos", "int", Horz, "int", Vert)
            }
        }
        return
    }

    ; Send keys to all supported executables
    xcsoarWindows := GetXCSoarWindows()
    for index, window in xcsoarWindows {
        WinID := window.id
        ControlGetFocus, CursorPosition, ahk_id %WinID%
        if (!CursorPosition) {
            ControlSend, ahk_parent, %keys%, ahk_id %WinID%
        } else {
            ControlSend, %CursorPosition%, %keys%, ahk_id %WinID%
        }
    }
    return
}
config:
{
    Gui, New
    guiYPosition := 25
    Gui, Add, Text, x10 y%guiYPosition% w800, Press and hold your key/button until it is detected. If the key (eg. F1) needs a modifier button (eg. Fn), hold the modifier before pressing the assign button below
    guiYPosition += 40  ; Adjust the position for the next element

    Gui, Add, Tab3, x2 y2 h800 w1000 vCurrentTab gTabChanged, XCsoar and LK8000 Controls|Extra LK8000 Controls|LXSim Controls

    ; Regular Keys Tab
    Gui, Tab, XCsoar and LK8000 Controls
    Gui,Font,bold
    Gui, Add, Text, x10 y%guiYPosition%, Function:
    Gui, Add, Text, x525 y%guiYPosition%, Current Key/Value:
    guiYPosition += 20
    Gui,Font,normal

    for index, commandName in commandList {
        if (!StrContains(commandName, "Extra_") && !StrContains(commandName, "LXSim_")) { 
            IniRead, currentKeyValue, %iniFilePath%, InputBindings, %commandName%, None
            Gui, Add, Text, x10 y%guiYPosition% w200, %commandName%
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignInput v%commandName%_xyz, Assign Key/Button
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignAxis v%commandName%_abc, Assign Axis/HAT
            Gui, Add, Text, x+5 y%guiYPosition% w200, %currentKeyValue%
            guiYPosition += 30
            commandName := ""
        }
    }

    ; Extra Keys Tab
    Gui, Tab, Extra LK8000 Controls
    guiYPosition := 65

    Gui,Font,bold
    Gui, Add, Text, x10 y%guiYPosition%, LK8000 functions (or XCsoar extra keys):
    Gui, Add, Text, x525 y%guiYPosition%, Current Key/Value:
    guiYPosition += 20
    Gui,Font,normal

    for index, commandName in commandList {
        if (StrContains(commandName, "Extra_")) {  
            IniRead, currentKeyValue, %iniFilePath%, InputBindings, %commandName%, None
            Gui, Add, Text, x10 y%guiYPosition% w200, %commandName%
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignInput v%commandName%_xyz, Assign Key/Button
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignAxis v%commandName%_abc, Assign Axis/HAT
            Gui, Add, Text, x+5 y%guiYPosition% w200, %currentKeyValue%
            guiYPosition += 30
            commandName := ""
        }
    }

; LXSim Controls Tab
; LXSim Controls Tab
Gui, Tab, LXSim Controls
guiYPosition := 65

Gui,Font,bold
Gui, Add, Text, x10 y%guiYPosition%, LXSim Device Controls:
Gui, Add, Text, x525 y%guiYPosition%, Current Key/Value:
guiYPosition += 20
Gui,Font,normal

; Add groupbox for general actions
Gui, Add, GroupBox, x10 y%guiYPosition% w650 h100, General Actions
guiYPosition += 30

; OK and Cancel buttons
for index, commandName in commandList {
    if (commandName = "LXSim_OK" || commandName = "LXSim_Cancel") {
        friendlyName := StrReplace(commandName, "LXSim_", "")
        IniRead, currentKeyValue, %iniFilePath%, InputBindings, %commandName%, None
        Gui, Add, Text, x20 y%guiYPosition% w200, %friendlyName%
        Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignInput v%commandName%_xyz, Assign Key/Button
        Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignAxis v%commandName%_abc, Assign Axis/HAT
        Gui, Add, Text, x+5 y%guiYPosition% w200, %currentKeyValue%
        guiYPosition += 30
    }
}

guiYPosition += 40  ; Increased spacing after General Actions
; Add groupbox for dials
Gui, Add, GroupBox, x10 y%guiYPosition% w650 h250, Dial Controls
guiYPosition += 30  ; Move inside the group box

; Top Right Dial
for index, commandName in commandList {
    if (StrContains(commandName, "LXSim_Top_Dial_")) {
        friendlyName := StrReplace(commandName, "LXSim_Top_Dial_", "Top Right Dial - ")
        IniRead, currentKeyValue, %iniFilePath%, InputBindings, %commandName%, None
        Gui, Add, Text, x20 y%guiYPosition% w200, %friendlyName%
        Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignInput v%commandName%_xyz, Assign Key/Button
        Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignAxis v%commandName%_abc, Assign Axis/HAT
        Gui, Add, Text, x+5 y%guiYPosition% w200, %currentKeyValue%
        guiYPosition += 30
    }
}

    ; Bottom Right Dial
    for index, commandName in commandList {
        if (StrContains(commandName, "LXSim_Bottom_Right_")) {
            friendlyName := StrReplace(commandName, "LXSim_Bottom_Right_", "Bottom Right Dial  - ")
            IniRead, currentKeyValue, %iniFilePath%, InputBindings, %commandName%, None
            Gui, Add, Text, x20 y%guiYPosition% w200, %friendlyName%
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignInput v%commandName%_xyz, Assign Key/Button
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignAxis v%commandName%_abc, Assign Axis/HAT
            Gui, Add, Text, x+5 y%guiYPosition% w200, %currentKeyValue%
            guiYPosition += 30
        }
    }

    ; Bottom Left Dial
    for index, commandName in commandList {
        if (StrContains(commandName, "LXSim_Bottom_Left_")) {
            friendlyName := StrReplace(commandName, "LXSim_Bottom_Left_", "Bottom Left Dial - ")
            IniRead, currentKeyValue, %iniFilePath%, InputBindings, %commandName%, None
            Gui, Add, Text, x20 y%guiYPosition% w200, %friendlyName%
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignInput v%commandName%_xyz, Assign Key/Button
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignAxis v%commandName%_abc, Assign Axis/HAT
            Gui, Add, Text, x+5 y%guiYPosition% w200, %currentKeyValue%
            guiYPosition += 30
        }
    }

    ; Add groupbox for buttons
    guiYPosition += 20
    Gui, Add, GroupBox, x10 y%guiYPosition% w650 h300, Button Controls (not available in Condor)
    guiYPosition += 30

    ; Top Buttons
    for index, commandName in commandList {
        if (StrContains(commandName, "LXSim_Top_Button_")) {
            friendlyName := StrReplace(commandName, "LXSim_Top_Button_", "Top Button ")
            IniRead, currentKeyValue, %iniFilePath%, InputBindings, %commandName%, None
            Gui, Add, Text, x20 y%guiYPosition% w200, %friendlyName%
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignInput v%commandName%_xyz, Assign Key/Button
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignAxis v%commandName%_abc, Assign Axis/HAT
            Gui, Add, Text, x+5 y%guiYPosition% w200, %currentKeyValue%
            guiYPosition += 30
        }
    }

    ; Bottom Buttons
    guiYPosition += 10
    for index, commandName in commandList {
        if (StrContains(commandName, "LXSim_Bottom_Button_")) {
            friendlyName := StrReplace(commandName, "LXSim_Bottom_Button_", "Bottom Button ")
            IniRead, currentKeyValue, %iniFilePath%, InputBindings, %commandName%, None
            Gui, Add, Text, x20 y%guiYPosition% w200, %friendlyName%
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignInput v%commandName%_xyz, Assign Key/Button
            Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignAxis v%commandName%_abc, Assign Axis/HAT
            Gui, Add, Text, x+5 y%guiYPosition% w200, %currentKeyValue%
            guiYPosition += 30
        }
    }
 
    Gui, Tab  ; End of tabs
    guiYPosition += 20  ; Add some padding
Gui, Add, Button, x100 y%guiYPosition% w200 gGuiClose, Close and Activate

    Gui, Show
    return
}

GuiClose:
    Gui, Destroy
    createKeys()
    return

StrContains(haystack, needle) {
    return InStr(haystack, needle) ? true : false
}

; Subroutine for assigning input
AssignInput() {
    selectedCommand := StrReplace(A_GuiControl,"_xyz")
    GuiControl,, %A_GuiControl%, Press Key/Button  ; Update the button text
    inputStartTime := A_TickCount
    UserInput := ""
    Loop
    {
        Loop, 512
        {
            keyName := Format("sc{:x}", A_Index)  ; Format as a hex string with leading zero
            Hotkey, %keyName%, KeyAssign, On
        }

        sleep 200
        
        Loop, 512
        {
            keyName := Format("sc{:x}", A_Index)
            Hotkey, %keyName%, Off
        }

        if (UserInput != "")
            Break 1

        ; Check each joystick button for multiple joysticks
        Loop, %JoystickNumber%
        {
            joystickId := A_Index
            Loop, 32  ; Supports up to 32 buttons per joystick
            {
                buttonName := joystickId . "Joy" . A_Index
                if GetKeyState(buttonName, "P") {
                    UserInput := buttonName
                    GuiControl,, %A_GuiControl%, Assign Key/Button  ; Reset the button text back to "Assign"
                    break 3  ; Exit both loops
                }
            }
        }
        
        ; Break if the timeout has been reached (5 seconds)
        if (A_TickCount - inputStartTime > 5000) {
            GuiControl,, %A_GuiControl%, Assign Key/Button  ; Reset the button text back to "Assign"
            break
        }
        Sleep, 1  ; Short sleep to prevent high CPU usage
    }

    ; Process the input
 if (UserInput != "") {
    IniWrite, %UserInput%, %iniFilePath%, InputBindings, %selectedCommand%
    tabState := currentTab  ; Store current tab
    Gui, Destroy
    createKeys()
    gosub, config
    GuiControl, Choose, CurrentTab, %tabState%  ; Restore tab
    return
} else {
        MsgBox, No input was detected within 5 seconds.
    }
return
}

KeyAssign:
    scanCode := A_ThisHotkey
    keyName := GetKeyName(scanCode)  ; Get the key name from the scan code
    UserInput := keyName
return

AssignAxis() {
    static commandName
    selectedCommand := StrReplace(A_GuiControl, "_abc")
    axes_list := "X,Y,Z,R,U,V"
    startTime := A_TickCount
    initialAxisValues := {}
    GuiControl,, %A_GuiControl%, Move axis/hat

    ; Initialize axis values
    Loop, %JoystickNumber% {
        joystickId := A_Index
        Loop, Parse, axes_list, `, 
        {
            axis := joystickId . "Joy" . A_LoopField
            initialAxisValues[axis] := GetKeyState(axis)
        }
        initialPOVValue := GetKeyState(joystickId . "JoyPOV")
        initialAxisValues[joystickId . "JoyPOV"] := initialPOVValue
    }

    ; Monitor for changes
    while ((A_TickCount - startTime) < 5000) 
    {  ; 5-second timeout
        Loop, %JoystickNumber% {
            joystickId := A_Index
            ; Check axes
            Loop, Parse, axes_list, `, 
                {
                    axis := joystickId . "Joy" . A_LoopField
                    axisValue := GetKeyState(axis)
                    if (Abs(axisValue - initialAxisValues[axis]) > 30) {
                        triggerValue := (axisValue <= 30) ? 0 : 100
                        newValue := axis . "," . triggerValue
                        IniWrite, %newValue%, %iniFilePath%, InputBindings, %selectedCommand%
                        GuiControl,, %A_GuiControl%, Assign AXIS/HAT  ; Reset button text
                        tabState := currentTab  ; Store current tab
                        Gui, Destroy
                        createKeys()
                        gosub, config
                        GuiControl, Choose, CurrentTab, %tabState%  ; Restore tab
                        return
                    }
                }
                
                ; Check POV
                povValue := GetKeyState(joystickId . "JoyPOV")
                if (povValue != initialAxisValues[joystickId . "JoyPOV"] && povValue in "0,9000,18000,27000") {
                    newValue := joystickId . "JoyPOV," . povValue
                    IniWrite, %newValue%, %iniFilePath%, InputBindings, %selectedCommand%
                    GuiControl,, %A_GuiControl%, Assign AXIS/HAT  ; Reset button text
                    tabState := currentTab  ; Store current tab
                    Gui, Destroy
                    createKeys()
                    gosub, config
                    GuiControl, Choose, CurrentTab, %tabState%  ; Restore tab
                    return
                }
        }
        Sleep, 100  ; Short sleep to reduce CPU usage
    }
    MsgBox, % "Timeout reached without no joystick movement detected."
return
}

joy_check() {
    for commandName, binding in joystickBindings {
        axis := binding.axis
        triggerValue := binding.trigger

        if (InStr(axis, "POV")) {
            ; Handle POV input
            povPosition := GetKeyState(axis)
            if (povPosition = triggerValue) {
                sendjoy(commandName)
            }
        } else {
            ; Handle other joystick axis input
            axisPosition := GetKeyState(axis)
            if (axisPosition != "" && ((axisPosition >= 80 && triggerValue = 100) || (axisPosition <= 20 && triggerValue = 0))) {
                sendjoy(commandName)
            }
        }
    }
    return
}

sendjoy(commandName) {
    if (commandName != "") {
        sendString := commandMappings[commandName]
        if (sendString != "") {
            SendToXCS(sendString)
        } else {
            MsgBox, % "No command string found for: " . commandName
        }
    } else {
        MsgBox, % "Unknown hotkey: " . A_ThisHotkey
    }
}

TabChanged:
    GuiControlGet, currentTab,, CurrentTab
return