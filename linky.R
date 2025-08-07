#!/usr/bin/env Rscript
# Note : j'ai rajouté un shebang, ça mange pas de pain même si ça ne sert à rien
#        sous Windows ou si on le lance via Rstudio
#        Je trouve tout de même que ça aide à voir d'un rapide coup d'oeil ce
#        qui se trouve dans le fichier surtout si l'extension n'est pas parlante.

# Instructions:
# 1) Récupérer le zip fourni par ENEDIS (compteur linky).
# 2) Renommer le fichier 'mes-puissances-atteintes-30min-XXXXXXXXXXXXXXXXXX.csv'
#    en 'mes-puissances-atteintes-30min.csv' et le placer dans le même
#    répertoire que ce script.

#******************************************************************
#*** PROGRAMME EN LANGAGE R avec RSTUDIO **************************
#******************************************************************

# Charger les librairies nécessaires
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

# Lire et nettoyer les données de consommation en une seule passe avec dplyr
# On utilise read.csv2 pour les fichiers CSV avec ";" comme séparateur (courant en France).
# On saute les premières lignes, on nomme les colonnes, et on spécifie l'encodage.
# La colonne "nature" est ignorée au chargement (colClasses = "NULL") pour plus d'efficacité.
data_cleaned <- read.csv2(
  "mes-puissances-atteintes-30min.csv",
  skip = 2,
  col.names = c("heure", "conso", "nature"),
  colClasses = c("character", "integer", "NULL"),
  encoding = "latin1"
) %>%
  # Filtrer les lignes potentiellement vides
  filter(heure != "" | !is.na(conso)) %>%
  # Extraire la date qui se trouve sur sa propre ligne
  mutate(date = ifelse(is.na(conso), heure, NA)) %>%
  # Propager la date aux lignes de consommation correspondantes
  fill(date, .direction = "down") %>%
  # Garder uniquement les lignes avec des données de consommation
  filter(!is.na(conso))

# Transformer les données et créer de nouvelles colonnes de temps
# On utilise une seule passe de `mutate` pour créer les colonnes de date et temps.
# Note : on agrège par heure, perdant la granularité de la demi-heure des données originales.
data_transformed <- data_cleaned %>%
  mutate(
    date = as.Date(date, format = '%d/%m/%Y'),
    heure = hour(hms(heure)),
    annee = year(date),
    anneemois = sprintf("%04d%02d", annee, month(date))
  )

# Calculer la moyenne de la consommation par mois et par heure
moyenne_conso <- data_transformed %>%
  group_by(anneemois, heure) %>%
  summarise(moy_conso = mean(conso, na.rm = TRUE), .groups = 'drop')

# Créer une heatmap avec ggplot2
# Le graphique montre la consommation moyenne (kW) pour chaque heure de la journée (y)
# et chaque mois (x).
ggplot(moyenne_conso, aes(x = anneemois, y = heure, fill = moy_conso)) +
  geom_tile(color = "white", size = 0.1) +
  scale_y_continuous(breaks = 0:23, expand = c(0, 0)) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_fill_gradient(low = "blue", high = "red", name = "Consommation (kWh)") +
  labs(
    title = "Moyenne de la Consommation par Mois et par Heure",
    x = "Mois (AnnéeMois)",
    y = "Heure de la Journée"
  ) +
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )
