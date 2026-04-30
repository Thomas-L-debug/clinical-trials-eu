# Clinical Trials EU - Project Context

**Projet :** Application Flutter pour vulgariser les essais cliniques européens  
**GitHub :** https://github.com/Thomas-L-debug/clinical-trials-eu  
**Date dernière mise à jour :** 30 avril 2026

## Stack Technique Actuelle

### Architecture Globale
- **Frontend** : Flutter (Web + futur Android/iOS)
- **Backend** : Dart + Shelf (même langage que Flutter)
- **Base de données** : PostgreSQL 16
- **Infrastructure** : Docker multi-stage + docker-compose
- **Outils** : Makefile, Git, WSL Ubuntu

### Structure du Projet

clinical-trials-eu/
├── flutter_app/              # Application Flutter
├── backend/                  # API Dart Shelf
│   ├── bin/
│   │   ├── server.dart
│   │   └── fetch_ctis.dart
│   ├── lib/
│   └── pubspec.yaml
├── data/                     # Scripts & données brutes CTIS
├── database/migrations/      # Migrations SQL
├── docker/
│   ├── dev/                  # Flutter + Nginx
│   └── backend/              # Dockerfile Backend
├── PROJECT_CONTEXT.md
├── Makefile
├── .gitignore
└── .dockerignore


### Commandes Principales (Makefile)

```bash
make help                  # Liste toutes les commandes
make dev                   # Mode développement Flutter (hot-reload)
make backend-run           # Lancer le backend (port 8081)
make data-fetch            # Récupérer essais depuis API CTIS
make db-up                 # Lancer seulement PostgreSQL
make db-shell              # Accéder à psql
make down                  # Tout arrêter
```

### État Actuel (30 avril 2026)

- Infrastructure Docker stable (multi-stage + profiles dev/prod)
- Backend Shelf fonctionnel avec connexion PostgreSQL
- API /health et /trials opérationnelles
- Script fetch_ctis.dart → récupère 50 essais par page (API CTIS officielle)
- Base de données prête avec table trials
- .gitignore et .dockerignore optimisés
- Hot-reload Flutter + Nginx en production-like

### Prochaines Étapes Prioritaires

- Insertion automatique des données CTIS dans PostgreSQL
- Création du modèle Trial + mapping complet
- Endpoint d’insertion + vulgarisation des résumés (LLM)
- Connexion Flutter → Backend
- Cron job quotidien + CI/CD