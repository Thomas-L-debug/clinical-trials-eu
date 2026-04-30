# ====================== BASE (Flutter complet) ======================
FROM ghcr.io/cirruslabs/flutter:stable AS base

WORKDIR /app

# Optimisation cache dépendances
COPY flutter_app/pubspec.* ./
RUN flutter pub get

# ====================== BUILDER (pour prod) ======================
FROM base AS builder

COPY flutter_app/ .
RUN flutter clean && \
    flutter build web --release --no-tree-shake-icons --web-renderer html && \
    echo "=== Build web terminé ===" && \
    ls -la build/web

# ====================== DEV (pour hot-reload) ======================
FROM base AS dev

COPY flutter_app/ .

RUN flutter doctor -v

EXPOSE 8080
# CMD simplifié sans flag obsolète
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080", "--web-hostname=0.0.0.0"]

# ====================== PRODUCTION (Nginx léger) ======================
FROM nginx:alpine AS prod

COPY docker/dev/nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/build/web /usr/share/nginx/html

RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]