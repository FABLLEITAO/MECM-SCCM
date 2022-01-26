
$ErrorActionPreference= 'silentlycontinue'
$saida = 'C:\Windows\CNX\' + $env:computername + '.log'
 
Get-Date |Out-File $saida
' '|Out-File $saida -Append
'################################################################################################################################'|Out-File $saida -Append
'Concentrix - Technical support - Verify and Restore Network Connection'|Out-File $saida -Append
'################################################################################################################################'|Out-File $saida -Append
'Developed by ITBR Ops'|Out-File $saida -Append
'################################################################################################################################'|Out-File $saida -Append
' '|Out-File $saida -Append

#Summary Script----------------------------------------------------------------------------------------------------------------------------------------------

'Network and security devices summary:' | Out-File $saida -Append
' '|Out-File $saida -Append
 
#DNS Check----------------------------------------------------------------------------------------------------------------------------------------------
$zona = nslookup $env:computername mz-vv-dc-001
 
$X = 0
foreach ($line in $zona) {
    $fields = $line -split '\s+'
    $ip = $fields[-1]
    $X = $x + 1
    if($x -eq 5){$ipZona = $ip} 
}
 
#--------------------------------------------
 
$ipreversa = nslookup $ipZona mz-vv-dc-001
 
$X = 0
foreach ($line in $zona) {
    $fields = $line -split '\s+'
    $ip = $fields[-1]
    $X = $x + 1
    if($x -eq 5){$ipreversa = $ip} 
}
 
#-----------------------------------------
$h = $env:computername
if($ipreversa -eq $ipZona){'Clean DNS' |Out-File $saida -Append} 
else {'The host ' + $h +' is dirty in DNS: Zone - ' + $ipZona + ' / Reverse: ' + $ipreversa | Out-File $saida -Append}
 
#SCCM check----------------------------------------------------------------------------------------------------------------------------------------------
 
 
if (Get-Process | Select-Object Name | Where-Object {$_.Name -eq 'ccmsetup'}){'SCCM - In the process of installing or updating.' | Out-File $saida -Append}
else {
 
    if(Get-Service | Select-Object Name,Status | Where-Object {$_.Name -eq 'CcmExec'}){
        if ((Get-Service | Select-Object Name,Status | Where-Object {$_.Name -eq 'CcmExec' -and $_.Status -eq 'Running'}) -like '*Running*'){'SCCM Client Installed.'|Out-File $saida -Append}
        else{'Out of default configuration - SCCM Service Not Started.'|Out-File $saida -Append}
    }
    else
    {
        'Out of default configuration - Does not have SCCM client installed.'|Out-File $saida -Append
    }
}
 
#FortiClient check---------------------------------------------------------------------------------------------------------------------------------------------
 
if(Get-Service -Name FCT_SecSvr){
    if ((Get-Service | Select-Object Name,Status | Where-Object {$_.Name -eq 'FCT_SecSvr' -and $_.Status -eq 'Running'}) -like '*Running*'){'FortiClient OK.'|Out-File $saida -Append}
    else{'Out of default configuration - FortiClient Service Not Started.'|Out-File $saida -Append}
}
else
{
    'Out of default configuration - Does not contain FortiClient Antivirus installed.'|Out-File $saida -Append
}
 
#________________________________________________________________________________________________________________________________________________________
 
 
$x = 0
$y = 0
$z = 0
 
try{
    $PrivateProfile = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile | Select-Object PSChildName, EnableFirewall
    if ($null -ne $PrivateProfile){$x = 1}
 
    $DomainProfile = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall\DomainProfile | Select-Object PSChildName, EnableFirewall
    if ($null -ne $DomainProfile){$y = 1}
    
    $PublicProfile = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall\PublicProfile | Select-Object PSChildName, EnableFirewall 
    if ($null -ne $PublicProfile){$z = 1}
}
 
catch{'GPO NAO APLICADO' |Out-File $saida -Append}
 
if (($x -eq 1) -or ($y -eq 1) -or ($z -eq 1)){
 
if ((Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile | Select-Object PSChildName,EnableFirewall) -like '*0*'){'Windows Firewall Profile - Public OK.' |Out-File $saida -Append}
else{'Out of default configuration - Windows Firewall Public Profile.' |Out-File $saida -Append}
 
if ((Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile | Select-Object PSChildName,EnableFirewall) -like '*0*'){'Windows Firewall Profile - Private OK.' |Out-File $saida -Append}
else{'Out of default configuration - Windows Firewall Private Profile.' |Out-File $saida -Append}
 
if ((Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile | Select-Object PSChildName,EnableFirewall) -like '*0*'){'Windows Firewall Profile - Domain OK.' |Out-File $saida -Append}
else{'Out of default configuration - Windows Firewall Domain Profile.'|Out-File $saida -Append}
 
' '|Out-File $saida -Append
'################################################################################################################################'|Out-File $saida -Append
'Firewall Description Sample:' |Out-File $saida -Append
'* EnableFirewall = 0 --> Firewall Disabled | EnableFirewall = 1 --> Firewall Enabled' |Out-File $saida -Append
' '|Out-File $saida -Append

'Current Firewall Configuration:'|Out-File $saida -Append
Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile | Select-Object PSChildName,EnableFirewall |Out-File $saida -Append
Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile | Select-Object PSChildName,EnableFirewall |Out-File $saida -Append
Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile | Select-Object PSChildName,EnableFirewall|Out-File $saida -Append
' '|Out-File $saida -Append
}

'################################################################################################################################'| Out-File $saida -Append
'Resumo da conexao Ethernet:' |Out-File $saida -Append
' '|Out-File $saida -Append


#Restore and Check Connection__________________________________________________________________________________________________________________________________

#Adptador Ethernet#

if(Get-NetAdapter -Name "Ethernet"){
    if ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet' -and $_.Status -eq 'Up'}) -like '*Up*'){'Connected Ethernet Network Adapter.'| Out-File $saida -Append}
        elseif ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet' -and $_.Status -eq 'Disabled'}) -like '*Disabled*') 
            {
              Enable-NetAdapter -Name "Ethernet" -Confirm:$false
              get-netadapter "Ethernet" | Set-DnsClientServerAddress -ResetServerAddresses
              Clear-DnsClientCache
                    if ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet' -and $_.Status -eq 'Up'}) -like '*Up*'){'Network Adapter Reactivated.'| Out-File $saida -Append}
                        elseif ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet ' -and $_.Status -eq 'Disconnected'}) -like '*Disconnected*'){'Network adapter active and network cable disconnected.'|Out-File $saida -Append}
                            else
                                {
                                    'Malfunction with Adptador, cable disconnected or no permission - Could not activate the network adapter or there is no active connection.'| Out-File $saida -Append
                                }
            }
}

#Adptador Ethernet 2#

if(Get-NetAdapter -Name "Ethernet 2"){
    if ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 2' -and $_.Status -eq 'Up'}) -like '*Up*'){'Connected Ethernet Network Adapter.'| Out-File $saida -Append}
        elseif ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 2' -and $_.Status -eq 'Disabled'}) -like '*Disabled*') 
            {
              Enable-NetAdapter -Name "Ethernet 2" -Confirm:$false
              get-netadapter "Ethernet 2" | Set-DnsClientServerAddress -ResetServerAddresses
              Clear-DnsClientCache
                    if ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 2' -and $_.Status -eq 'Up'}) -like '*Up*'){'Network Adapter Reactivated.'| Out-File $saida -Append}
                        elseif ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 2' -and $_.Status -eq 'Disconnected'}) -like '*Disconnected*'){'Network adapter active and network cable disconnected.'|Out-File $saida -Append}
                            else
                                {
                                    'Malfunction with Adptador, cable disconnected or no permission - Could not activate the network adapter or there is no active connection.'| Out-File $saida -Append
                                }
            }
}

#Adptador Ethernet 3#

if(Get-NetAdapter -Name "Ethernet 3"){
    if ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 3' -and $_.Status -eq 'Up'}) -like '*Up*'){'Connected Ethernet Network Adapter.'| Out-File $saida -Append}
        elseif ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 3' -and $_.Status -eq 'Disabled'}) -like '*Disabled*') 
            {
              Enable-NetAdapter -Name "Ethernet 3" -Confirm:$false
              get-netadapter "Ethernet 3" | Set-DnsClientServerAddress -ResetServerAddresses
              Clear-DnsClientCache
                    if ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 3' -and $_.Status -eq 'Up'}) -like '*Up*'){'Network Adapter Reactivated.'| Out-File $saida -Append}
                        elseif ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 3' -and $_.Status -eq 'Disconnected'}) -like '*Disconnected*'){'Network adapter active and network cable disconnected.'|Out-File $saida -Append}
                            else
                                {
                                    'Malfunction with Adptador, cable disconnected or no permission - Could not activate the network adapter or there is no active connection.'| Out-File $saida -Append
                                }
            }
}

#Adptador Ethernet 4#

if(Get-NetAdapter -Name "Ethernet 4"){
    if ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 4' -and $_.Status -eq 'Up'}) -like '*Up*'){'Connected Ethernet Network Adapter.'| Out-File $saida -Append}
        elseif ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 4' -and $_.Status -eq 'Disabled'}) -like '*Disabled*') 
            {
              Enable-NetAdapter -Name "Ethernet 4" -Confirm:$false
              get-netadapter "Ethernet 4" | Set-DnsClientServerAddress -ResetServerAddresses
              Clear-DnsClientCache
                    if ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 4' -and $_.Status -eq 'Up'}) -like '*Up*'){'Network Adapter Reactivated.'| Out-File $saida -Append}
                        elseif ((Get-NetAdapter | Select-Object Name,Status | Where-Object {$_.Name -eq 'Ethernet 4' -and $_.Status -eq 'Disconnected'}) -like '*Disconnected*'){'Network adapter active and network cable disconnected.'|Out-File $saida -Append}
                            else
                                {
                                    'Malfunction with Adptador, cable disconnected or no permission - Could not activate the network adapter or there is no active connection.'| Out-File $saida -Append
                                }
            }
}

Copy-Item -Path 'C:\Windows\CNX\*.log' -Destination '\\mz-vv-dc-001\logs$' -Force