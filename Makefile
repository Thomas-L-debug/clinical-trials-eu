# ===============================================
# Makefile - Clinical Trials EU
# ===============================================

PROJECT_NAME := clinical-trials-eu
PORT_WEB := 8080

GREEN  := $(shell printf "\033[0;32m")
YELLOW := $(shell printf "\033[0;33m")
RESET  := $(shell printf "\033[0m")

.DEFAULT_GOAL := help
.PHONY: help up dev prod down build rebuild db-up db-logs db-shell db-reset logs shell pub-get lint clean

# ====================== AIDE ======================
## help          : Affiche cette aide
help:
	@echo "${GREEN}════════════════════════════════════════════════════════════${RESET}"
	@echo "${GREEN}  ${PROJECT_NAME} - Commandes disponibles${RESET}"
	@echo "${GREEN}════════════════════════════════════════════════════════════${RESET}"
	@awk '/^[a-zA-Z\-_0-9%]+:/ { \
		helpCommand = $$1; \
		if (match(lastLine, /^## /)) { \
			printf "  ${YELLOW}%-15s${RESET} %s\n", helpCommand, substr(lastLine, 4) \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ""

# ====================== DOCKER ======================
## dev           : Mode développement (hot-reload) - RECOMMANDÉ
dev:
	@echo "🚀 Lancement en mode DEV..."
	docker compose --profile dev up -d

## prod          : Version production (Nginx)
prod:
	docker compose --profile prod up -d --build flutter-web
	@echo "${GREEN}✅ Production lancée → http://localhost:${PORT_WEB}${RESET}"

## down          : Arrête tout
down:
	docker compose --profile dev --profile prod down --remove-orphans

## build         : Rebuild toutes les images
build:
	docker compose build --no-cache

## rebuild       : Tout reconstruire + relancer DEV complet (postgres + backend + flutter)
rebuild: down build
	@echo "${YELLOW}🚀 Lancement complet en mode DEV...${RESET}"
	docker compose --profile dev up -d postgres
	docker compose --profile dev up -d backend
	docker compose --profile dev up -d --build flutter-dev
	@echo "${GREEN}✅ Tout est lancé (postgres + backend + flutter-dev)${RESET}"

# ====================== DATABASE ======================
## db-up         : Lance seulement la BDD
db-up:
	docker compose up -d postgres

## db-logs       : Logs Postgres
db-logs:
	docker compose logs -f postgres

## db-shell      : Connexion psql
db-shell:
	docker compose exec postgres psql -U dev -d clinical_trials

## db-reset      : Reset complet de la BDD (⚠️ supprime les données)
db-reset:
	docker compose down -v postgres
	docker compose up -d postgres

# ====================== FLUTTER ======================
## logs          : Logs du container Flutter dev
logs:
	docker compose --profile dev logs -f flutter-dev

## shell         : Terminal dans Flutter dev
shell:
	docker compose --profile dev exec flutter-dev bash

## pub-get       : flutter pub get
pub-get:
	docker compose --profile dev exec flutter-dev flutter pub get

# ====================== QUALITÉ ======================
## lint          : Format + analyze
lint:
	docker compose --profile dev exec flutter-dev dart format lib/ -l 120
	docker compose --profile dev exec flutter-dev flutter analyze

## clean         : Nettoyage
clean:
	docker compose --profile dev exec flutter-dev flutter clean
	docker compose down --rmi local --remove-orphans

# ====================== BACKEND ======================
## backend-build  : Build du backend Docker
backend-build:
	docker compose build backend

## backend-run    : Lance le backend dans Docker (recommandé)
backend-run:
	docker compose --profile dev up -d backend

## backend-logs   : Voir les logs du backend
backend-logs:
	docker compose logs -f backend

## backend-shell  : Terminal dans le backend
backend-shell:
	docker compose exec backend bash

## backend-rebuild : Rebuild complet + nettoyage cache si besoin
backend-rebuild:
	@echo "${YELLOW}🔨 Rebuild backend...${RESET}"
	docker compose --profile dev down backend
	@echo "🧹 Nettoyage cache Docker..."
	docker builder prune -f
	docker compose build backend --no-cache
	docker compose --profile dev up -d backend
	@echo "${GREEN}✅ Backend rebuildé${RESET}"
	@sleep 2
	@docker compose --profile dev logs backend --tail=30

# ====================== DATA ======================
## data-fetch    : Récupère les essais cliniques CTIS
data-fetch:
	cd backend && dart run bin/fetch_ctis.dart

## data-fetch-docker : Récupère les essais via le container (recommandé)
data-fetch-docker:
	@echo "${YELLOW}🚀 Fetch via Docker container...${RESET}"
	docker compose --profile dev exec backend dart run bin/fetch_ctis.dart

## data-fetch-all : Sync complète avec pagination (nouvelle commande)
data-fetch-all:
	@echo "${YELLOW}🚀 Fetch complet CTIS (toutes les pages)...${RESET}"
	docker compose --profile dev exec backend dart run bin/fetch_ctis.dart --full

## data-fetch-inc    : Mise à jour incrémentale (quelques pages récentes)
data-fetch-inc:
	docker compose --profile dev exec backend dart run bin/fetch_ctis.dart

# Vulgarisation LLM (Ollama)
data-vulgarize:
	@echo "🧠 Vulgarisation des essais (batch JSON structuré)..."
	docker compose --profile dev run --rm backend dart run bin/vulgarize.dart

data-vulgarize-all:
	@echo "🧠 Vulgarisation complète en boucle..."
	@while true; do \
		docker compose --profile dev run --rm backend dart run bin/vulgarize.dart || break; \
		sleep 4; \
	done