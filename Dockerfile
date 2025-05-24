FROM dart:stable AS builder
WORKDIR /app
COPY . .
RUN dart pub get
RUN flutter build web

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html