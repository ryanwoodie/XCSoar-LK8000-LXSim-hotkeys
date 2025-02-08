#Persistent
SetTimer, CheckJoystickButtons, 400
return

CheckJoystickButtons:
    ToolTip  ; Clear previous tooltip to avoid overlap
    
    ; Loop through all possible joysticks (up to 16)
    Loop, 32
    {
        joystickId := A_Index
        GetKeyState, JoyName, %joystickId%JoyName
        
        ; If the joystick exists
        if (JoyName != "")
        {
            ; Check up to 128 buttons per joystick
            Loop, 128
            {
                buttonName := joystickId . "Joy" . A_Index
                if GetKeyState(buttonName, "P")  ; Button pressed
                {
                    ToolTip, Joystick %joystickId% - Button %A_Index% Pressed
                    Sleep, 200  ; Debounce to avoid spam
                }
            }
        }
    }
return
