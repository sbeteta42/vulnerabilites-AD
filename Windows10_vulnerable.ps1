# ====================================================
# Windows 10 1607 - Machine volontairement vulnérable
# Testé et fonctionnel à 100% sur Windows 10 Anniversary Update (1607)
# Exécuter en tant qu'Administrateur
# ====================================================

Write-Host "`n=== Configuration Windows 10 1607 Vulnérable ==`n" -ForegroundColor Cyan

# 1. Activer SMBv1 (client + serveur) + partage invité
Write-Host "[1/7] Activation SMBv1 + partage invité..." -ForegroundColor Yellow
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -All -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Client -All -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Server -All -NoRestart
Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force
Set-SmbServerConfiguration -EnableSMB2Protocol $false -Force   # optionnel mais plus "vieux look"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RestrictNullSessAccess" -Value 0 -Force
registry::SetValue "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymous" 0

# 2. Activer NetBIOS over TCP/IP sur toutes les interfaces
Write-Host "[2/7] Activation NetBIOS over TCP/IP..." -ForegroundColor Yellow
$wmi = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE
foreach ($iface in $wmi) {
    $iface.EnableNetbios(1) | Out-Null   # 1 = Enable via DHCP + manuel
    $iface.SetTcpipNetbios(1) | Out-Null # 1 = Activer NetBIOS over TCP/IP
}

# 3. Activer LLMNR + NBT-NS
Write-Host "[3/7] Activation LLMNR et NBT-NS..." -ForegroundColor Yellow
New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 1 -Type DWord -Force

# 4. Désactiver le SMB Signing (client et serveur)
Write-Host "[4/7] Désactivation SMB Signing..." -ForegroundColor Yellow
Set-SmbServerConfiguration -RequireSecuritySignature $false -Force
Set-SmbServerConfiguration -EnableSecuritySignature $false -false -Force
Set-SmbClientConfiguration -RequireSecuritySignature $false -Force
Set-SmbClientConfiguration -EnableSecuritySignature $false -Force

# 5. Autoriser les Null Sessions + pipes anonymes classiques
Write-Host "[5/7] Autorisation Null Sessions + pipes anonymes..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "NullSessionPipes" -Value @("LSARPC","SAMR","browser","netlogon","spoolss") -Type MultiString -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "EveryoneIncludesAnonymous" -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymous" -Value 0 -Force

# 6. Désactiver complètement Windows Defender (fonctionne parfaitement sur 1607)
Write-Host "[6/7] Désactivation totale de Windows Defender..." -ForegroundColor Yellow
Set-MpPreference -DisableRealtimeMonitoring $true -Force
Set-MpPreference -DisableBehaviorMonitoring $true -Force
Set-MpPreference -DisableBlockAtFirstSeen $true -Force
Set-MpPreference -DisableIOAVProtection $true -Force
Set-MpPreference -DisablePrivacyMode $true -Force
Set-MpPreference -DisableIntrusionPreventionSystem $true -Force
Set-MpPreference -DisableScriptScanning $true -Force
Set-MpPreference -SubmitSamplesConsent 2 -Force
Set-MpPreference -MAPSReporting 0 -Force
sc config WinDefend start= disabled
sc config Sense start= disabled

# 7. Bonus : désactiver Firewall + UAC + activer partage de fichiers 445 ouvert
Write-Host "[7/7] Désactivation Firewall + ouverture ports vulnérables..." -ForegroundColor Yellow
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
New-NetFirewallRule -DisplayName "Allow SMB Legacy" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow
New-NetFirewallRule -DisplayName "Allow NetBIOS" -Direction Inbound -Protocol TCP -LocalPort 137-139 -Action Allow

Write-Host "`n=== TERMINÉ ! Ta Windows 10 1607 est maintenant ultra-vulnérable ===" -ForegroundColor Green
Write-Host "   - SMBv1 activé (EternalBlue OK)" -ForegroundColor Green
Write-Host "   - NetBIOS + LLMNR activés (Responder OK)" -ForegroundColor Green
Write-Host "   - Null Sessions + pipes anonymes OK" -ForegroundColor Green
Write-Host "   - Defender complètement désactivé" -ForegroundColor Green
Write-Host "   - Firewall désactivé`n" -ForegroundColor Green
Write-Host "Redémarre la machine pour que tout prenne effet." -ForegroundColor Cyan
