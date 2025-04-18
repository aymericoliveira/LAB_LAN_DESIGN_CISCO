####################################################
#                   TESTS DE HAUTE DISPONIBILITÉ
# --------------------------------------------------
# Ce bloc liste les tests à réaliser pour valider
# la résilience du réseau en cas de panne.
#
# ➤ Secteurs concernés :
#    - ADMINISTRATION
#    - PRODUCTION
#    - TRANSPORT
#
# ➤ Services critiques à surveiller :
#    - DHCP
#    - Accès au réseau local
#    - Accès à Internet
#
# --------------------------------------------------
# 🔴 TESTS D'AVARIE :
# --------------------------------------------------
# o Perte d’un lien entre ACCESSx et DISTRIB1
# o Perte de DISTRIB1
# o Perte du lien entre DISTRIB1 et HSRP1
# o Perte de HSRP1
# o Perte du lien WAN entre HSRP1 et FAI
#
# --------------------------------------------------
# 🟢 TESTS DE RÉSILIENCE :
# --------------------------------------------------
# o Retour du lien entre ACCESSx et DISTRIB1
# o Retour de DISTRIB1
# o Retour du lien entre DISTRIB1 et HSRP1
# o Retour de HSRP1
# o Retour du lien WAN entre HSRP1 et FAI
#
# ➤ Objectif : Vérifier que le réseau continue
#   de fonctionner ou se rétablit correctement
#   après chaque panne simulée.
#
# ➤ Matériel : déjà en place.
#   Il ne vous reste plus qu’à câbler, configurer
#   et effectuer les tests.
####################################################