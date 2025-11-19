# ==============================================================
# Script PowerShell : Rendre Windows 10 volontairement vulnérable
# Objectif : Lab pentest (LLMNR + NetBIOS + SMBv1 + EternalBlue)
# À exécuter en tant qu'Administrateur (clic droit → Exécuter avec PowerShell en tant qu'administrateur)
# Auteur : Grok / adapté au module Cisco NetAcad 2025
# ==============================================================

Write-Host "=== Configuration Windows 10 VULNÉRABLE pour lab pentest ===" -ForegroundColor Red
Write-Host "Attention : NE JAMAIS exécuter ceci sur une machine de production !" -ForegroundColor Yellow
Pause

# 1. Activer SMBv1 (obligatoire pour EternalBlue MS17-010)
Write-Host "[1/7] Activation de SMBv1..." -ForegroundColor Cyan
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force

# 2. Activer NetBIOS over TCP/IP sur toutes les cartes réseau
Write-Host "[2/7] Activation de NetBIOS over TCP/IP..." -ForegroundColor Cyan
$interfaces = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE
foreach ($iface in $interfaces) {
    $iface.EnableNetbios(0)  # 0 = Activer NetBIOS over TCP/IP
}
# Forcer via registre
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" -Name "NetbiosOptions" -Value 0

# 3. Activer LLMNR (Link-Local Multicast Name Resolution)
Write-Host "[3/7] Activation de LLMNR..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 1 -Type DWord -Force

# 4. Désactiver SMB Signing (permet le relay NTLM plus facilement)
Write-Host "[4/7] Désactivation du SMB Signing (client & serveur)..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RequireSecuritySignature" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "RequireSecuritySignature" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "EnableSecuritySignature" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "EnableSecuritySignature" -Value 0 -Force

# 5. Désactiver Windows Defender en temps réel (optionnel mais pratique en lab)
Write-Host "[5/7] Désactivation temporaire de Windows Defender..." -ForegroundColor Cyan
Set-MpPreference -DisableRealtimeMonitoring $true -Force

# 6. Ouvrir les ports utiles dans le pare-feu Windows (SMB, NetBIOS, etc.)
Write-Host "[6/7] Ouverture des ports SMB/NetBIOS dans le pare-feu..." -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "SMB-In (Lab)" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "NetBIOS-In (Lab)" -Direction Inbound -Protocol UDP -LocalPort 137,138 -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "NetBIOS-In TCP (Lab)" -Direction Inbound -Protocol TCP -LocalPort 139 -Action Allow -Profile Any

# 7. Créer un partage administratif accessible à tout le monde (vulnérabilité classique)
Write-Host "[7/7] Création d'un partage C:\Lab vulnérable (everyone full control)..." -ForegroundColor Cyan
New-Item -Path "C:\Lab" -ItemType Directory -Force
New-SmbShare -Name "Lab" -Path "C:\Lab" -FullAccess "Tout le monde" -Force

Write-Host ""
Write-Host "=== CONFIGURATION TERMINÉE ===" -ForegroundColor Green
Write-Host "Ta machine est maintenant vulnérable à :" -ForegroundColor Yellow
Write-Host "   • LLMNR/NetBIOS Poisoning (Responder)"
Write-Host "   • EternalBlue / MS17-010 (Metasploit)"
Write-Host "   • Énumération SMB anonyme (enum4linux, crackmapexec)"
Write-Host "   • SMB Relay (si tu veux aller plus loin)"
Write-Host ""
Write-Host "Redémarre la machine pour que tout prenne effet." -ForegroundColor Magenta
Write-Host "Pour revenir en arrière → exécute le script 'Repair-Windows.ps1' que je peux te fournir aussi."
Pause
