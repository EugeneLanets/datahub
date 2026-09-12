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
├── setup.sh                  # Скрипт автоматического разворачивания
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
docker compose up -d --build
```

Эта команда запустит следующие сервисы:
- **app** - PHP-FPM контейнер с Laravel
- **webserver** - Nginx веб-сервер
- **db** - PostgreSQL база данных
- **redis** - Redis для кеширования

### 3. Разворачивание проекта

Есть два способа развернуть проект внутри контейнера `app`: автоматический (рекомендуется) и ручной, шаг за шагом.

#### Вариант A: автоматический запуск через setup.sh

Скрипт `setup.sh` сам выполняет весь путь: установку Laravel/зависимостей, подготовку `.env`, генерацию `APP_KEY`, ожидание готовности PostgreSQL, миграции, создание `.env.review` и выставление корректных прав доступа. Скрипт безопасно запускать повторно — он проверяет текущее состояние на каждом шаге и не перезаписывает уже настроенные файлы.

```bash
docker compose exec app sh setup.sh
```

После завершения работы скрипта приложение будет полностью готово — переходите сразу к разделу «Доступ к приложению».


#### Вариант B: ручная установка по шагам

Если нужно выполнить каждый шаг вручную (например, для отладки) — можно повторить те же действия, что делает `setup.sh`, вручную.

**3.1. Установка зависимостей Laravel**

Установить зависимости Laravel: 

```bash
docker compose exec app composer install
```

**3.2. Настройка переменных окружения**

Для проведения ревью в проект добавлен файл `src/.env.review`, его содержимое необходимо добавить в `src/.env`

```bash
cp src/.env.review src/.env
```
Если файл `src/.env.review` не существует, необходимо скопировать файл с примером переменных окружения `src/.env.example` 

```bash
cp src/.env.example src/.env
```

Необходимо проверить, что следующие переменные корректно установлены в файле `src/.env`, если значения не совпадают - установить:

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

**3.3. Генерация ключа приложения**

Если `APP_KEY` в `.env` пустой:

```bash
docker compose exec app php artisan key:generate
```

**3.4. Применение миграций**

```bash
docker compose exec app php artisan migrate
```

**3.6. Права доступа**

```bash
docker compose exec app chown -R www-data:www-data /var/www/html
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

### База данных не отвечает сразу после запуска

PostgreSQL может подниматься чуть дольше, чем стартует контейнер `app`. `setup.sh` сам ждёт готовности базы перед миграциями; при ручной установке просто подождите несколько секунд и повторите команду `migrate`.

## Очистка Docker

```bash
docker compose down -v  # Удалит контейнеры и volumes
docker system prune     # Очистит неиспользуемые ресурсы
```

## Developer
Евгений Lanets, [Telegram](https://t.me/Lanets)

## Лицензия
Проект выполнен в рамках стажировки [Preax](https://preax.ru)