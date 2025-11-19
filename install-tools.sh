#!/bin/bash
echo "[+] Mise à jour système"
sudo apt update

echo "[+] Installation des outils du TP"
sudo apt install -y metasploit-framework responder hashcat crackmapexec enum4linux-ng nmap smbclient impacket-scripts bloodhound.py python3-pip

echo "[+] Tout est prêt !"
echo "Test Responder : sudo python3 /opt/Responder/Responder.py -I eth0 -dw"
echo "Test Metasploit EternalBlue : msfconsole -q -x 'use exploit/windows/smb/ms17_010_eternalblue; exit'"
