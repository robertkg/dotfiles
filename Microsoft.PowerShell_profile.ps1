# Modules
Import-Module -Name PSReadline

# PSReadline-specific settings
Set-PSReadlineOption -BellStyle None

# Functions
## Remove PS prefix in terminal and set home dir prompt to ~
function global:prompt {
    # https://stackoverflow.com/questions/39186373/how-can-i-use-tilde-in-the-powershell-prompt
    $regex = [regex]::Escape($HOME) + "(\\.*)*$"
    "$($executionContext.SessionState.Path.CurrentLocation.Path -replace $regex, '~$1')$('>' * ($nestedPromptLevel + 1)) "
}

## List all certificates in local machine personal store. Format as it's a one-time use
function Get-PersonalLmCerts {
    Get-ChildItem -Path "Cert:\LocalMachine\My" |
    Format-Table Subject, Thumbprint, NotAfter -AutoSize
}

## Update current user's PS profile with a given profile file
function Update-PsProfile {
    [Cmdletbinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [string]
        $ProfileTemplate = "C:\Git\ps-profile\Microsoft.PowerShell_profile.ps1"
    )

    if (-not (Test-Path $ProfileTemplate)) {
        throw "Profile template $ProfileTemplate was not found."
    }

    $newProfile = (Get-Content -Raw -Path $ProfileTemplate -ErrorAction Stop)

    if ($PSCmdlet.ShouldProcess($profile, "Updating profile for $(whoami) with profile $ProfileTemplate")) {
        Set-Content -Path $profile -Value $newProfile -Force
    }
}

## Launch/open a new tab of Firefox 32/64, depending on which version is installed
function Start-Firefox ($params) {
    $32bitDir = "C:\Program Files\Mozilla Firefox\firefox.exe"
    $64bitDir = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"

    if (Test-Path -Path $32bitDir) {
        Start-Process $32bitDir $params
    }
    elseif (Test-Path -Path $64bitDir) {
        Start-Process $64bitDir $params
    }
    else {
        Write-Warning -Message "No Firefox installation found. Opening in default web browser..."
        Start-Process $params
    }
}

## Lookup aliases based on cmdlet name
function Get-AliasCmdlet ($CmdletName) {
    Get-Alias |
    Where-Object -FilterScript { $_.Definition -like $CmdletName } |
    Format-Table -Property Definition, Name -AutoSize
}

# Aliases
Set-Alias -Name "touch" -Value New-Item
Set-Alias -Name "grep" -Value Select-String
Set-Alias -Name "im" -Value Import-Module
Set-Alias -Name "certlm" -Value Get-PersonalLmCerts
Set-Alias -Name "ff" -Value Start-Firefox
Set-Alias -Name "firefox" -Value Start-Firefox
Set-Alias -Name "eps" -Value Enter-PSSession

# PSReadline key handlers
## Resolve the full path of the given relative path
## Source: https://github.com/psconfeu/2019/blob/master/sessions/Anthony%20Allen/PSReadline/PSReadline.zip
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+p' -Description "Resolves full path of the given relative path" -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    $tokens = $null
    $ast = $null
    $parseErrors = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)


    foreach ($token in $tokens) {
        $extent = $token.Extent
        if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor) {
            $tokenToChange = $token
            break
        }
    }

    if ($null -ne $tokenToChange) {
        $extent = $tokenToChange.Extent
        $tokenText = $extent.Text

        $pathValue = $tokenToChange.Value
        $resolvedPath = Resolve-Path -Path $pathValue -ErrorAction SilentlyContinue
        if ($resolvedPath) {
            $replacementText = $extent.Text.Replace($pathValue, $resolvedPath.Path)
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                $extent.StartOffset,
                $tokenText.Length,
                $replacementText)
        }
    }
}

## Open current directory in VS Code
## Source: https://github.com/psconfeu/2019/blob/master/sessions/Anthony%20Allen/PSReadline/PSReadline.zip
Set-PSReadLineKeyHandler -Key Ctrl+Alt+c -BriefDescription "OpenInCodeInsiders" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("code .")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

## Format code on the command line
## Source: https://github.com/psconfeu/2019/blob/master/sessions/Anthony%20Allen/PSReadline/PSReadline.zip
Set-PSReadLineKeyHandler Ctrl+Alt+f -ScriptBlock {

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)


    $fmt = Invoke-Formatter -ScriptDefinition $line -Settings 'CodeFormattingStroustrup'
    $fmt = $fmt -replace "\r", ""
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.length, $fmt)
}