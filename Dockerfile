FROM ghcr.io/flutter/flutter:3.29.3 AS builder
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html