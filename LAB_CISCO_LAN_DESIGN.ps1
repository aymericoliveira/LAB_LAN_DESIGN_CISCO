
# Ce fichier contient des commandes pour configurer un réseau sur du matériel CISCO.
# Avant de commancer il est préférable de prendre connaissance du README.md.

####################################################
# Matériels :
# 3x Router 1941 + HWIC-2T : FAI / HSRP1 / HSRP2
# 5x Switch 2960 : ACCESS1 / ACCESS2 / ACCESS3 / DISTRIB1 / DISTRIB2
# 1x Server : INET
# 3x PC : ADMINISTRATION / PRODUCTION / TRANSPORT
####################################################


# INET
1.1.1.1
255.255.255.252
1.1.1.2

# FAI
hostname FAI # Définit le nom du routeur en "FAI"
int g0/0 # Accède à l'interface GigabitEthernet 0/0
ip add 1.1.1.2 255.255.255.252 # Attribue l'adresse IP 1.1.1.2 avec un masque /30
no shut # Active l'interface (par défaut elle est désactivée)

int s0/0/0 # Accède à l'interface série 0/0/0
clock rate 4000000 # Définit le débit d'horloge à 4 Mbps (nécessaire si côté DCE)
ip add 1.0.0.2 255.255.255.252 # Attribue l'adresse IP 1.0.0.2 avec un masque /30
no shut # Active l'interface

int s0/0/1 # Accède à l'interface série 0/0/1
clock rate 1000000 # Définit le débit d'horloge à 1 Mbps (nécessaire si côté DCE)
ip add 2.0.0.2 255.255.255.252 # Attribue l'adresse IP 2.0.0.2 avec un masque /30
no shut # Active l'interface

# HSRP1
hostname HSRP1 
int g0/0 
no shut # Active l'interface
int s0/0/0                                  
description Primary-WAN-Link # Ajoute une description à l'interface (lien WAN principal)
ip add 1.0.0.1 255.255.255.252 # Attribue l'adresse IP 1.0.0.1 avec un masque /30
no shut # Active l'interface
ip route 0.0.0.0 0.0.0.0 1.0.0.2

# HSRP2
hostname HSRP2
int g0/0
no shut
int s0/0/0
description Backup-WAN-Link # Ajoute une description à l'interface (lien WAN backup)
ip add 2.0.0.1 255.255.255.252
no shut
ip route 0.0.0.0 0.0.0.0 2.0.0.2

####################################################
# A ce stade, les routeurs HSRP peuvent joindre toutes les adresses IP publiques.
####################################################

# DISTRIB1
hostname DISTRIB1 # Définit le nom du switch en "DISTRIB1"
ip default-gateway 192.168.1.254 # Définit la passerelle par défaut pour le switch (accès hors réseau local)
int vlan 1 # Accède à l'interface VLAN 1 (interface de gestion)
description Default-Admin-VLAN # Ajoute une description à l'interface VLAN 1
ip address 192.168.1.1 255.255.255.0 # Attribue l'adresse IP 192.168.1.1 à l'interface VLAN 1
no shut # Active l'interface VLAN 1

# DISTRIB2
hostname DISTRIB2
ip default-gateway 192.168.1.254
int vlan 1
description Default-Admin-VLAN
ip address 192.168.1.2 255.255.255.0
no shut

# ACCESS1
hostname ACCESS1
ip default-gateway 192.168.1.254
int vlan 1
description Default-Admin-VLAN
ip address 192.168.1.11 255.255.255.0
no shut

# ACCESS2
hostname ACCESS2
ip default-gateway 192.168.1.254
int vlan 1
description Default-Admin-VLAN
ip address 192.168.1.12 255.255.255.0
no shut

# ACCESS3
hostname ACCESS3
ip default-gateway 192.168.1.254
int vlan 1
description Default-Admin-VLAN
ip address 192.168.1.13 255.255.255.0
no shut

####################################################
# À ce stade, les switches peuvent se joindre entre eux au niveau IP.
####################################################

####################################################
# Configuration des trunks
# Configuration des trunks
------------------------
# Les liens entre les switches doivent être des trunks.
# Les liens entre les routeurs et les switches doivent être des trunks.
# Les switches de la couche Distribution sont reliés uniquement par des trunks.
# L'idéal est que les trunks se forment automatiquement quand on connecte un nouveau switch à la Distribution.
# Les ports des switches de Distribution peuvent donc être configurés en mode "dynamic desirable" pour la plupart.
# Seuls les ports connectés à des routeurs devront être configurés en mode "trunk".
# Aucune configuration concernant les trunks n'est à apporter au switches de la couche Access.
####################################################

# DISTRIB1
int range f0/1-24,g0/1 # j'accède aux interfaces FastEthernet 0/1 à 0/24 et GigabitEthernet 0/1
switchport mode dynamic desirable # Je configure les ports pour négocier automatiquement le mode trunk si possible
int g0/2 # j'accède à l'interface GigabitEthernet 0/2
switchport mode trunk # Je force le port en mode trunk (permet le passage de plusieurs VLANs)


# DISTRIB2
int range f0/1-24,g0/1
switchport mode dynamic desirable
int g0/2
switchport mode trunk

####################################################
# À ce stade, nos trunks sont fonctionnels.
####################################################

####################################################
# Configuration VTP
-----------------
# Création du domaine VTP.
# Création du mot de passe du domaine VTP.
# Les switches de Distribution resteront en mode VTP server.
# Il est important d'avoir plusieurs switches en mode VTP server.
# En cas d'indisponibilité de l'un d'eux, un autre est directement disponible sans configuration supplémentaire.
# À partir de ces switches, on pourra créer, modifier, supprimer des VLANs.
# Les switches de la couche Access seront configurés en mode VTP client.
# Les techniciens opérant sur les switches de la couche Access n'ont pas les mêmes habilitations que les techniciens opérant sur les switches de la couche Distribution.
# En effet, les techniciens des switches de la couche Access pourront par exemple attribuer des VLANs aux ports des switches de la couche Access mais ne pourront pas modifier les VLANs ou le mode VTP d'un switch.
####################################################

# DISTRIB1

vtp domain autoprod.lan # Je définis le nom de domaine VTP sur "autoprod.lan"
vtp password AUTOPROD-VTP-Key # Je configure le mot de passe VTP pour sécuriser l’échange des infos de VLAN

# DISTRIB2
do show vtp stat # Je vérifie l’état du VTP depuis le mode configuration (commande exécutée en mode privilégié)
vtp password AUTOPROD-VTP-Key # Je saisis le même MDP VTP que sur DISTRIB1 pour garantir la synchronisation entre le Distrib1 et Distrib2

# ACCESSx
do show vtp stat # Je consulte les infos VTP sur un switch d'accès
vtp password AUTOPROD-VTP-Key # J’entre le MDP VTP pour l’authentification
vtp mode client # Je passe le switch en mode client VTP pour qu’il reçoive les infos VLAN sans pouvoir les modifier

#* On ne configurera pas ici les accès aux switches ni les privilèges IOS.

# Création des VLANs
-----------------
# DISTRIB1
vlan 2 # Je créer le VLAN 2 
name ADMINISTRATION # Je donne un nom au VLAN 2
vlan 3
name PRODUCTION
vlan 4
name TRANSPORT
vlan 5
name TRAP

####################################################
# Configuration RSTP
------------------
# Nous construisons une architecture hautement disponible.
# Il est primordial que les changements de topologie soient rapides.
# Nous utiliserons donc le protocole Rapid Spanning Tree (RSTP).
# DISTRIB1 sera le "Root Primary" et DISTRIB2 le "Root Secondary".
####################################################

# DISTRIB1
span vlan 1-5 prio 24576 # Je définis la priorité STP pour les VLANs 1 à 5 à 24576 sur DISTRIB1 (priorité plus forte)
span mode rapid # Je configure le mode Rapid PVST+ pour un STP plus rapide

# DISTRIB2
span vlan 1-5 prio 28672 # Je définis une priorité STP un peu plus élevée (donc moins prioritaire) que DISTRIB1 pour les VLANs 1 à 5
span mode rapid # Je passe aussi DISTRIB2 en mode Rapid PVST+

# ACCESSx
span mode rapid # Je configure les switches d’accès en mode Rapid PVST+, pour un temps de convergence réduit


####################################################
# Attribution de VLAN aux ports
---------------------------------------
# ACCESSx
 # Chaque switch de la couche Access doit pouvoir accueillir six ordinateurs pour chaque VLAN.
 # Les ports f0/1-18 seront donc configurés en mode "access".
 # Les ports f0/1-6 seront attribués au VLAN 2.
 # Les ports f0/7-12 seront attribués au VLAN 3.
 # Les ports f0/13-18 seront attribués au VLAN 4.
 # Les ports f0/23 et f0/24 doivent passer en mode "trunk" lorsqu'ils sont connectés aux switches de Distribution.
 # Ces derniers resteront donc tous en mode "dynamic auto".
 # Ils seront attribués au VLAN 5 (effectif uniquement en mode "access").
 # Les ports restants seront configurés en mode "access" et seront attribués au VLAN 5.
# DISTRIBx
 # Les switches de Distribution sont connectés uniquement à des switches et des routeurs.
 # Leurs ports resteront donc tous en mode "dynamic desirable" ou "trunk".

# Ils seront tous attribués au VLAN 5 (effectif uniquement en mode "access").
####################################################

# DISTRIBx
int range f0/1-24,g0/1-2 # j'accède aux interfaces Fast 0/1 à 0/24 et Gig 1/2
switchport access vlan 5 # j'assigne les VLAN 5 (Ils seront dans le même de broadcast)

# ACCESSx
int range f0/1-18 # j'accède aux interfaces Fast 0/1 
switchport mode access # je configure les ports en mode access

int range f0/1-6
switchport access vlan 2

int range f0/7-12
switchport access vlan 3

int range f0/13-18
switchport access vlan 4

int range f0/23-24
switchport access vlan 5

int range f0/19-22,g0/1-2
switchport mode access
switchport access vlan 5

####################################################
# Configuration du routage inter-VLAN
-----------------------------------
# Les deux routeurs HSRP doivent être en mesure d'assurer le routage inter-VLAN seuls.
# Leurs interfaces g0/0 sont connectées au LAN par un port trunk.
# Pour chaque interface g0/0, il faut créer une sous-interface dot1q par VLAN (on omettra volontairement le VLAN 5).
# Chaque sous-interface doit posséder sa propre adresse IP.
####################################################

# HSRP1
int g0/0.1 # J'accède à l'interface sous-interface GigabitEthernet 0/0.1
description Default-Admin-VLAN # Je donne une description pour identifier le VLAN d'administration par défaut
encapsulation dot1q 1 # J'encapsule cette sous-interface avec le VLAN 1 en utilisant le protocole 802.1Q
ip address 192.168.1.252 255.255.255.0 # J'attribue l'adresse IP 192.168.1.252 à cette sous-interface pour le VLAN 1

int g0/0.2
description ADMINISTRATION
encapsulation dot1q 2
ip address 192.168.2.252 255.255.255.0

int g0/0.3
description PRODUCTION
encapsulation dot1q 3
ip address 192.168.3.252 255.255.255.0

int g0/0.4
description TRANSPORT
encapsulation dot1q 4
ip address 192.168.4.252 255.255.255.0

# HSRP2
int g0/0.1
description Default-Admin-VLAN
encapsulation dot1q 1
ip address 192.168.1.253 255.255.255.0

int g0/0.2
description ADMINISTRATION
encapsulation dot1q 2
ip address 192.168.2.253 255.255.255.0

int g0/0.3
description PRODUCTION
encapsulation dot1q 3
ip address 192.168.3.253 255.255.255.0

int g0/0.4
description TRANSPORT
encapsulation dot1q 4
ip address 192.168.4.253 255.255.255.0

# HSRP1
int g0/0.1  
standby 1 ip 192.168.1.254 # Je configure l’adresse IP virtuelle HSRP du groupe 1 pour assurer la haute dispo (gateway virtuelle)
standby 1 priority 101 # Je définis la priorité de ce routeur à 101 (plus haute priorité = routeur actif si supérieur aux autres)
standby 1 preempt # J’active la préemption : si ce routeur devient à nouveau le plus prioritaire, il reprendra le rôle actif
standby 1 track s0/0/0 # Je fais en sorte que la priorité baisse si l’interface s0/0/0 tombe (failover plus intelligent)

int g0/0.2
standby 2 ip 192.168.2.254
standby 2 priority 101
standby 2 preempt
standby 2 track s0/0/0

int g0/0.3
standby 3 ip 192.168.3.254
standby 3 priority 101
standby 3 preempt
standby 3 track s0/0/0

int g0/0.4
standby 4 ip 192.168.4.254
standby 4 priority 101
standby 4 preempt
standby 4 track s0/0/0

# HSRP2
int g0/0.1
standby 1 ip 192.168.1.254
standby 1 priority 99
standby 1 preempt

int g0/0.2
standby 2 ip 192.168.2.254
standby 2 priority 99
standby 2 preempt

int g0/0.3
standby 3 ip 192.168.3.254
standby 3 priority 99
standby 3 preempt

int g0/0.4
standby 4 ip 192.168.4.254
standby 4 priority 99
standby 4 preempt

# HSRP2
show standby brief 

                    P indicates configured to preempt.
                     |
Interface   Grp  Pri P State        Active               Standby      Virtual IP
Gig           1      99  P Standby  192.168.1.252   local           192.168.1.254  
Gig           2      99  P Standby  192.168.2.252   local           192.168.2.254  
Gig           3      99  P Standby  192.168.3.252   local           192.168.3.254  
Gig           4      99  P Standby  192.168.4.252   local           192.168.4.254 

# On peut voir que tout fonctionne normalement. On peut aussi tester le HSRP1

####################################################
# Configuration du DHCP
---------------------
# HSRP1 et HSRP2 doivent être capables de délivrer des adresses pour les VLAN qui en ont besoin.
# Ils devront tous les deux détenir un pool DHCP par VLAN à alimenter.
# Pour éviter les conflits, ils ne délivreront pas les mêmes plages d'adresses IP.
# Pour chaque VLAN, HSRP1 délivrera les 50 premières adresses IP, et HSRP2 délivrera les 50 adresses IP suivantes.
####################################################

# HSRP1
ip dhcp pool ADMINISTRATION # Je crée un pool DHCP pour le VLAN Administration
net 192.168.2.0 255.255.255.0 # Je définis le réseau utilisé pour ce pool
default-router 192.168.2.254 # Je spécifie la passerelle par défaut (adresse HSRP virtuelle)

ip dhcp pool PRODUCTION          
net 192.168.3.0 255.255.255.0              
default-router 192.168.3.254      

ip dhcp pool TRANSPORT          
net 192.168.4.0 255.255.255.0       
default-router 192.168.4.254                

ip dhcp excluded-address 192.168.2.51 192.168.2.254   # J’exclus les adresses élevées du pool ADMINISTRATION (réservées aux équipements réseau par ex.)
ip dhcp excluded-address 192.168.3.51 192.168.3.254   # J’exclus les IP hautes du pool PRODUCTION
ip dhcp excluded-address 192.168.4.51 192.168.4.254   # Même principe pour le pool TRANSPORT


# HSRP2
ip dhcp pool ADMINISTRATION
net 192.168.2.0 255.255.255.0
default-router 192.168.2.254

ip dhcp pool PRODUCTION
net 192.168.3.0 255.255.255.0
default-router 192.168.3.254

ip dhcp pool TRANSPORT
net 192.168.4.0 255.255.255.0
default-router 192.168.4.254

ip dhcp excluded-address 192.168.2.1 192.168.2.50
ip dhcp excluded-address 192.168.3.1 192.168.3.50
ip dhcp excluded-address 192.168.4.1 192.168.4.50
ip dhcp excluded-address 192.168.2.101 192.168.2.254
ip dhcp excluded-address 192.168.3.101 192.168.3.254
ip dhcp excluded-address 192.168.4.101 192.168.4.254

####################################################
# À ce stade, les ordinateurs ADMINISTRATION, PRODUCTION et TRANSPORT sont en mesure de recevoir 
# une configuration IP et de communiquer entre eux ou avec d'autres ressources sur le réseau local.
####################################################

# NAT / PAT / Accès à Internet
----------------------------
# HSRP1 et HSRP2 doivent tout deux être capables d'assurer ce service.

# HSRP1
access-list 1 permit 192.168.1.0 0.0.0.255 # Je crée une ACL numéro 1 qui autorise le trafic provenant du réseau 192.168.4.0/24
access-list 1 permit 192.168.2.0 0.0.0.255
access-list 1 permit 192.168.3.0 0.0.0.255
access-list 1 permit 192.168.4.0 0.0.0.255
ip nat inside source list 1 int s0/0/0 over # J’active la NAT avec surcharge (PAT) pour traduire les IPs du réseau interne en l’IP publique de l’interface s0/0/0
int g0/0.1
ip nat inside
int g0/0.2
ip nat inside
int g0/0.3
ip nat inside
int g0/0.4
ip nat inside
int s0/0/0
ip nat outside

# HSRP2
access-list 1 permit 192.168.1.0 0.0.0.255
access-list 1 permit 192.168.2.0 0.0.0.255
access-list 1 permit 192.168.3.0 0.0.0.255
access-list 1 permit 192.168.4.0 0.0.0.255
ip nat inside source list 1 int s0/0/0 over
int g0/0.1
ip nat inside
int g0/0.2
ip nat inside
int g0/0.3
ip nat inside
int g0/0.4
ip nat inside
int s0/0/0
ip nat outside

####################################################
# À ce stade, les ordinateurs ADMINISTRATION, PRODUCTION, TRANSPORT et les autres 
# ressources du réseau local ont un accès à Internet fonctionnel et hautement disponible.
####################################################







