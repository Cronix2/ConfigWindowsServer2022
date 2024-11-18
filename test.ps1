
$DomainName = "eval-ASI.local"
$SharedFolderPath = "\\EVAL-ASI-WIN\Cours CSI"
$DriveLetter = "P:"

$scriptContent = "net use $DriveLetter $SharedFolderPath /persistent:yes"

New-Item -Path $ScriptPath -ItemType File -Force
Set-Content -Path $ScriptPath -Value $scriptContent
Write-Host "Script de mappage créé : $ScriptPath."

Set-GPRegistryValue -Name $GPOName -Key "Software\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon" -ValueName "0" -Type String -Value $ScriptPath
Write-Host "Script ajouté à la GPO."

$Domain = Get-ADDomain -Identity $DomainName
New-GPLink -Name $GPOName -Target "LDAP://$($Domain.DistinguishedName)"
Write-Host "GPO '$GPOName' liée au domaine."

gpupdate /force
Write-Host "Mise à jour des stratégies de groupe forcée sur les clients."

Write-Host "Le mappage de lecteur réseau est désormais configuré via la GPO '$GPOName'."
