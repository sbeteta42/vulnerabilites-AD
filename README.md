<h1 align="center">
  Vulnerabilités ACTIVE DIRECTORY
  <br>
</h1>

Créez un Active Directory vulnérable qui vous permet de tester la plupart des attaques Active Directory dans un laboratoire local, ceci fait suite à mon dépot github https://github.com/sbeteta42/import_bulk_Users-Groupes_OU_ActiveDirectory

### Attaques prises en charge
- Abuser des ACL/ACE
- Kerbéroastre
- Torréfaction AS-REP
- Abuser des administrateurs DNS
- Mot de passe dans la description de l'objet
- Objets utilisateur avec mot de passe par défaut (Changeme123 !)
- Pulvérisation de mot de passe
- DCSync
- Billet Argent (silver ticket) kerberos
- Billet d'or (golden ticket) kerberos
- Passez le hachage
- Passez le billet
- Signature SMB désactivée


### Caractéristiques principales
- Randomiser les attaques
- Couverture complète des attaques mentionnées
- vous devez exécuter le script dans le DC avec Active Directory installé
- Certaines attaques nécessitent un poste client

### Exemple
```powershell
# si vous n'avez pas encore installé Active Directory: Installer la fonctionnalité Windows des services de domaine AD
Module d'importation ADDSDeployment
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\\Windows\\NTDS" -DomainMode "7" -DomainName "formation.lan" -DomainNetbiosName "formation" -ForestMode "7" -InstallDns:$true -LogPath " C:\\Windows\\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\\Windows\\SYSVOL" -Force:$true
# si vous avez déjà installé Active Directory, exécutez simplement le script !
IEX((new-object net.webclient).downloadstring("https://raw.githubusercontent.com/sbeteta42/vulnerable-AD/master/vulner-ad.ps1"));
Invoke-VulnAD -UsersLimit 100 -DomainName "formation.lan"
```
