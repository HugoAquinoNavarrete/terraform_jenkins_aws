<powershell>

$url = "https://raw.githubusercontent.com/jborean93/ansible-windows/master/scripts/Upgrade-PowerShell.ps1"
$file = "$env:temp\Upgrade-PowerShell.ps1"
$username = "ansible"
$password = "${password}"
$group = "Administrators"

# Creating new local user
& NET USER $username $password /add /y /expires:never
# Adding local user to group
& NET LOCALGROUP $group $username /add
# Ensuring password never expires
& WMIC USERACCOUNT WHERE "Name='$username'" SET PasswordExpires=FALSE

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
&$file -Version 5.1 -Username $username -Password $password -Verbose
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file
winrm enumerate winrm/config/Listener
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

</powershell>
<persist>true</persist>
