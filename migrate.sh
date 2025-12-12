#!/bin/bash

# 🚀 Скрипт автоматической миграции проекта в новый репозиторий

set -e  # Остановка при ошибке

echo "🔄 Начинаем миграцию проекта..."

# Определяем пути
SOURCE_DIR="/Users/user/Documents/Projects/Baltset-USA/ai-service-platform"
TARGET_BASE="/Users/user/Documents/Projects/Github"
TARGET_DIR="$TARGET_BASE/balt-set.ru"
REPO_URL="https://github.com/Heallshoking/balt-set.ru.git"

# 1. Создаём целевую директорию
echo "📁 Создаём директорию $TARGET_DIR..."
mkdir -p "$TARGET_DIR"

# 2. Копируем проект (исключая .git)
echo "📦 Копируем файлы проекта..."
rsync -av --progress "$SOURCE_DIR/" "$TARGET_DIR/" \
    --exclude='.git' \
    --exclude='.DS_Store' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.env' \
    --exclude='ai_service.db' \
    --exclude='venv' \
    --exclude='node_modules'

# 3. Переходим в новую директорию
cd "$TARGET_DIR"

# 4. Инициализируем Git
echo "🔧 Инициализируем Git..."
git init

# 5. Настраиваем Git (если нужно)
if [ -z "$(git config user.name)" ]; then
    echo "👤 Настройте Git перед продолжением:"
    echo "git config user.name 'Your Name'"
    echo "git config user.email 'your.email@example.com'"
fi

# 6. Добавляем remote
echo "🌐 Добавляем remote repository..."
git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"

# 7. Создаём .gitignore если его нет
if [ ! -f .gitignore ]; then
    echo "📝 Создаём .gitignore..."
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
ENV/
env/

# Environment
.env
*.db
*.sqlite
*.sqlite3

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
EOF
fi

# 8. Добавляем все файлы
echo "➕ Добавляем файлы в Git..."
git add .

# 9. Создаём первый коммит
echo "💾 Создаём первый коммит..."
git commit -m "🚀 Initial commit: AI Service Platform

- FastAPI backend
- SQLite database
- Telegram bots integration
- Static frontend pages
- Ready for Timeweb deployment"

echo ""
echo "✅ Миграция завершена успешно!"
echo ""
echo "📍 Проект скопирован в: $TARGET_DIR"
echo "🔗 Remote настроен на: $REPO_URL"
echo ""
echo "🚀 Следующие шаги:"
echo "   cd $TARGET_DIR"
echo "   git push -u origin main"
echo ""
