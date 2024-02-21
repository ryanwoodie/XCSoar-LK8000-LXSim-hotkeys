#InstallKeybdHook
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn   ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode, 2
DetectHiddenWindows, On

; Check every 100 milliseconds
SetTimer, CheckHatSwitch, 100
return

CheckHatSwitch:
    hat := GetKeyState("JoyPOV") ; Get the state of the HAT switch
    modifierPressed := GetKeyState("Joy1", "P") ; Check if the modifier button (Joy1) is pressed

    if (modifierPressed)
    {
        if (hat = 0) ; Up
        {
            SendToXCS("{F4}") ; Zoom In
        }
        else if (hat = 9000) ; Right
        {
            SendToXCS("{F9}") ; Task Next
        }
        else if (hat = 18000) ; Down
        {
            SendToXCS("{F3}") ; Zoom Out
        }
        else if (hat = 27000) ; Left
        {
            SendToXCS("{F10}") ; Task Previous
        }
        ; Additional directions/actions can be added here
    }
    else
    {
        if (hat = 0) ; Up
        {
            SendToXCS("{Up}")
        }
        else if (hat = 9000) ; Right
        {
            SendToXCS("{Right}")
        }
        else if (hat = 18000) ; Down
        {
            SendToXCS("{Down}")
        }
        else if (hat = 27000) ; Left
        {
            SendToXCS("{Left}")
        }
        ; Additional directions/actions can be added here
    }
return

#SingleInstance force
WinSet, Style, -0xC00000, XCSoar

Enter::SendToXCS("{Enter}")
Esc::SendToXCS("{Escape}")
Del::SendToXCS("{F1}") ; Quick Menu

; Main top-level cursor behaviors

; Pan On and Zoom
NumpadSub::SendToXCS("{F3}") ; Zoom Out
NumpadAdd::SendToXCS("{F4}") ; Zoom In
0::SendToXCS("{F2}") ; Pan Mode

; MacCready controls
5::SendToXCS("{F6}") ; Auto MC
8::SendToXCS("{F7}") ; MC Up
2::SendToXCS("{F8}") ; MC Down

; Task next and previous arm
6::SendToXCS("{F9}") ; Task Next
4::SendToXCS("{F10}") ; Task Previous

; Handles piping individual keys to XCSoar
SendToXCS(k)
{
    WinGet, WinID, ID, XCSoar
    ControlGetFocus, CursorPosition, XCSoar
    if not CursorPosition
        ControlSend, ahk_parent, %k%, ahk_id %WinID%
    else
    {
        ControlSend, %CursorPosition%, %k%, ahk_id %WinID%
    }

    WinGet, WinID, ID, LK8000
    ControlGetFocus, CursorPosition, LK8000
    if not CursorPosition
        ControlSend, ahk_parent, %k%, ahk_id %WinID%
    else
    {
        ControlSend, %CursorPosition%, %k%, ahk_id %WinID%
    }

    return
}
