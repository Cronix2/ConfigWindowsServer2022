#Use this fonction to know if your are administrator on your computer, it's a boolean exit
function AsAdministrator{
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

#Use this fonction to rename your computer
function Rename_your_Server{
    param (
        [string] $newname
    )
    Rename-Computer -NewName "$newname" #-Restart
}

#Use this function to change your adress IP 
function Change_to_static_IP{
    param(
        [string]$new_ip_address
    )
    if ((Get-NetAdapter | Measure-Object).count -lt 2){
        Write-Host "vous n'avez pas assez d'interface reseau, par consequent nous n'avons pas change votre addresse IP"
    }
    else{
        $new_default_gateway = $new_ip_address.split(".")
        $new_default_gateway[3]=1
        $new_default_gateway = [system.String]::Join(".", $new_default_gateway)
        $index_interface = (Get-NetAdapter | Select-Object -First 1).ifIndex

        #Write-Host "$new_default_gateway `n$new_ip_address"
        Remove-NetIPAddress -InterfaceIndex $index_interface -Confirm:$false
        Remove-NetRoute -InterfaceIndex $index_interface -Confirm:$false
        New-NetIPAddress -InterfaceIndex $index_interface -IPAddress $new_ip_address -PrefixLength 24 -DefaultGateway $new_default_gateway
        Set-DnsClientServerAddress -InterfaceIndex $index_interface -ServerAddresses ($new_ip_address,"8.8.8.8")
    }
}

function Download_and_install_IIS{
    param (
        [string]$name_site1,
        [string]$name_site2,
        [string]$name_site3
    )
    $name_site_table = @($name_site1, $name_site2, $name_site3)
    Install-WindowsFeature -name Web-Server -IncludeManagementTools
    for ($i=0; $i -lt 3; $i++){
        $name_site = $name_site_table[$i]
        New-Item -Path "C:\" -Name $name_site -ItemType Directory
        New-Item -Path ("C:\"+"$name_site") -Name "index.html" -ItemType "file" -Value ("Hello " + $name_site)
        New-IISSite -Name $name_site -BindingInformation "*:80" -PhysicalPath "$env:systemdrive\inetpub\testsite"
    }    
}

function Download_and_install_DNS{
    param (
        [string]$new_ip_address,
        [string]$primary_zone,
        [string]$secondary_zone,
        [string]$zone_file,
        [string]$name_1,
        [string]$name_2,
        [string]$name_3
    )
    Install-WindowsFeature -name DNS -IncludeManagementTools
    $DnsServerSettings = Get-DnsServerSetting -ALL
    $DnsServerSettings.ListeningIpAddress = @($new_ip_address)
    Set-DNSServerSetting $DnsServerSettings
    Add-DnsServerPrimaryZone -Name $primary_zone -ZoneFile $zone_file
    Add-DnsServerResourceRecordA -Name $name_1 -ZoneName $primary_zone -IPv4Address $new_ip_address
    Add-DnsServerRessourceRecordA -Name $name_2 -ZoneName $primary_zone -IPv4Address $new_ip_address
    Add-DnsServerRessourceRecordA -Name $name_3 -ZoneName $primary_zone -IPv4Address $new_ip_address
}

function Restart_Server{
    Restart-Computer -Force
}

function Size_of_the_table{
    param(
        [array]$table
    )
    $table.length
}

# ____________________________________________________
function _main_{
    [string]$rs = Read-Host "Entrez le nom que vous voulez donnez a votre machine"
    [string]$nia = Read-Host "Entrez l'adresse IP que vous voulez donnez a votre machine"
    [string]$nos = Read-Host "Entrez le nom de votre zone DNS exemple pour user.contoso.com ça sera contoso.com"
    [string]$name_1 = Read-Host "Entrez le nom de votre premier site"
    [string]$name_2 = Read-Host "Entrez le nom de votre deuxieme site"
    [string]$name_3 = Read-Host "Entrez le nom de votre troisieme site"
    $table_zone = $nos.split(".")
    $size = Size_of_the_table -table $table_zone
    [string]$primary_zone = $table_zone[$size-1]
    [string]$secondary_zone = $table_zone[$size-2]
    [string]$zone_file = $nos + ".dns"
    #Rename_your_Server -newname $rs
    #Change_to_static_IP -new_ip_address $nia
    Download_and_install_IIS -name_site1 $name_1 -name_site2 $name_2 -name_site3 $name_3
    #Download_and_install_DNS -new_ip_address $nia -primary_zone $primary_zone -secondary_zone $secondary_zone -zone_file $zone_file
}

_main_