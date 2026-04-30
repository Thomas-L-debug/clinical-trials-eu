# ===============================================
# Makefile pour Clinical Trials EU
# ===============================================

# Variables
PROJECT_NAME := clinical-trials-eu
FLUTTER_SERVICE := flutter-dev
PORT_WEB := 8080

# Couleurs
GREEN  := $(shell printf "\033[0;32m")
YELLOW := $(shell printf "\033[0;33m")
RESET  := $(shell printf "\033[0m")

.DEFAULT_GOAL := help
.PHONY: help up up-fast down rebuild build run shell pub-get run-web doctor analyze test format lint clean logs prune dev dev-hot

# ====================== AIDE ======================
## help          : Affiche cette aide
help:
	@echo "${GREEN}════════════════════════════════════════════════════════════${RESET}"
	@echo "${GREEN}  ${PROJECT_NAME} - Commandes disponibles${RESET}"
	@echo "${GREEN}════════════════════════════════════════════════════════════${RESET}"
	@awk '/^[a-zA-Z\-_0-9%]+:/ { \
		helpCommand = $$1; \
		if (match(lastLine, /^## /)) { \
			printf "  ${YELLOW}%-18s${RESET} %s\n", \
				helpCommand, substr(lastLine, 4) \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ""

# ====================== DOCKER ======================
## up            : Build + lance (recommandé)
up: build run

## up-fast       : Lance sans rebuild (quand l'image est déjà bonne)
up-fast: run

## run           : Démarre les containers (sans rebuild)
run:
	docker compose up -d
	@echo "${GREEN}✅ Application lancée !${RESET}"
	@echo "   Web → http://localhost:${PORT_WEB}"

## build         : Reconstruit l'image (multi-stage Flutter + Nginx)
build:
	docker compose build --no-cache
	@echo "${GREEN}✅ Image reconstruite avec succès${RESET}"

## rebuild       : Tout nettoyer + reconstruire + relancer
rebuild: down build run

## down          : Arrête et supprime les containers
down:
	docker compose down --remove-orphans

## logs          : Voir les logs en temps réel
logs:
	docker compose logs -f ${FLUTTER_SERVICE}

# ====================== DÉVELOPPEMENT RAPIDE ======================
## dev           : Mode développement avec hot-reload (recommandé pour coder)
dev:
	@echo "${YELLOW}Lancement en mode dev (hot-reload web)...${RESET}"
	docker compose up -d
	docker compose exec ${FLUTTER_SERVICE} flutter run -d web-server \
		--web-port=${PORT_WEB} \
		--web-hostname=0.0.0.0 \
		--no-tree-shake-icons

## dev-hot       : Alias pour dev (plus explicite)
dev-hot: dev

# ====================== FLUTTER ======================
## shell         : Terminal dans le container
shell:
	docker compose exec ${FLUTTER_SERVICE} bash

## pub-get       : flutter pub get
pub-get:
	docker compose exec ${FLUTTER_SERVICE} flutter pub get

## doctor        : flutter doctor
doctor:
	docker compose exec ${FLUTTER_SERVICE} flutter doctor

# ====================== QUALITÉ ======================
## lint          : Format + analyze
lint: format analyze

## format        : Formate le code
format:
	docker compose exec ${FLUTTER_SERVICE} dart format lib/ -l 120

## analyze       : Analyse statique
analyze:
	docker compose exec ${FLUTTER_SERVICE} flutter analyze

# ====================== NETTOYAGE ======================
## clean         : Nettoyage Flutter + Docker
clean:
	docker compose exec ${FLUTTER_SERVICE} flutter clean || true
	docker compose down --rmi local --remove-orphans

## prune         : Nettoie tout le cache Docker
prune:
	docker system prune -af --volumes

# ====================== DÉVELOPPEMENT & PRODUCTION ======================
## dev           : Mode développement avec hot-reload (RECOMMANDÉ)
dev:
	@echo "${YELLOW}🚀 Lancement du mode DEV avec hot-reload...${RESET}"
	@echo "→ Code monté en live depuis ./flutter_app"
	@echo "→ Ouvre http://localhost:8080 une fois lancé"
	docker compose --profile dev up -d --build flutter-dev
	@echo "${GREEN}Container démarré. Attends 5-10s puis ouvre le navigateur.${RESET}"

## prod          : Version production (Nginx)
prod:
	docker compose --profile prod up -d --build flutter-web
	@echo "${GREEN}✅ Production lancée → http://localhost:8080${RESET}"

## down          : Arrête tout
down:
	docker compose --profile dev --profile prod down --remove-orphans