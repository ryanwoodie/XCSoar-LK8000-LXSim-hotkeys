o::
{
    SetMouseDelay, -1
    
    ; Send Alt-Tab twice to focus the game
    Send, {Alt Down}{Tab}{Alt Up}
    Sleep, 200  ; Wait for window focus
    if WinExist("ahk_exe CONDOR.EXE") {
        WinActivate
    }
    WinWaitActive, ahk_exe CONDOR.EXE,, 5
    if ErrorLevel
        Send, {Alt Down}{Tab}{Alt Up}
    
    ; Send Esc to bring up menu
    Send, {Esc}
    Sleep, 100  ; Wait for menu
    
    ; Mouse will be at 900,540 after game focus
    ; Need to move up 240px
    DllCall("mouse_event", "UInt", 0x0001, "Int", 0, "Int", -240, "UInt", 0, "UInt", 0)
    Sleep, 50
    
    ; Send left mouse button down and up
    DllCall("mouse_event", "UInt", 0x0002, "Int", 0, "Int", 0, "UInt", 0, "UInt", 0)  ; Left down
    Sleep, 50
    DllCall("mouse_event", "UInt", 0x0004, "Int", 0, "Int", 0, "UInt", 0, "UInt", 0)  ; Left up
    
    return
}

l:: ;assign hotkey to exit Condor Flight
{
    SetMouseDelay, -1
    
    ; Send Alt-Tab twice to focus the game
    Send, {Alt Down}{Tab}{Alt Up}
    Sleep, 200  ; Wait for window focus
    if WinExist("ahk_exe CONDOR.EXE") {
        WinActivate
    }
    WinWaitActive, ahk_exe CONDOR.EXE,, 5
    if ErrorLevel
        Send, {Alt Down}{Tab}{Alt Up}
    
    ; Send Esc to bring up menu
    Send, {Esc}
    Sleep, 100  ; Wait for menu
    
    ; Mouse will be at 900,540 after game focus
    ; Need to move up 240px
    DllCall("mouse_event", "UInt", 0x0001, "Int", 0, "Int", -200, "UInt", 0, "UInt", 0)
    Sleep, 50
    
    ; Send left mouse button down and up
    DllCall("mouse_event", "UInt", 0x0002, "Int", 0, "Int", 0, "UInt", 0, "UInt", 0)  ; Left down
    Sleep, 50 
    DllCall("mouse_event", "UInt", 0x0004, "Int", 0, "Int", 0, "UInt", 0, "UInt", 0)  ; Left up
    
    Sleep, 100  ; Wait for menu
    
    ; Mouse will be at 900,540 after game focus
    ; Need to move up 240px
    DllCall("mouse_event", "UInt", 0x0001, "Int", -40, "Int", -40, "UInt", 0, "UInt", 0)
    Sleep, 50
    
    ; Send left mouse button down and up
    DllCall("mouse_event", "UInt", 0x0002, "Int", 0, "Int", 0, "UInt", 0, "UInt", 0)  ; Left down
    Sleep, 50
    DllCall("mouse_event", "UInt", 0x0004, "Int", 0, "Int", 0, "UInt", 0, "UInt", 0)  ; Left up
    
    return
}