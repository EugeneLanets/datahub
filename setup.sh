#!/bin/sh
# setup.sh
# Выполняется ВНУТРИ контейнера app:
#   docker compose exec app sh setup.sh

set -e

echo "=== [1/5] Установка Laravel-зависимостей ==="
composer install --no-interaction

echo "=== [2/5] Подготовка .env ==="
if [ ! -f ".env" ]; then
    if [ -f ".env.review" ]; then
        echo ".env отсутствует, копирование из .env.review..."
        cp .env.review .env
    elif [ -f ".env.example" ]; then
        echo ".env отсутствует, копирование из .env.example..."
        cp .env.example .env

        echo "Копирование параметров подключения к Postgres/Redis..."
        for pair in \
            "DB_CONNECTION=pgsql" \
            "DB_HOST=db" \
            "DB_PORT=5432" \
            "DB_DATABASE=laravel" \
            "DB_USERNAME=postgres" \
            "DB_PASSWORD=postgres" \
            "CACHE_STORE=redis" \
            "REDIS_HOST=redis" \
            "REDIS_PORT=6379"
        do
            key=$(echo "$pair" | cut -d= -f1)
            grep -v "^#*${key}=" .env > .env.tmp && mv .env.tmp .env
            echo "$pair" >> .env
        done
    else
        echo "Не найдено ни .env.review, ни .env.example. Прерываю."
        exit 1
    fi
else
    echo ".env уже существует, пропускаю."
fi

echo "=== [3/5] Проверка APP_KEY ==="
if ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
    echo "APP_KEY не установлен, генерация..."
    php artisan key:generate --force
else
    echo "APP_KEY уже установлен."
fi

echo "=== [4/5] Миграции ==="
php -r "new PDO('pgsql:host=${DB_HOST:-db};port=${DB_PORT:-5432};dbname=${DB_DATABASE:-laravel}', '${DB_USERNAME:-postgres}', '${DB_PASSWORD:-postgres}');" \
    || { echo "Не удалось подключиться к PostgreSQL. Проверьте .env. Прерываю."; exit 1; }

php artisan migrate --force

echo "=== [5/5] Выставление прав ==="
chown -R www-data:www-data /var/www/html

echo ""
echo "Готово! Откройте http://localhost:8000"