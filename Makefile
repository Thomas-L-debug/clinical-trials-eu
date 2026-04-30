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
	@echo "${YELLOW}🚀 Lancement mode DEV (hot-reload)...${RESET}"
	docker compose --profile dev up -d --build flutter-dev

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

## rebuild       : Tout reconstruire + relancer dev
rebuild: down build dev

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

# ====================== DATA ======================
## data-fetch    : Récupère les essais cliniques CTIS
data-fetch:
	cd backend && dart run bin/fetch_ctis.dart

## data-fetch-all : Récupère plusieurs pages (à venir)
data-fetch-all:
	@echo "À implémenter plus tard"