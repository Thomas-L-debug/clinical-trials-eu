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

# Cible par défaut
.DEFAULT_GOAL := help

.PHONY: help up up-fast down build rebuild shell pub-get run-web doctor analyze test format lint clean logs prune

# ====================== AIDE ======================
## help          : Affiche cette aide
help:
	@echo "${GREEN}════════════════════════════════════════════════════════════${RESET}"
	@echo "${GREEN}  ${PROJECT_NAME} - Commandes disponibles${RESET}"
	@echo "${GREEN}════════════════════════════════════════════════════════════${RESET}"
	@awk '/^[a-zA-Z\-_0-9%]+:/ { \
		helpCommand = $$1; \
		if (match(lastLine, /^## /)) { \
			printf "  ${YELLOW}%-15s${RESET} %s\n", \
				helpCommand, substr(lastLine, 4) \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ""

# ====================== DOCKER ======================
## up            : Build + lance (premier lancement)
up:
	docker compose up --build -d
	@echo "${GREEN}✅ Application lancée !${RESET}"
	@echo "   Web → http://localhost:${PORT_WEB}"

## up-fast       : Lance sans rebuild (rapide)
up-fast:
	docker compose up -d
	@echo "${GREEN}✅ Application lancée (fast mode)!${RESET}"
	@echo "   Web → http://localhost:${PORT_WEB}"

## down          : Arrête tous les containers
down:
	docker compose down --remove-orphans

## rebuild       : Tout reconstruire + relancer
rebuild: down build up

## build         : Reconstruit l'image
build:
	docker compose build --no-cache

## logs          : Voir les logs en temps réel
logs:
	docker compose logs -f ${FLUTTER_SERVICE}

# ====================== FLUTTER ======================
## shell         : Terminal dans le container
shell:
	docker compose exec ${FLUTTER_SERVICE} bash

## pub-get       : Mise à jour packages
pub-get:
	docker compose exec ${FLUTTER_SERVICE} flutter pub get

## run-web       : Lance l'app web
run-web:
	docker compose exec ${FLUTTER_SERVICE} flutter run -d web --web-port=${PORT_WEB} --web-browser-flag="--disable-web-security"

## doctor        : Vérification Flutter
doctor:
	docker compose exec ${FLUTTER_SERVICE} flutter doctor

# ====================== QUALITÉ ======================
## lint          : Format + analyze
lint: format analyze

## format        : Formate le code
format:
	docker compose exec ${FLUTTER_SERVICE} dart format lib/

## analyze       : Analyse statique
analyze:
	docker compose exec ${FLUTTER_SERVICE} flutter analyze

# ====================== NETTOYAGE ======================
## clean         : Nettoyage complet
clean:
	docker compose exec ${FLUTTER_SERVICE} flutter clean
	docker compose down --rmi local --remove-orphans

## prune         : Nettoie cache Docker
prune:
	docker system prune -f --volumes