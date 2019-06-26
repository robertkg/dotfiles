
Describe "Import-Profile" {
    It "throws an error when $NewProfile is empty" {
        C:\Git\ps-profile\Import-Profile.ps1 -NewProfile "" | Should Throw "Profile $NewProfile was not found."
    }
}