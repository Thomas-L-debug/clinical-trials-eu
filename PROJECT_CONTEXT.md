# Clinical Trials EU - Setup & Notes de Session

**Projet :** Application Flutter pour vulgariser les essais cliniques européens  
**GitHub :** [https://github.com/Thomas-L-debug/clinical-trials-eu](https://github.com/Thomas-L-debug/clinical-trials-eu)  
**Date dernière mise à jour :** 25 avril 2026

## 1. Environnement Actuel (WSL Ubuntu)

- **Flutter** → `~/development/flutter` (version 3.41.7 stable)
- **Android SDK** → `~/development/android`
- **Java** → OpenJDK 21
- **Docker + docker-compose** installé
- **Git** configuré en SSH

## 2. Commandes Principales (Makefile)

```bash
cd ~/Projects/clinical-trials-eu

make help                 # Voir toutes les commandes
make up                   # Première fois (long) → build + démarrage
make up-fast              # Après le 1er build (rapide)
make down                 # Arrêter tout
make rebuild              # Tout reconstruire + relancer
make shell                # Ouvrir terminal dans le container
make run-web              # Lancer l'app web
make doctor               # Vérifier Flutter
make lint                 # Format + analyze