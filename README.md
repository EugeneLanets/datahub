# API Агрегатор - Laravel Backend

Проект представляет собой API агрегатор на Laravel с использованием Docker для развертывания всех необходимых сервисов.

## Требования к системе

- Docker и Docker Compose
- Git
- Минимум 2GB свободной оперативной памяти
- Свободный порт 8000 для веб-сервера
- Свободный порт 6379 для Redis (опционально)

## Структура проекта
```text
├── docker/
│   ├── nginx/
│   │   └── default.conf      # Конфигурация Nginx
│   └── php/
│       └── Dockerfile        # Dockerfile для PHP-FPM
├── src/                      # Laravel приложение
├── docker-compose.yml        # Конфигурация Docker Compose
└── README.md                # Документация проекта
```

## Установка и настройка

### 1. Клонирование репозитория

```bash
git clone <repository-url>
cd api-aggregator
```

### 2. Запуск Docker-контейнеров

```bash
docker compose up -d
```

Эта команда запустит следующие сервисы:
- **app** - PHP-FPM контейнер с Laravel
- **webserver** - Nginx веб-сервер
- **db** - PostgreSQL база данных
- **redis** - Redis для кеширования

### 3. Установка Laravel

Поскольку папка src изначально пуста, необходимо установить Laravel внутри контейнера:

```bash
docker compose exec app composer create-project laravel/laravel .
```

Если папка src уже содержит файлы Laravel, то можно пропустить этот шаг.

### 4. Настройка переменных окружения

Если файл src/.env не существует, скопируйте файл с примером переменных окружения:

```bash
cp src/.env.example src/.env
```

Отредактируйте файл `src/.env` и убедитесь, что следующие переменные установлены корректно:

```env
DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=postgres
DB_PASSWORD=postgres

CACHE_STORE=redis
REDIS_HOST=redis
REDIS_PORT=6379
```

### 5. Установка зависимостей Laravel

```bash
# Установка PHP зависимостей (если вы не устанавливали Laravel а он уже был в репозитории)
docker compose exec app composer install

# Генерация ключа приложения (Если APP_KEY в .env пустой)
docker compose exec app php artisan key:generate

# Применение миграций
docker compose exec app php artisan migrate
```

### 6. Создание файла для проверки

Создайте копию настроенного .env файла для проверяющего:

```bash
cp src/.env src/.env.review
```

## Доступ к приложению

После успешного запуска приложение будет доступно по адресу:
- **Веб-интерфейс**: http://localhost:8000

## Тестирование

### Проверка работоспособности системы

```bash
# Проверка версии Laravel
docker compose exec app php artisan --version

# Проверка доступности главной страницы
curl http://localhost:8000
```

## Полезные команды

```bash
# Просмотр логов
docker compose logs -f app

# Остановка контейнеров
docker compose down

# Перезапуск контейнеров
docker compose restart

# Выполнение artisan команд внутри контейнера
docker compose exec app php artisan <command>

# Подключение к базе данных
docker compose exec db psql -U postgres -d laravel
```

## Решение проблем

### Порт 8000 занят
Измените порт в `docker-compose.yml`:
```yaml
webserver:
  ports:
    - "8001:80"  # Используйте другой порт
```
### Проблемы с правами доступа

```bash
docker compose exec app chown -R www-data:www-data /var/www/html
```
## Очистка Docker

```bash
docker compose down -v  # Удалит контейнеры и volumes
docker system prune     # Очистит неиспользуемые ресурсы
```

## Developer
Евгений Lanets, [Telegram](https://t.me/Lanets) 