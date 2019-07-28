$File = Import-Csv -Path ".\WSC2019_TP39_Module_B_Users.csv"
## Space should be there for property "Organizational Unit"
$File |Select-Object| Sort-Object -Property "Organizational Unit" -Unique|Select-Object 'Organizational Unit'|ForEach-Object {
    New-ADOrganizationalUnit $_.'Organizational Unit'
}
## You have to Define Group Scope Universal | Domail Local | Global
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
    -HomeDirectory '\\dc2\Homes\%username%' `
    -HomeDrive 'H:\' `
    -PasswordNeverExpires $true `
    -Path ("ou="+$_."organizational unit"+",dc=wsc2019,dc=ru")  `
    -SamAccountName $_.ID `
    -Surname $_.Surname
}

