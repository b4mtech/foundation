FROM cgr.dev/chainguard/php:latest-dev AS builder

COPY . /app
USER root
RUN chown -Rf php:php /app
COPY .env.production /app/.env
WORKDIR "/app"
USER php
RUN mkdir ./bootstrap/cache && \
    mkdir -p ./storage/logs && \
    mkdir -p ./storage/framework/sessions && \
    mkdir -p ./storage/framework/testing && \
    mkdir -p ./storage/framework/views && \
    mkdir -p ./storage/framework/cache/data && \
    mkdir -p ./storage/app/public && \
    chown -Rf php:php ./*
RUN composer install --no-ansi --no-interaction --no-scripts --no-suggest --no-progress --no-dev --prefer-dist --optimize-autoloader

FROM node:19-alpine AS node-builder
COPY . /app
RUN cd /app && \
    yarn install && \
    yarn run build

FROM 940080879460.dkr.ecr.us-east-2.amazonaws.com/bandm/php-fpm:dev
# FROM php:fpm-alpine3.17
COPY --from=builder /app /app
COPY --from=node-builder /app/public /app/public
WORKDIR "/app"
COPY storage/credentials.json /app/storage/
RUN chown -Rf www-data:www-data ./* && \
    chmod -Rf 755 ./* && \
    chmod -Rf 777 ./storage/* && \
    chmod -Rf 777 ./bootstrap/cache && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

ENTRYPOINT [ "/usr/bin/php-fpm", "-y", "/etc/php-fpm.conf" ]
