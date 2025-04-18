@"
# Objectif du LAB
Mise en place d'une architecture 2-Tiers sous Packet Tracer.

Dans ce LAB, nous allons explorer les concepts suivants :
- **HSRP**
- **VTP**
- **VLANs**
- **RSTP**
- **Routage inter-VLAN**
- **DHCP**
- **ACL**
- **NAT / PAT / Accès à Internet**

## Pré-requis
Avant de commencer, assurez-vous d'avoir :
- **Packet Tracer** : Vous aurez besoin de Packet Tracer, disponible gratuitement en créant un compte sur [NetAcad](https://www.netacad.com/).

## Matériel requis
Le laboratoire nécessite les équipements suivants :
- **3x Routeurs 1941** (FAI, HSRP1, HSRP2)
- **5x Switchs 2960** (ACCESS1, ACCESS2, ACCESS3, DISTRIB1, DISTRIB2)
- **1x Serveur** (INET)
- **3x PC** (ADMINISTRATION, PRODUCTION, TRANSPORT)

## Câblage LAN / WAN

ACCESSx f0/23-24     <-> f0/21-24 DISTRIBx  
DISTRIB1 g0/1         <-> g0/1 DISTRIB2  
DISTRIB1 g0/2         <-> g0/0 HSRP1  
HSRP1 s0/0/0 (DTE)    <-> s0/0/0 (DCE) FAI        [1.0.0.0/30 - 4 Mbps]  
DISTRIB2 g0/2         <-> g0/0 HSRP2  
HSRP2 s0/0/0 (DTE)    <-> s0/0/1 (DCE) FAI        [2.0.0.0/30 - 1 Mbps]  
FAI g0/0              <-> INET  
ACCESS1 f0/1          <-> ADMINISTRATION  
ACCESS2 f0/7          <-> PRODUCTION  
ACCESS3 f0/13         <-> TRANSPORT

## Déploiement

- **VTP Domain** : `autoprod.lan`
- **VTP Password** : `AUTOPROD-VTP-Key`
- **VLANs** :
  - VLAN 1 : Default
  - VLAN 2 : ADMINISTRATION - 192.168.2.0/24 - ACCESSx f0/1-6
  - VLAN 3 : PRODUCTION - 192.168.3.0/24 - ACCESSx f0/7-12
  - VLAN 4 : TRANSPORT - 192.168.4.0/24 - ACCESSx f0/13-18
  - VLAN 5 : TRAP - ACCESSx ports restants

- **RSTP** : activé
- **Routage inter-VLAN** : via sous-interfaces, haute disponibilité avec HSRP
- **HSRP** : HSRP1 actif / HSRP2 passif
- **DHCP** : serveurs HSRP1 et HSRP2, pools par VLAN
- **NAT / PAT** : translation pour accès à Internet, haute disponibilité

## Structure du projet

Le projet est composé des fichiers suivants :
- **`README.md`** : Ce fichier, contenant des informations sur le projet
- **`configs/HSRP.txt`** : Exemple de configuration HSRP
- **`configs/DHCP.txt`** : Configuration DHCP sur routeur Cisco
- **`topologie/TP_LAN_Design`** : Fichier de topologie ou plan logique
-**``**: Fichier de test de haute de haute disponibilité 

## Licence

Ce projet est sous **licence MIT**. Cela signifie que vous êtes libre de l'utiliser, de le modifier et de le distribuer, dans les conditions suivantes :

- **Droits d'utilisation** : Vous pouvez utiliser ce code pour tout projet personnel ou professionnel, y compris des projets commerciaux.
- **Modifications** : Vous êtes autorisé à modifier le code pour l'adapter à vos besoins.
- **Distribution** : Vous pouvez distribuer des copies modifiées du code, à condition d'inclure la même licence MIT dans les fichiers distribués.

**Avertissement** : Ce projet est fourni "tel quel", sans aucune garantie d'aucune sorte, expresse ou implicite, y compris mais sans s'y limiter les garanties de qualité marchande et d'adaptation à un usage particulier.
"@ | Out-File "README.md" -Encoding UTF8
