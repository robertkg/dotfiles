[CmdletBinding(SupportsShouldProcess)]
param (
    $NewProfile = (Get-Content -Raw -Path "$PSScriptRoot\Microsoft.PowerShell_profile.ps1")
)

if ($PSCmdlet.ShouldProcess($profile, "Update profile for current user $(whoami) with $($NewProfile.PSPath)")) {
    if (-not (Test-Path -Path $profile)) {
        New-Item -ItemType File -Path $profile -Value $NewProfile -Force
    }
    else {
        Set-Content -Path $profile -Value $NewProfile -Force
    }
}

