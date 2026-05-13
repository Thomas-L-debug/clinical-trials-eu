# Project Context - Clinical Trials EU Vulgarisation

## Objectif
Application Flutter multiplateforme (Android → iOS → Web) permettant à tout le monde de consulter et comprendre facilement les **essais cliniques européens** (CTIS - EMA).

- Récupération automatique des données via l’API CTIS officielle
- Vulgarisation des résumés techniques (LLM à venir)
- Stockage dans PostgreSQL
- Interface simple et accessible

## Architecture actuelle (13 mai 2026)

### Stack
- **Frontend** : Flutter (web + Android + futur iOS)
- **Backend** : Dart + Shelf (même langage que Flutter → cohérence maximale)
- **Base de données** : PostgreSQL 16
- **Containerisation** : Docker + docker-compose (profiles dev/prod)
- **Outils** : Makefile, GitHub Actions (CI/CD à finaliser)

### Structure du projet

/clinical-trials-eu
├── flutter_app/          ← Application Flutter
├── backend/
│   ├── bin/
│   ├── lib/
│   │   ├── models/trial.dart
│   │   ├── repositories/trial_repository.dart
│   │   ├── database.dart
│   │   └── router.dart          ← Page HTML / + API JSON
│   └── data/                    ← JSON de backup
├── docker/
├── database/migrations/
├── Makefile
├── docker-compose.yml
└── project_context.md

### Fonctionnalités implémentées
- ✅ Connexion PostgreSQL robuste (Docker + host variable)
- ✅ Modèle `Trial` complet + `fromCtisJson`
- ✅ Repository avec upsert (Sql.named)
- ✅ Page d’accueil HTML dynamique (`/`) avec liste des essais
- ✅ Endpoint `/trials` JSON
- ✅ Commande `make data-fetch-docker` qui récupère + insère 50 essais
- ✅ Docker multi-container (postgres + backend + flutter-dev)

### Prochaines étapes prioritaires (dans l’ordre)
1. Pagination complète CTIS + synchronisation incrémentale
2. Service de vulgarisation LLM (Ollama ou Groq)
3. Filtres avancés (phase, statut, maladie, pays)
4. CI/CD GitHub Actions (build Flutter + Docker push)
5. Authentification / admin (futur)
6. Passage en production

## Commandes utiles
- `make dev` → tout en local
- `make backend-run` / `make data-fetch-docker`
- `make backend-rebuild` → après modification de code

**Statut** : Pipeline données → DB → affichage **fonctionnel**. Base solide pour scaler.