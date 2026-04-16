# Запуск заданий 3, 4 и 5 в Docker

## Структура проекта

```
project/
├── docker-compose.yml          # Описание сервисов
├── Dockerfile.jupyter          # Образ JupyterLab с PySpark и psycopg2
├── init-db/
│   └── 01_load_demo.sh         # Авто-загрузка дампа demo при первом старте
├── dumps/                      # ← СЮДА кладём дамп БД demo
│   └── demo-*.sql.gz           # см. edu.postgrespro.ru (напр. demo-20250901-3m.sql.gz)
├── datasets/                   # ← СЮДА кладём CSV-датасет для заданий 4 и 5
│   └── aggrigation_logs_per_week.csv
└── notebooks/                  # ← Здесь лежат ноутбуки
    ├── Task_3_completed.ipynb
    ├── Task_4_completed.ipynb
    └── Task_5_completed.ipynb
```

---

## Быстрый старт

### 1. Установите Docker и Docker Compose

- **Windows / macOS**: скачайте [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Linux**:
  ```bash
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER   # добавляем себя в группу (нужен перелогин)
  ```

### 2. Подготовьте файлы

```bash
# Клонируйте или создайте папку проекта и перейдите в неё
mkdir project && cd project

# Создайте вложенные папки
mkdir -p dumps datasets notebooks init-db
```

Скопируйте файлы проекта:
- `docker-compose.yml` → `project/`
- `Dockerfile.jupyter` → `project/`
- `init-db/01_load_demo.sh` → `project/init-db/`
- Ноутбуки `Task_*_completed.ipynb` → `project/notebooks/`
- CSV-файл `aggrigation_logs_per_week.csv` → `project/datasets/`

### 3. Загрузите дамп базы данных demo (Задание 3)

Актуальные файлы перечислены на странице [демо-базы Postgres Pro](https://postgrespro.com/education/demodb). Скрипт инициализации подхватывает любой файл вида `dumps/demo-*.sql.gz`.

Пример (небольшой дамп за 3 месяца, ~133 МБ в архиве):

```bash
curl -L -o dumps/demo-20250901-3m.sql.gz \
     "https://edu.postgrespro.ru/demo-20250901-3m.sql.gz"
```

**Windows (PowerShell):** из корня проекта можно выполнить `powershell -ExecutionPolicy Bypass -File scripts\download-demo-dump.ps1`

> Поддерживаются форматы: `.sql.gz` (сжатый) и `.sql` (обычный).

### 4. Запустите стек

```bash
# Первый запуск: собрать образ + стартовать (занимает ~3-5 минут)
docker compose up --build

# Последующие запуски (быстро):
docker compose up
```

### 5. Откройте JupyterLab

Перейдите в браузере по адресу: **http://localhost:8888**

> Пароль не требуется (токен отключён).

Откройте папку `work/` — там находятся все три ноутбука.

---

## Описание сервисов

| Сервис     | Образ                              | Порт  | Назначение                          |
|------------|------------------------------------|-------|-------------------------------------|
| `postgres` | `postgres:16`                      | 5432  | СУБД: базы `demo` (Task 3) и `test` (Task 4) |
| `jupyter`  | Собирается из `Dockerfile.jupyter` | 8888  | JupyterLab: Tasks 3, 4, 5           |

---

## Подключение к PostgreSQL

### Из ноутбуков (уже настроено)

В каждом ноутбуке переменные окружения читаются автоматически:

```python
import os, psycopg2

conn = psycopg2.connect(
    dbname='demo',                                  # для Task 3
    user=os.environ.get('POSTGRESQL_USER', 'postgres'),
    password=os.environ.get('POSTGRESQL_PASSWORD', 'postgres'),
    host=os.environ.get('POSTGRESQL_HOST', 'localhost'),
)
```

### Из терминала (psql напрямую)

```bash
# Подключение к БД demo
docker compose exec postgres psql -U postgres -d demo

# Подключение к БД test
docker compose exec postgres psql -U postgres -d test
```

### Из внешнего клиента (DBeaver, DataGrip и т.п.)

```
Host:     localhost
Port:     5432
User:     postgres
Password: postgres
Database: demo   (или test)
```

---

## Загрузка базы данных вручную

Если автозагрузка не сработала (БД `demo` пустая):

```bash
# Способ 1: через Docker Compose
docker compose exec -T postgres bash -c \
  "gunzip -c /dumps/demo-small.sql.gz | psql -U postgres"

# Способ 2: напрямую через psql с хоста (если установлен)
gunzip -c dumps/demo-small.sql.gz | \
  psql -h localhost -U postgres
```

---

## Работа с разными версиями дампа

| Файл                    | Размер БД | Рекомендуется для        |
|-------------------------|-----------|--------------------------|
| `demo-small.sql.gz`     | ~300 МБ   | Разработка и отладка     |
| `demo-medium.sql.gz`    | ~1 ГБ     | Тестирование оптимизации |
| `demo-big.sql.gz`       | ~3 ГБ     | Боевая нагрузка и Spark  |

---

## Управление контейнерами

```bash
# Остановить (данные сохраняются)
docker compose stop

# Остановить и удалить контейнеры (данные в volume остаются)
docker compose down

# Полный сброс: удалить контейнеры + volume с данными PostgreSQL
docker compose down -v

# Посмотреть логи
docker compose logs -f postgres
docker compose logs -f jupyter

# Открыть bash внутри контейнера
docker compose exec jupyter bash
docker compose exec postgres bash
```

---

## Пересборка образа после изменений в Dockerfile

```bash
docker compose up --build
```

---

## Часто встречающиеся проблемы

### JupyterLab не запускается / порт занят

```bash
# Проверить, какой процесс занимает порт 8888
lsof -i :8888        # macOS/Linux
netstat -aon | findstr 8888   # Windows

# Изменить порт в docker-compose.yml:
# ports:
#   - "8890:8888"     ← используем 8890 снаружи
```

### PostgreSQL не принимает подключения

```bash
# Проверить статус healthcheck
docker compose ps

# Посмотреть логи postgres
docker compose logs postgres
```

### PySpark: нет Java

Образ `jupyter/pyspark-notebook` включает Java 17.  
Если возникает `JAVA_HOME is not set`:

```bash
docker compose exec jupyter bash -c "java -version"
```

### Медленная загрузка большого дампа

Это нормально: загрузка `demo-big.sql.gz` может занимать 10-30 минут.  
Прогресс можно отслеживать:

```bash
docker compose logs -f postgres
```

---

## Версии ПО

| Компонент  | Версия    |
|------------|-----------|
| PostgreSQL | 16        |
| Python     | 3.11      |
| PySpark    | 3.5.0     |
| JupyterLab | 4.2       |
| psycopg2   | 2.9.9     |
| pandas     | 2.2.2     |
| matplotlib | 3.8.4     |
