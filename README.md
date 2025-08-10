<h1 align="center">
  Vulnerabilités ACTIVE DIRECTORY
  <br>
</h1>    

Crée un Active Directory vulnérable pour tester la majorité des attaques AD courantes dans un lab local, en complément de mon dépôt [import_bulk_Users-Groupes_OU_ActiveDirectory](https://github.com/sbeteta42/import_bulk_Users-Groupes_OU_ActiveDirectory).

---

## ​ Attaques prises en charge
- Abus d’ACL/ACE  
- Kerberoasting  
- AS-REP Roasting  
- Abus des administrateurs DNS  
- Mot de passe dans la description d’un objet  
- Utilisateurs avec mot de passe par défaut (`ChangeMe123!`)  
- Pulvérisation de mot de passe (Password Spraying)  
- DCSync  
- Golden Ticket / Silver Ticket (Kerberos)  
- Pass-the-Hash  
- Pass-the-Ticket  
- Désactivation de la signature SMB  

---

## ​ Principales fonctionnalités
- Génération aléatoire des attaques pour diversifier les exercices  
- Couvre tous les scénarios listés ci-dessus  
- À lancer directement **sur le contrôleur de domaine (DC)** avec AD installé  
- Certaines attaques peuvent nécessiter un poste client

---

##  Utilisation (PowerShell Windows Server)
1. **Si tu n’as pas encore AD installé :**
    ```powershell
    Import-Module ADDSDeployment
    Install-ADDSForest -CreateDnsDelegation:$false `
                       -DatabasePath "C:\Windows\NTDS" `
                       -DomainMode "7" `
                       -DomainName "formation.lan" `
                       -DomainNetbiosName "formation" `
                       -ForestMode "7" `
                       -InstallDns:$true `
                       -LogPath "C:\Windows\NTDS" `
                       -NoRebootOnCompletion:$false `
                       -SysvolPath "C:\Windows\SYSVOL" `
                       -Force:$true
    ```

2. **Sinon, exécute simplement le script :**
    ```powershell
    IEX((New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/sbeteta42/vulnerable-AD/master/vulner-ad.ps1"))
    Invoke-VulnAD -UsersLimit 100 -DomainName "formation.lan"
    ```

---

##  À propos
Ce dépôt te permet de monter facilement un environnement **Active Directory volontairement vulnérable**, parfait pour les labs de sécurité, pentests internes ou TP. Il suit la logique de mon dépôt [import_bulk_Users-Groupes_OU_ActiveDirectory](https://github.com/sbeteta42/import_bulk_Users-Groupes_OU_ActiveDirectory).

---

##  Licence
MIT... libre comme l’air !

