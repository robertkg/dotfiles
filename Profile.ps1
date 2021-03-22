# PSReadline-specific settings
Set-PSReadlineOption -BellStyle None

# Prompt

function prompt {
    # [username@machine] ~\myfolder:
    # https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
    $esc = [char]27
    $regex = [regex]::Escape($HOME) + "(\\.*)*$"
    "$ESC[32m[$(($env:USERNAME).ToLower())@$(($env:COMPUTERNAME).ToLower())]$esc[0m $($executionContext.SessionState.Path.CurrentLocation.Path -replace $regex, '~$1'): " 
}

# Functions
## Git aliases for syncing branches
function git-sync-test { git checkout test; git pull; git merge origin/qa --no-edit; git push }
function git-sync-qa { git checkout qa; git pull; git merge origin/production --no-edit; git push }
function git-sync { git checkout production; git pull; git-sync-qa; git-sync-test }
## List all certificates in local machine personal store. Format as it's a one-time use
function Get-PersonalLmCerts {
    Get-ChildItem -Path "Cert:\LocalMachine\My" |
    Format-Table Subject, Thumbprint, NotAfter -AutoSize
}


function Get-CertificateExpiry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]] $Cn,
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Runspaces.PSSession] $Session
    )

    $certificates = Invoke-Command -Session $Session -ScriptBlock {
        $certs = Get-ChildItem -Path "Cert:\LocalMachine\" -Recurse | Where-Object { $_.Subject -like "*$Using:Cn*" }
        return $certs
    }

    return ($certificates | Select-Object Thumbprint, FriendlyName, NotBefore, NotAfter -Unique | Format-Table -AutoSize -Wrap)
}

function Get-SslThumbprint {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)
        ]
        [Alias('FullName')]
        [String]$Url
    )

    Add-Type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
            public class IDontCarePolicy : ICertificatePolicy {
            public IDontCarePolicy() {}
            public bool CheckValidationResult(
                ServicePoint sPoint, X509Certificate cert,
                WebRequest wRequest, int certProb) {
                return true;
            }
        }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object IDontCarePolicy

    # Need to connect using simple GET operation for this to work
    Invoke-RestMethod -Uri $URL -Method Get | Out-Null

    $endpointRequest = [System.Net.Webrequest]::Create("$URL")
    $sslThumbprint = $endpointRequest.ServicePoint.Certificate.GetCertHashString()

    return [PSCustomObject] @{
        Thumbprint = $sslThumbprint
        Issuer     = $endpointRequest.ServicePoint.Certificate.Issuer
        Subject    = $endpointRequest.ServicePoint.Certificate.Subject   
    }
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

## Lookup aliases based on cmdlet name
function Get-AliasCmdlet ($CmdletName) {
    Get-Alias |
    Where-Object -FilterScript { $_.Definition -like $CmdletName } |
    Format-Table -Property Definition, Name -AutoSize
}

# Aliases
Set-Alias -Name "vim" -Value "C:\tools\neovim\Neovim\bin\nvim.exe"
Set-Alias -Name "vi" -Value "C:\tools\neovim\Neovim\bin\nvim.exe"
Set-Alias -Name "which" -Value Get-Command
Set-Alias -Name "touch" -Value New-Item
Set-Alias -Name "grep" -Value Select-String
Set-Alias -Name "im" -Value Import-Module
Set-Alias -Name "certlm" -Value Get-PersonalLmCerts
Set-Alias -Name "esn" -Value Enter-PSSession
Set-Alias -Name "ls" -Value Get-ChildItemColor -Option AllScope -Force
Set-Alias -Name "dir" -Value Get-ChildItemColor -Option AllScope -Force

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
Set-PSReadLineKeyHandler -Key Ctrl+Alt+c -BriefDescription "OpenInVSCode" -ScriptBlock {
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
