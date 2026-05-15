# Project Context - Clinical Trials EU Vulgarisation

## Objectif
Application Flutter multiplateforme (Android → iOS → Web) permettant à tout le monde de consulter et comprendre facilement les **essais cliniques européens** (CTIS - EMA).

- Récupération automatique des données via l’API CTIS officielle
- Vulgarisation des résumés techniques (LLM à venir)
- Stockage dans PostgreSQL
- Interface simple et accessible

## Architecture actuelle (15 mai 2026)

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
│   │   └── server.dart
│   ├── lib/
│   │   ├── models/trial.dart          ← fromMap + toJson + fromCtisJson
│   │   ├── repositories/trial_repository.dart  ← searchAndGet + count optimisé
│   │   ├── database.dart              ← Connection v3+ robuste
│   │   └── router.dart                ← page HTML + API JSON avec recherche/pagination
│   └── data/                          ← JSON de backup
├── docker/
├── database/migrations/
├── Makefile
├── docker-compose.yml
└── PROJECT_CONTEXT.md

### Fonctionnalités implémentées
- ✅ Connexion PostgreSQL robuste (Docker + host variable)
- ✅ Modèle `Trial` complet + `fromCtisJson` + `fromMap` + `toJson`
- ✅ Repository avec upsert + searchAndGet + count optimisé
- ✅ Page d’accueil HTML dynamique avec **recherche** + **pagination**
- ✅ Endpoint `/trials` JSON (limit/offset/search)
- ✅ Commande `make data-fetch-all` qui récupère + insère **10 000 essais**
- ✅ Docker multi-container (postgres + backend + flutter-dev)
- ✅ Port backend 8081 / Flutter 8080 (pas de conflit)

### Prochaines étapes prioritaires (dans l’ordre)
1. **Vulgarisation LLM** (Ollama local ou Groq) → résumé simplifié
2. Filtres avancés (phase, statut, maladie, pays) sur la page HTML
3. Amélioration design + responsive de la page d’accueil
4. CI/CD GitHub Actions (build Flutter + Docker push)
5. Application Flutter (web + Android + iOS)
6. Authentification / admin (futur)
7. Passage en production

## Commandes utiles
- `make dev` → tout en local
- `make backend-rebuild` → après modification backend
- `make data-fetch-all` → sync complète CTIS
- `make backend-run` → lance seulement le backend

**Statut** : **Pipeline données → DB → page HTML fonctionnelle** avec recherche et pagination.  
**10 000 essais** stockés et accessibles. Base très solide pour scaler.