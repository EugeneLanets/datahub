FROM php:8.2-fpm-alpine

# Установка зависимостей
RUN apk add --no-cache \
    postgresql-dev \
    libzip-dev \
    zip \
    unzip \
    autoconf \
    g++ \
    make \
    && docker-php-ext-install pdo pdo_pgsql zip \
    && pecl channel-update pecl.php.net \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del autoconf g++ make

# Установка Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html

# Настройка прав доступа
RUN chown -R www-data:www-data /var/www/html