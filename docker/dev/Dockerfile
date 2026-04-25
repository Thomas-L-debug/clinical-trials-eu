FROM cirrusci/flutter:stable

RUN apt-get update && apt-get install -y \
    git curl unzip libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY flutter_app/ .

EXPOSE 8080

CMD ["flutter", "run", "-d", "web", "--web-port=8080"]
