function A{
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

function B{
    param (
        [string] $nn
    )
    Rename-Computer -NewName "$nn" #-Restart
}

function C{
    param(
        [string]$niaf
    )
    if ((Get-NetAdapter | Measure-Object).count -lt 2){
        Write-Host "nope"
    }
    else{
        $ndg = $niaf.split(".")
        $ndg[3]=1
        $ndg = [system.String]::Join(".", $ndg)
        $iif = (Get-NetAdapter | Select-Object -First 1).ifIndex

        Remove-NetIPAddress -InterfaceIndex $iif -Confirm:$false
        Remove-NetRoute -InterfaceIndex $iif -Confirm:$false
        New-NetIPAddress -InterfaceIndex $iif -IPAddress $niaf -PrefixLength 24 -DefaultGateway $ndg
        Set-DnsClientServerAddress -InterfaceIndex $iif -ServerAddresses ($niaf,"8.8.8.8")
    }
}

function D{
    param (
    )
    Install-WindowsFeature -name Web-Server -IncludeManagementTools
    
}

function E{
    param (
        [string]$niaf,
        [string]$pz,
        [string]$sz,
        [string]$zf
    )
    Install-WindowsFeature -name DNS -IncludeManagementTools
    $dss = Get-DnsServerSetting -ALL
    $dss.ListeningIpAddress = @($niaf)
    Set-DNSServerSetting $dss
    Add-DnsServerPrimaryZone -Name $pz -ZoneFile $zf
}

function F{
    Restart-Computer -Force
}

function G{
    param(
        [array]$t
    )
    $t.length
}

# ____________________________________________________
function _main_{
    [string]$rs = Read-Host "rs"
    [string]$nia = Read-Host "nia"
    [string]$nos = Read-Host "nos"
    $tz = $nos.split(".")
    $s = G -t $tz
    [string]$pz = $tz[$s-1]
    [string]$sz = $tz[$s-2]
    [string]$zf = $nos + ".dns"
    B -nn $rs
    C -niaf $nia
    D
    E -niaf $nia -pz $pz -sz $sz -zf $zf
}

_main_