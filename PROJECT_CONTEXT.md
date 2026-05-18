# Project Context - Clinical Trials EU Vulgarisation

## Objectif
Application Flutter multiplateforme permettant à tout le monde de consulter et **comprendre facilement** les essais cliniques européens (CTIS - EMA).

- Récupération automatique via API CTIS
- **Vulgarisation des résumés** (LLM Ollama local + GPU)
- Stockage PostgreSQL
- Interface simple et accessible

## Architecture actuelle (18 mai 2026)

### Stack
- **Frontend** : Flutter (web + Android + futur iOS)
- **Backend** : Dart + Shelf
- **Base de données** : PostgreSQL 16
- **LLM** : Ollama (llama3.1:8b) avec GPU NVIDIA RTX 2060
- **Containerisation** : Docker + docker-compose (profiles dev)
- **Outils** : Makefile, GitHub Actions (à finaliser)

### Structure du projet

/clinical-trials-eu
├── flutter_app/
├── backend/
│   ├── bin/
│   │   ├── server.dart
│   │   └── vulgarize.dart          ← Nouveau : vulgarisation batch LLM
│   ├── lib/
│   │   ├── models/trial.dart
│   │   ├── repositories/trial_repository.dart
│   │   ├── database.dart
│   │   └── router.dart
│   └── ...
├── docker/
├── database/migrations/
├── Makefile
├── docker-compose.yml
└── PROJECT_CONTEXT.md


### Fonctionnalités implémentées

**✅ Pipeline données**
- Récupération + insertion de ~10 000 essais
- Page HTML avec recherche + pagination

**✅ Vulgarisation LLM (nouveau)**
- Script `bin/vulgarize.dart` complet (batch de 20-30 essais)
- Prompt structuré en JSON + règles légales strictes
- Stockage dans `vulgarized_fr` (format JSON)
- Support GPU via Ollama
- Timer + progression dans les logs
- `make data-vulgarize` et `make data-vulgarize-all`

**✅ Docker**
- Services : postgres, backend, ollama (GPU), flutter-dev
- `make dev`, `make backend-rebuild`

### Prochaines étapes prioritaires (dans l’ordre)

1. **Amélioration du prompt** LLM (ton encore plus prudent)
2. Affichage joli des résumés vulgarisés sur la page HTML
3. Intégration dans l’application Flutter (web d’abord)
4. Filtres avancés (phase, statut, maladie, pays)
5. CI/CD GitHub Actions complet
6. Passage en production

## Commandes utiles

```bash
make dev                    # Tout lancer (dev)
make backend-rebuild        # Rebuild backend après modification
make data-vulgarize         # Vulgariser un batch (~20-30 essais)
make data-vulgarize-all     # Tout vulgariser (boucle)
make db-shell               # Accéder à PostgreSQL
```

Statut actuel : Pipeline complet données → vulgarisation LLM → stockage.
Base très solide, vulgarisation fonctionnelle et prête à scaler.