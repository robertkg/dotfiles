#NoEnv
#SingleInstance, Force
#Persistent

DetectHiddenWindows, On

;; win+r: launch keypirinha
;; hotkey_run must be set to F13 in keypirinha config
#r::
  Send, {F13}
return

#space::
  Send, {F13}
return

#F12::Reload

;; win+t: launch terminal
#t::
  if FileExist("C:\Program Files\ConEmu\ConEmu64.exe") {
    Run, "C:\Program Files\ConEmu\ConEmu64.exe" -icon "C:\Program Files\ConEmu\microsoft-terminal.ico" -NoUpdate
  }
  else if FileExist("C:\Program Files\PowerShell\7\pwsh.exe") {
    Run, "C:\Program Files\PowerShell\7\pwsh.exe" -nologo
  } else {
    Run, "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -nologo
  }
return
