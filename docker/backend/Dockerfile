FROM dart:stable

WORKDIR /app/backend

# 1. Copie seulement les fichiers de dépendances d'abord (pour le cache)
COPY backend/pubspec.* ./
RUN dart pub get --no-precompile

# 2. Copie tout le reste du code
COPY backend/ .

# 3. Vérification explicite
RUN ls -la && dart pub get --offline && echo "✅ Dependencies OK"

EXPOSE 8081

CMD ["dart", "run", "bin/server.dart"]
