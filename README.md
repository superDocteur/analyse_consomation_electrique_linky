# Analyse de consommation électrique Linky

Ce projet a pour but de visualiser avec des couleurs la répartition de votre consommation d'électricité à partir des données fournies par ENEDIS pour le compteur Linky.

## Description

Le script `linky.R` est écrit en langage R et utilise les librairies `dplyr`, `tidyr`, `ggplot2` et `lubridate` pour :
1.  Lire les données de consommation (fichier CSV).
2.  Nettoyer et transformer les données.
3.  Calculer la consommation moyenne par mois et par heure.
4.  Générer une heatmap (carte de chaleur) pour visualiser la consommation.

Le script a été refactorisé pour suivre les bonnes pratiques de programmation en R, en utilisant notamment des pipelines `dplyr` pour plus de clarté et d'efficacité.

## Utilisation

1.  Récupérez votre fichier de consommation depuis le site d'ENEDIS.
2.  Renommez le fichier en `mes-puissances-atteintes-30min.csv`.
3.  Placez ce fichier dans le même répertoire que le script `linky.R`.
4.  Exécutez le script R. Le graphique sera généré.

Une image d'exemple du graphique généré (`analyse_conso.png`) est incluse dans ce dépôt.
