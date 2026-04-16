#!/bin/bash
# ============================================================
#  Скрипт инициализации PostgreSQL (выполняется 1 раз при
#  первом создании контейнера — только если pg_data пуст).
#
#  Размещение: ./init-db/01_load_demo.sh
# ============================================================

set -e

echo "==> [init] Проверяем наличие дампа demo БД..."

DUMP_FILE=""

# Ищем дамп (сначала сжатый, потом обычный)
for f in /dumps/demo-*.sql.gz /dumps/demo-*.sql; do
    if [ -f "$f" ]; then
        DUMP_FILE="$f"
        break
    fi
done

if [ -z "$DUMP_FILE" ]; then
    echo "==> [init] WARN: дамп demo не найден в /dumps/."
    echo "==> [init] Создаём пустую БД demo и БД test."
    psql -U postgres -c "CREATE DATABASE demo;"
    psql -U postgres -c "CREATE DATABASE test;"
    exit 0
fi

echo "==> [init] Найден дамп: $DUMP_FILE"

# Создаём чистую БД demo (pg_dump включает DROP DATABASE IF EXISTS)
psql -U postgres -c "CREATE DATABASE demo;" 2>/dev/null || true

echo "==> [init] Загружаем дамп в БД demo..."
if [[ "$DUMP_FILE" == *.gz ]]; then
    gunzip -c "$DUMP_FILE" | psql -U postgres -d demo
else
    psql -U postgres -d demo -f "$DUMP_FILE"
fi

echo "==> [init] БД demo успешно загружена!"

# Создаём тестовую БД для Task 4
psql -U postgres -c "CREATE DATABASE test;" 2>/dev/null || true
echo "==> [init] БД test создана."

echo "==> [init] Инициализация завершена."
