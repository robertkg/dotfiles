#requires -runasadministrator

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
$profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Profile.ps1"

Write-Verbose "Importing profile `n`t- From: $NewProfile`n`t- To: $profilePath"

if (-not (Test-Path -Path $profilePath)) {
    Write-Verbose "Path $profilePath not found. Creating it..."
    New-Item -ItemType File -Path $profilePath -Value $profileTemplate
}

Set-Content -Path $profilePath -Value $profileTemplate

# Link PowerShell Core profile
if (Test-Path $env:USERPROFILE\Documents\PowerShell) {
    Write-Verbose "Found path $env:USERPROFILE\Documents\PowerShell"
    $coreProfilePath = "$env:USERPROFILE\Documents\PowerShell\Profile.ps1"
    Write-Verbose "Creating symlink with Windows PowerShell profile.`n`t- From: $coreProfilePath`n`t- To: $profilePath"
    New-Item -ItemType SymbolicLink -Path $coreProfilePath -Target $profilePath -Force 1> $null
}

Write-Output "Profile imported to '$profilePath'."

