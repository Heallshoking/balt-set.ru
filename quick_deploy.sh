#!/bin/bash

# 🚀 БЫСТРЫЙ ДЕПЛОЙ - Мгновенные изменения на app.balt-set.ru
# Использование: ./quick_deploy.sh "описание изменений"

set -e

COMMIT_MSG="${1:-Quick MVP update}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 БЫСТРЫЙ ДЕПЛОЙ НА app.balt-set.ru"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Показать изменения
echo "📝 Изменённые файлы:"
git status --short
echo ""

# Добавить все изменения
echo "➕ Добавляем файлы..."
git add .

# Коммит
echo "💾 Создаём коммит: $COMMIT_MSG"
git commit -m "$COMMIT_MSG" || echo "⚠️ Нет новых изменений"

# Push
echo "🚀 Отправляем на GitHub..."
git push origin main

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ГОТОВО!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⏰ Изменения появятся на app.balt-set.ru через ~2-3 минуты"
echo "🌐 Проверьте: https://app.balt-set.ru"
echo ""
echo "📊 Следите за деплоем: https://timeweb.cloud/my/apps"
echo ""
