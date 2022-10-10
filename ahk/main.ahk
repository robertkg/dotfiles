#NoEnv
#SingleInstance, Force
#Persistent

DetectHiddenWindows, On

;; Keys and symbols: https://www.autohotkey.com/docs/Tutorial.htm#s21

; =============================================================================
; AutoHotKey
; =============================================================================
; Win + F12: Reload this AutoHotKey script
#F12::
    Reload
    TrayTip, AutoHotKey, Script reloaded, 2
return

; =============================================================================
; Virtual desktop
; =============================================================================
!WheelUp::Send ^#{Left} ; alt + wheel up: Change to previous virtual desktop 
!WheelDown::Send ^#{Right} ; alt + wheel down: Change to next virtual desktop

; =============================================================================
; Windows Terminal
; =============================================================================
#t::
    Process, Exist, WindowsTerminal.exe
    If Not ErrorLevel {
        Run, wt.exe
    }
    Else {
        WinActivate, ahk_exe WindowsTerminal.exe
    }
return

; =============================================================================
; Spotify
; =============================================================================
#IfWinActive, ahk_exe Spotify.exe

    /::Send, ^l ; shift + 7: Focus search box
    Esc::Send, !{Left} ; esc: Go back

    ; =============================================================================
    ; Keypirinha
    ; =============================================================================
    ; #space::
    ;     Send, {F13}
    ; return
    ; win + r: Launch Keypirinha 
    ; hotkey_run must be set to F13 in keypirinha config
    ; #r::
    ;    Send, {F13}
    ; return