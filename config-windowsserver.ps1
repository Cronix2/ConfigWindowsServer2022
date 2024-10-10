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
    )
    Install-WindowsFeature -name Web-Server -IncludeManagementTools
    
}

function Download_and_install_DNS{
    param (
        [string]$new_ip_address
    )
    Install-WindowsFeature -name DNS -IncludeManagementTools
    $DnsServerSettings = Get-DnsServerSetting -ALL
    $DnsServerSettings.ListeningIpAddress = @($new_ip_address)
    Set-DNSServerSetting $DnsServerSettings
}

# ____________________________________________________
function _main_{
    [string]$rs = Read-Host "Entrez le nom que vous voulez donnez a votre machine"
    [string]$nia = Read-Host "Entrez l'adresse IP que vous voulez donnez a votre machine"
    Rename_your_Server -newname $rs
    Change_to_static_IP -new_ip_address $nia
    Download_and_install_IIS
    Download_and_install_DNS -new_ip_address $nia
}

_main_