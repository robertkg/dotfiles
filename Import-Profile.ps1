[CmdletBinding(SupportsShouldProcess)]
param (
    $NewProfile = "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"
)

if (-not (Test-Path -Path $NewProfile)) {
    throw "Profile $NewProfile was not found."
}

$profileTemplate = (Get-Content -Raw -Path $NewProfile)

if ($PSCmdlet.ShouldProcess($profile, "Update profile for current user $(whoami) with $($NewProfile.PSPath)")) {
    if (-not (Test-Path -Path $profile)) {
        New-Item -ItemType File -Path $profile -Value $profileTemplate -Force
    }
    else {
        Set-Content -Path $profile -Value $profileTemplate -Force
    }
}

