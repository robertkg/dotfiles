#requires -runasadministrator

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]
    $NewProfile = "$PSScriptRoot\Profile.ps1"
)

if (-not (Test-Path -Path $NewProfile)) {
    throw "Profile $NewProfile was not found."
}

$profileTemplate = (Get-Content -Raw -Path $NewProfile)
$profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Profile.ps1"

if (-not (Test-Path -Path $profile)) {
    New-Item -ItemType File -Path $profilePath -Value $profileTemplate -Force
}

Set-Content -Path $profilePath -Value $profileTemplate -Force

# Link PowerShell Core profile
New-Item -ItemType SymbolicLink -Path C:\Users\Robert\Documents\PowerShell\Profile.ps1 -Target C:\Users\Robert\Documents\WindowsPowerShell\Profile.ps1 -Force