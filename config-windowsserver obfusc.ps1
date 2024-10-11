function AA {
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

function B{
    Restart-Computer -Force
}

function C{
    param(
        [array]$t
    )
    $t.length
}

function D {
    param (
        [string] $nn
    )
    Rename-Computer -NewName "$nn"
}

function E{
    param(
        [string]$nia
    )
    if ((Get-NetAdapter | Measure-Object).count -lt 2){
        Write-Host "nope"
    }
    else{
        $ndg = $nia.split(".")
        $ndg[3]=1
        $ndg = [system.String]::Join(".", $ndg)
        $ii = (Get-NetAdapter | Select-Object -First 1).ifIndex

        Remove-NetIPAddress -InterfaceIndex $ii -Confirm:$false
        Remove-NetRoute -InterfaceIndex $ii -Confirm:$false
        New-NetIPAddress -InterfaceIndex $ii -IPAddress $nia -PrefixLength 24 -DefaultGateway $ndg
        Set-DnsClientServerAddress -InterfaceIndex $ii -ServerAddresses ($nia,"8.8.8.8")
    }
}

function F{
    param (
        [string]$ns
    )
    $cert = New-SelfSignedCertificate -Subject "CN=$ns" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256
    Export-Certificate -Cert $cert -FilePath "C:\Users\admin\Desktop\$ns.cer"
}

function G{
    param (
        [string]$ns1,
        [string]$ns2,
        [string]$ns3,
        [string]$nia,
        [string]$zn
    )
    $nst = @($ns1, $ns2, $ns3)
    Install-WindowsFeature -name Web-Server -IncludeManagementTools
    for ($i=0; $i -lt 3; $i++){
        $ns = $nst[$i]
        New-Item -Path "C:\inetpub" -Name $ns -ItemType Directory
        New-Item -Path "C:\inetpub\$ns" -Name "index.html" -ItemType "file" -Value ("Hello " + $ns)
        New-IISSite -Name $ns -BindingInformation ("$nia"+":80:"+("$ns"+"."+"$zn")) -PhysicalPath "C:\inetpub\$ns"
    } 
}

function J {
    param (
        [string]$nia,
        [string]$pz,
        [string]$sz,
        [string]$zn,
        [string]$n1,
        [string]$n2,
        [string]$n3
    )
    Install-WindowsFeature -name DNS -IncludeManagementTools
    $dss = Get-DnsServerSetting -ALL
    $dss.ListeningIpAddress = @($nia)
    Set-DNSServerSetting $dss
    Add-DnsServerPrimaryZone -Name $pz -ZoneFile $zn
    Add-DnsServerResourceRecord -Name ($n1+"."+$sz) -A -ZoneName $pz -IPv4Address $nia
    Add-DnsServerResourceRecord -Name ($n2+"."+$sz) -A -ZoneName $pz -IPv4Address $nia
    Add-DnsServerResourceRecord -Name ($n3+"."+$sz) -A -ZoneName $pz -IPv4Address $nia
    Get-DnsServerDnsSecZoneSetting -ZoneName $pz
}

function I{
    $a = AA
    if ($a -eq $false){
        exit
    }else{
        [string]$rs = Read-Host "rs"
        [string]$nia = Read-Host "nia"
        [string]$nos = Read-Host "nos"
        [string]$n1 = Read-Host "n1"
        [string]$n2 = Read-Host "n2"
        [string]$n3 = Read-Host "n3"
        $tz = $nos.split(".")
        $size = C -table $tz
        [string]$pz = $tz[$size-1]
        [string]$sz = $tz[$size-2]
        [string]$zn = $nos + ".dns"
        D -newname $rs
        E -new_ip_address $nia
        G -name_site1 $n1 -name_site2 $n2 -name_site3 $n3 -new_ip_address $nia -zone_file $nos
        J -new_ip_address $nia -primary_zone $pz -secondary_zone $sz -zone_file $zn -name_1 $n1 -name_2 $n2 -name_3 $n3
    }
}

I