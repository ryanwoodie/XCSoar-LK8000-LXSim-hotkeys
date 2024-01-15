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


; Main top-level cursor behaviors
Up::SendToXCS("{Up}")
Down::SendToXCS("{Down}")
Left::SendToXCS("{Left}")
Right::SendToXCS("{Right}")

; Pan On and Zoom
NumpadSub::SendToXCS("{F13}") ; Zoom Out
NumpadAdd::SendToXCS("{F14}") ; Zoom In
0::SendToXCS("{F15}") ; Pan Mode

; MacCready controls
5::SendToXCS("{F16}") ; Auto MC
8::SendToXCS("{F17}") ; MC Up
2::SendToXCS("{F18}") ; MC Down

; Task next and previous arm
6::SendToXCS("{F19}") ; Task Next
4::SendToXCS("{F20}") ; Task Previous

; Handles piping individual keys to XCSoar
SendToXCS(k)
{
	WinGet, WinID, ID, XCSoar
    ControlGetFocus,CursorPosition, XCSoar
    if not CursorPosition
    ControlSend, ahk_parent, %k%, ahk_id %WinID%
    else
    {
    ControlSend, %CursorPosition%, %k%, ahk_id %WinID%
    }

    WinGet, WinID, ID, LK8000
    ControlGetFocus,CursorPosition, LK8000
    if not CursorPosition
    ControlSend, ahk_parent, %k%, ahk_id %WinID%
    else
    {
    ControlSend, %CursorPosition%, %k%, ahk_id %WinID%
    }

	return
}
