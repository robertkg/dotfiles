
[CmdletBinding()]
param (
    [Parameter()]
    [ValidatePattern(".*[Pp]rofile\.ps1")]
    [string]
    $NewProfile = "$PSScriptRoot\Profile.ps1"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $NewProfile)) {
    throw "Profile $NewProfile was not found."
}

$profileTemplate = (Get-Content -Raw -Path $NewProfile)
$winProfilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\profile.ps1"
$coreProfilePath = "$env:USERPROFILE\Documents\PowerShell\profile.ps1"

if (Test-Path -Path $winProfilePath) {
    $profileTemplate > $winProfilePath
    Write-Host "Updated $winProfilePath"
}
else {
    New-Item $winProfilePath -Value $profileTemplate -Force
    Write-Host "Created $coreProfilePath"
}

if (Test-Path -Path $coreProfilePath) {
    $profileTemplate > $coreProfilePath
    Write-Host "Updated $coreProfilePath"
}
else {
    New-Item $winProfilePath -Value $profileTemplate
    Write-Host "Created $coreProfilePath"
}