param(
[string]$filepath
)

$File = Import-Csv -Path $filepath
## Space should be there for property "Organizational Unit"
$File |Select-Object| Sort-Object -Property "Organizational Unit" -Unique|Select-Object 'Organizational Unit'|ForEach-Object {
    New-ADOrganizationalUnit $_.'Organizational Unit'
}
## You have to Define Group Scope Universal | Domail Local | Universal
$File|Select-Object|Sort-Object 'Group' -Unique|Select-Object 'Group'|ForEach-Object {
    New-ADGroup $_.Group -GroupScope Global
}

$File|ForEach-Object {
    New-ADUser `
    -Name ($_.'Given Name'+' '+$_.Surname) `
    -AccountPassword (ConvertTo-SecureString $_.Password -AsPlainText -Force) `
    -City $_.City `
    -Company $_.Company `
    -OtherAttributes @{co=$_.Country}`
    -DisplayName ($_.'Given Name'+' '+$_.Surname) `
    -EmailAddress $_.'E-Mail' `
    -Enabled $true `
    -GivenName $_.'Given Name' `
    -HomeDirectory '\\DC2012\Home\%username%' `
    -HomeDrive 'H:\' `
    -PasswordNeverExpires $true `
    -Path ("ou="+$_."organizational unit"+",dc=test,dc=local") `
    -SamAccountName $_.ID `
    -Surname $_.Surname
}

