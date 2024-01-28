#InstallKeybdHook
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn   ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode, 2
DetectHiddenWindows, On

#SingleInstance force
WinSet, Style, -0xC00000, XCSoar

Enter::SendToXCS("{Enter}")
Esc::SendToXCS("{Escape}")
Del::SendToXCS("{F1}") ; XCsoar mega menu

;example of needing two buttons pressed together.

Joy1::
Joy2::
    if GetKeyState("Joy1", "P") and GetKeyState("Joy2", "P") {
        SendToXCS("{Up})
    }
return


Up::SendToXCS("{Up}")
Down::SendToXCS("{Down}")
Left::SendToXCS("{Left}")
Right::SendToXCS("{Right}")

; Updated keys based on your new mappings
NumpadSub::SendToXCS("{F3}") ; Zoom Out
NumpadAdd::SendToXCS("{F4}") ; Zoom In
0::SendToXCS("{F2}") ; Pan Mode

5::SendToXCS("{F6}") ; Auto MC
8::SendToXCS("{F7}") ; MC Up
2::SendToXCS("{F8}") ; MC Down

6::SendToXCS("{F9}") ; Task Next
4::SendToXCS("{F10}") ; Task Previous
7::SendToXCS("{F10}") ; Toggle between XC/LK and Condor to use mouse

; Handles piping individual keys to XCSoar
SendToXCS(k)
{

  static toggleState := 1  ; Static variable to maintain state between function calls

    if (keys = "{F10}") {
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
    ControlGetFocus,CursorPosition, XCSoar
    if not CursorPosition
    ControlSend, ahk_parent, %k%, ahk_id %WinID%
    else
    {
    ControlSend, %CursorPosition%, %k%, ahk_id %WinID%
    }

    WinGet, WinID, ID, LK8000
    ControlGetFocus,CursorPosition, ahk_exe LK8000-PC.exe
    if not CursorPosition
    ControlSend, ahk_parent, %k%, ahk_id %WinID%
    else
    {
    ControlSend, %CursorPosition%, %k%, ahk_id %WinID%
    }

	return
}
