.PHONY: up down build shell pub-get run-web doctor

up:
	docker compose up --build -d

down:
	docker compose down

build:
	docker compose build

shell:
	docker compose exec flutter-dev bash

pub-get:
	docker compose exec flutter-dev flutter pub get

run-web:
	docker compose exec flutter-dev flutter run -d web --web-port=8080

doctor:
	docker compose exec flutter-dev flutter doctor
