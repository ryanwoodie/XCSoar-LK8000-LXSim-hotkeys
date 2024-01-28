
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
global commandList := ["Enter", "Esc", "F1_Quick_Menu", "Up", "Down", "Left", "Right", "Zoom_Out", "Zoom_In", "Pan_Mode", "Auto_MC", "MC_Up", "MC_Down", "Task_Next", "Task_Previous", "Toggle_Mouse", "Extra_LK_Bottom_Bar_L", "Extra_LK_Bottom_Bar_R", "Extra_LK_Prev_Page", "Extra_LK_Next_Page", "Extra_LK_Top_Left", "Extra_LK_Top_Right", "Extra_LK_custom_menu_q", "Extra_LK_custom_menu_w", "Extra_LK_custom_menu_e", "Extra_LK_custom_menu_r", "Extra_LK_custom_menu_t", "Extra_LK_custom_menu_y", "Extra_LK_custom_menu_u", "Extra_LK_custom_menu_i", "Extra_LK_custom_menu_o", "Extra_LK_custom_menu_p"]

global commandMappings := {"Enter": "{Enter}", "Esc": "{Escape}", "F1_Quick_Menu": "{F1}", "Up": "{Up}", "Down": "{Down}", "Left": "{Left}", "Right": "{Right}", "Zoom_Out": "{F3}", "Zoom_In": "{F4}", "Pan_Mode": "{F2}", "Auto_MC": "{F6}", "MC_Up": "{F7}", "MC_Down": "{F8}", "Task_Next": "{F9}", "Task_Previous": "{F10}", "Toggle_Mouse": "{F13}", "Extra_LK_Bottom_Bar_L": "{a}", "Extra_LK_Bottom_Bar_R": "{s}", "Extra_LK_Prev_Page": "{d}", "Extra_LK_Next_Page": "{f}", "Extra_LK_Top_Left": "{g}", "Extra_LK_Top_Right": "{h}", "Extra_LK_custom_menu_q": "{q}", "Extra_LK_custom_menu_w": "{w}", "Extra_LK_custom_menu_e": "{e}", "Extra_LK_custom_menu_r": "{r}", "Extra_LK_custom_menu_t": "{t}", "Extra_LK_custom_menu_y": "{y}", "Extra_LK_custom_menu_u": "{u}", "Extra_LK_custom_menu_i": "{i}", "Extra_LK_custom_menu_o": "{o}", "Extra_LK_custom_menu_p": "{p}"}

global joystickBindings := {}
global hotkeyCommands := {}
global JoystickNumber = 0
global UserInput := ""

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
    ;MsgBox, Assigning keys
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


; Handles piping individual keys to XCSoar
SendToXCS(keys) {
    static toggleState := 1  ; Static variable to maintain state between function calls

    if (keys = "{F13}") {
        ; Check which program is currently not active and toggle to it
        toggleState := !toggleState  ; Toggle the state between 0 and 1

        if (toggleState = 1) {
            ; Attempt to activate CONDOR.EXE
            if WinExist("ahk_exe CONDOR.EXE") {
                WinActivate
            } else {
                ;toggleState := !toggleState  ; Revert toggleState if CONDOR.EXE does not exist
            }
        } else {
        If WinExist("ahk_exe XCsoar.exe") {
            WinActivate  ; Activates the found window
            sleep 200
            CoordMode, Mouse, Screen
            WinGetPos, X, Y, W, H, LK8000
            Horz := X + (W / 2)
            Vert := Y + (H / 2)
            DllCall("SetCursorPos", "int", Horz, "int", Vert)  ; Move cursor to the middle of the window
            return
        } else if WinExist("ahk_exe LK8000-PC.exe") {
            WinActivate  ; Activates the found window
            sleep 200
            CoordMode, Mouse, Screen
            WinGetPos, X, Y, W, H, LK8000
            Horz := X + (W / 2)
            Vert := Y + (H / 2)
            DllCall("SetCursorPos", "int", Horz, "int", Vert)  ; Move cursor to the middle of the window
            return
        }
    }
    }



    WinGet, WinID, ID, ahk_exe XCSoar.exe
    ControlGetFocus, CursorPosition, XCSoar
    if (!CursorPosition) {
        ControlSend, ahk_parent, %keys%, ahk_id %WinID%
    } else {
        ControlSend, %CursorPosition%, %keys%, ahk_id %WinID%
    }
   
   
	WinGet, WinID, ID, ahk_exe LK8000-PC.exe
  ControlGetFocus,CursorPosition, LK8000
  if not CursorPosition
  ControlSend, ahk_parent, %keys%, ahk_id %WinID%
  else
  {
	ControlSend, %CursorPosition%, %keys%, ahk_id %WinID%
}

    return
}

config:
{
    
    Gui, New
    guiYPosition := 25
    Gui, Add, Text, x10 y%guiYPosition% w400, Press and hold your key/button until it is detected. If the key (eg. F1) needs a modifier button (eg. Fn), hold the modifier before pressing the assign button below
    guiYPosition += 40  ; Adjust the position for the next element

    Gui, Add, Tab, x2 y2 h600 w800, Regular Keys|Extra Keys
    Gui, Tab, Regular Keys
    Gui,Font,bold
    Gui, Add, Text, x10 y%guiYPosition%, Function:
     Gui, Add, Text, x325 y%guiYPosition%, Current Key/Value:  ; Heading for the currentKeyValue column
    guiYPosition += 20  ; Adjust the position for the next set of elements
    Gui,Font,normal

for index, commandName in commandList {
     if (!StrContains(commandName, "Extra_")) { 
    IniRead, currentKeyValue, %iniFilePath%, InputBindings, %commandName%, None
    ;MsgBox, cmd: %commandName%
    Gui, Add, Text, x10 y%guiYPosition% w120, %commandName%
    Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignInput v%commandName%_xyz, Assign Key/Button
    ;Gui, Add, Edit, v%GuiControlVar% hidden, %commandName%
    Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignAxis v%commandName%_abc, Assign Axis/HAT
    Gui, Add, Text, x+5 y%guiYPosition% w100, %currentKeyValue%
    guiYPosition += 30
    commandName := ""
     }
}

  Gui, Tab, Extra Keys
    guiYPosition := 65  ; Reset position for Extra Keys

    Gui,Font,bold
    Gui, Add, Text, x10 y%guiYPosition%, LK8000 functions (or XCsoar extra keys):
     Gui, Add, Text, x325 y%guiYPosition%, Current Key/Value:  ; Heading for the currentKeyValue column
    guiYPosition += 20  ; Adjust the position for the next set of elements
    Gui,Font,normal

for index, commandName in commandList {
     if (StrContains(commandName, "Extra_")) {  
    IniRead, currentKeyValue, %iniFilePath%, InputBindings, %commandName%, None
    ;MsgBox, cmd: %commandName%
    Gui, Add, Text, x10 y%guiYPosition% w120, %commandName%
    Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignInput v%commandName%_xyz, Assign Key/Button
    ;Gui, Add, Edit, v%GuiControlVar% hidden, %commandName%
    Gui, Add, Button, x+5 y%guiYPosition% w100 gAssignAxis v%commandName%_abc, Assign Axis/HAT
    Gui, Add, Text, x+5 y%guiYPosition% w100, %currentKeyValue%
    guiYPosition += 30
    commandName := ""
     }
}
 
   Gui, Tab  ; End of tabs
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
        ;Tooltip %keyName%
         ;sleep 10
         Hotkey, %keyName%, KeyAssign, On
         ;Hotkey, %keyName%, Off
        }

        sleep 200
        
        Loop, 512
            {
                keyName := Format("sc{:x}", A_Index)  ; Format as a hex string with leading zero
                ;Tooltip %keyName%
                ;sleep 10
                ;Hotkey, %keyName%, KeyAssign, On
                Hotkey, %keyName%, Off
                }


        if (UserInput != "")
        Break 1

        ; Check each joystick button for multiple joysticks
        Loop, %JoystickNumber%  ; Assuming 2 joysticks, increase if you have more
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
        ;MsgBox, %selectedCommand%=%UserInput%
        Gui, Destroy
        Gosub, config
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
    ;global UserInput := scanCode
    ;Tooltip, %scanCode%,%UserInput%
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
                    IniWrite, % axis . "," . triggerValue, %iniFilePath%, InputBindings, %selectedCommand%
                    ;MsgBox, % "Axis " . axis . " changed significantly - Value saved"
                    GuiControl,, %A_GuiControl%, Assign AXIS/HAT  ; Reset the button text back to "Assign"
                    Gui, Destroy
                    Gosub, config
                    return
                }
            }
            ; Check POV
            povValue := GetKeyState(joystickId . "JoyPOV")
            if (povValue != initialAxisValues[joystickId . "JoyPOV"] && povValue in "0,9000,18000,27000") {
                IniWrite, % joystickId . "JoyPOV," . povValue, %iniFilePath%, InputBindings, %selectedCommand%
                GuiControl,, %A_GuiControl%, Assign AXIS/HAT ; Reset the button text back to "Assign"
                ;MsgBox, % "POV changed - Value saved"
                Gui, Destroy
                Gosub, config
                return
            }
        }
        Sleep, 100  ; Short sleep to reduce CPU usage
    }
    MsgBox, % "Timeout reached without no joystick movement detected."
return
}


; Assume joystickBindings is already populated as in previous examples

joy_check() {
for commandName, binding in joystickBindings {
    axis := binding.axis
    triggerValue := binding.trigger

    if (InStr(axis, "POV")) {
        ; Handle POV input
        povPosition := GetKeyState(axis)
        if (povPosition = triggerValue) {
            ; POV matches value
            ; Execute your logic for POV input here
            ;ToolTip, "POV command triggered: " %commandName% POVpos: %povPosition%
            sendjoy(commandName)
        }
    } else {
        ; Handle other joystick axis input
        axisPosition := GetKeyState(axis)
        ;one_axisPosition := GetKeyState("1JoyX")
        ;ToolTip, one_axisPosition: %one_axisPosition% axis: %axis% commandName: %commandName%  axis position: %axisPosition%
       if (axisPosition != "" && ((axisPosition >= 80 && triggerValue = 100) || (axisPosition <= 20 && triggerValue = 0))) {
            ; Axis is within the specified range
            ; Execute your logic for this axis input here
            ;ToolTip, Axis command triggered:%commandName%  pos: %axisPosition% triggerValue:%triggerValue%
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

