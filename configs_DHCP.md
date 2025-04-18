Configurer un serveur DHCP sur un routeur Cisco
===============================================


ip dhcp pool POOL1
 network 192.168.10.0 255.255.255.0
 default-router 192.168.10.254
 dns-server 192.168.10.1
 domain-name ipssi.lan

Création du pool DHCP :
ip dhcp pool

Définition de l'étendue d'adresses que le routeur pourra attribuer :
network

Indique la passerelle par défaut :
default-router

Indique le serveur DNS :
dns-server

Indique le suffixe DNS :
domain-name

Pour exclure une plage d'adresses :
ip dhcp excluded-address 192.168.10.251 192.168.10.253
! Attention : les exclusions se font en mode de configuration globale.

Pour afficher les baux d’adresses attribués par le serveur DHCP :
show ip dhcp binding

Pour afficher les statistiques du serveur DHCP :
show ip dhcp server statistics

Pour dépanner le serveur DHCP :
debug ip dhcp server events

