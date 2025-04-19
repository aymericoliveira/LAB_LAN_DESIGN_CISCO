

# HSRP : Exemple de configuration

## HSRP1
```bash
interface GigabitEthernet0/0                  # Accéder à l'interface GigabitEthernet0/0  
ip address 192.168.1.252 255.255.255.0        # Configurer l'adresse IP et le masque de sous-réseau  
ip nat inside                                 # Marquer l'interface pour la translation d'adresses réseau (NAT) interne  
standby 1 ip 192.168.1.254                    # Définir l'adresse IP virtuelle de l'HSRP  
standby 1 priority 101                        # Attribuer une priorité de 101 pour le routeur actuel  
standby 1 preempt                             # Activer le mode "preempt"  
standby 1 track s0/0/0                        # Suivre l'interface s0/0/0   
```

## HSRP2
```bash
 interface GigabitEthernet0/0                  # Accéder à l'interface GigabitEthernet0/0
 ip address 192.168.1.253 255.255.255.0        # Configurer l'adresse IP et le masque de sous-réseau
 ip nat inside                                 # Marquer l'interface pour la translation d'adresses réseau (NAT) interne
 standby 1 ip 192.168.1.254                    # Définir l'adresse IP virtuelle de l'HSRP
 standby 1 priority 99                         # Attribuer une priorité de 99 pour le routeur secondaire
 standby 1 preempt                             # Activer le mode "preempt" : permet au routeur secondaire de devenir principal si nécessaire
 ```