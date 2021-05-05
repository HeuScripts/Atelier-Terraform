

########################
# Résumé du déploiment #
########################

Tout est pret !

Nouveau déploiement de la configuration lancé le: ${day}/${month}/${year} à ${hour}:${minute}

L'adresse IP de la machine est:
${ip}

L'identifiant pour se connecter sur la machine est :
myvm\azureuser 

Et le mot de passe pour la demo : 
${pass}

Pour se connecter directement :
Get-AzRemoteDesktopFile -ResourceGroupName "myResourceGroup3" -Name "myVM" -Launch