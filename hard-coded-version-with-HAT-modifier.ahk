#InstallKeybdHook
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn   ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode, 2
DetectHiddenWindows, On

; Hat profiles are evaluated in order: modifier-specific sections first, then the no-modifier fallback.
; Adjust modifiers/mappings below to match your hardware layout.
hatSections := []
hatSections.Push({modifier: "Joy1", mapping: {0: "{F4}", 9000: "{F9}", 18000: "{F3}", 27000: "{F10}"}}) ; Zoom/Task when Joy1 held
hatSections.Push({modifier: "Joy2", mapping: {0: "{d}", 9000: "{s}", 18000: "{f}", 27000: "{a}"}}) ; LK8000 data/nav when Joy2 held
hatSections.Push({modifier: "", mapping: {0: "{Up}", 9000: "{Right}", 18000: "{Down}", 27000: "{Left}"}}) ; Default POV behavior

; Check every 100 milliseconds
SetTimer, CheckHatSwitch, 100
return

CheckHatSwitch:
    hat := GetKeyState("JoyPOV")
    if (hat = -1)
        return
    ProcessHat(hat)
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

; Toggle between XC/LK and Condor to use mouse
7::SendToXCS("{F10}")

; Direct arrow keys (in addition to hat default)
Up::SendToXCS("{Up}")
Down::SendToXCS("{Down}")
Left::SendToXCS("{Left}")
Right::SendToXCS("{Right}")

; Example of requiring two buttons together
Joy1::
Joy2::
    if GetKeyState("Joy1", "P") and GetKeyState("Joy2", "P") {
        SendToXCS("{Up}")
    }
return

; LK8000 extras (mirrors dynamic script outputs)
a::SendToXCS("{a}") ; Bottom bar left
s::SendToXCS("{s}") ; Bottom bar right
d::SendToXCS("{d}") ; Prev page
f::SendToXCS("{f}") ; Next page
g::SendToXCS("{g}") ; Top-left button
h::SendToXCS("{h}") ; Top-right button

q::SendToXCS("{q}") ; Custom menu q
w::SendToXCS("{w}") ; Custom menu w
e::SendToXCS("{e}") ; Custom menu e
r::SendToXCS("{r}") ; Custom menu r
t::SendToXCS("{t}") ; Custom menu t
y::SendToXCS("{y}") ; Custom menu y
u::SendToXCS("{u}") ; Custom menu u
i::SendToXCS("{i}") ; Custom menu i
o::SendToXCS("{o}") ; Custom menu o
p::SendToXCS("{p}") ; Custom menu p

ProcessHat(hatValue) {
    global hatSections

    ; First pass: modifier-specific mappings
    for index, section in hatSections {
        if (section.modifier != "" && GetKeyState(section.modifier, "P")) {
            SendHatMapping(hatValue, section.mapping)
            return
        }
    }

    ; Fallback: no-modifier mapping
    for index, section in hatSections {
        if (section.modifier = "") {
            SendHatMapping(hatValue, section.mapping)
            return
        }
    }
}

SendHatMapping(hatValue, mapping) {
    if (mapping.HasKey(hatValue)) {
        SendToXCS(mapping[hatValue])
    }
}

; Handles piping individual keys to XCSoar
SendToXCS(keys)
{
    static toggleState := 1  ; Static variable to maintain state between function calls

    if (keys = "{F10}" && (A_ThisHotkey = "7" || A_ThisHotkey = "Numpad7")) {
        toggleState := !toggleState

        if (toggleState = 1) {
            if WinExist("ahk_exe CONDOR.EXE") {
                WinActivate
            }
        } else {
            if WinExist("ahk_exe XCsoar.exe") {
                WinActivate
                sleep 200
                CoordMode, Mouse, Screen
                WinGetPos, X, Y, W, H, XCSoar
                Horz := X + (W / 2)
                Vert := Y + (H / 2)
                DllCall("SetCursorPos", "int", Horz, "int", Vert)
                return
            } else if WinExist("ahk_exe LK8000-PC.exe") {
                WinActivate
                sleep 200
                CoordMode, Mouse, Screen
                WinGetPos, X, Y, W, H, LK8000
                Horz := X + (W / 2)
                Vert := Y + (H / 2)
                DllCall("SetCursorPos", "int", Horz, "int", Vert)
                return
            }
        }
    }

    WinGet, WinID, ID, XCSoar
    ControlGetFocus, CursorPosition, XCSoar
    if not CursorPosition
        ControlSend, ahk_parent, %keys%, ahk_id %WinID%
    else
    {
        ControlSend, %CursorPosition%, %keys%, ahk_id %WinID%
    }

    WinGet, WinID, ID, LK8000
    ControlGetFocus, CursorPosition, LK8000
    if not CursorPosition
        ControlSend, ahk_parent, %keys%, ahk_id %WinID%
    else
    {
        ControlSend, %CursorPosition%, %keys%, ahk_id %WinID%
    }

    return
}
