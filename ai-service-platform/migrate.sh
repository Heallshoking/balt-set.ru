#!/bin/bash
set -e

echo "=================================================="
echo "🚀 МИГРАЦИЯ В НОВУЮ СТРУКТУРУ BALT-SET.RU"
echo "=================================================="

# Целевые пути
TARGET_BASE="/Users/user/Documents/Projects/Github/balt-set.ru"
CURRENT_DIR=$(pwd)

echo ""
echo "📂 Текущая папка: $CURRENT_DIR"
echo "📍 Целевая папка: $TARGET_BASE"

# Создать целевую структуру
echo ""
echo "📁 Создаю папки..."
mkdir -p "$TARGET_BASE"

# Инициализировать Git в корне
echo ""
echo "🔧 Настраиваю Git в корне..."
cd "$TARGET_BASE"

if [ ! -d ".git" ]; then
    git init
    echo "✅ Git инициализирован"
else
    echo "✅ Git уже есть"
fi

# Создать .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
.Python
venv/
.env
*.db
*.sqlite*
*.log

# IDEs
.vscode/
.idea/

# OS
.DS_Store
EOF
echo "✅ .gitignore создан"

# Переместить ai-service-platform
echo ""
echo "📦 Перемещаю ai-service-platform..."

if [ -d "$TARGET_BASE/ai-service-platform" ]; then
    echo "⚠️  Удаляю старую копию..."
    rm -rf "$TARGET_BASE/ai-service-platform"
fi

# Скопировать (безопаснее чем mv)
cp -R "$CURRENT_DIR" "$TARGET_BASE/ai-service-platform"
echo "✅ Скопировано в $TARGET_BASE/ai-service-platform"

# Настроить remote
echo ""
echo "🌐 Настраиваю GitHub remote..."
cd "$TARGET_BASE"

git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/Heallshoking/balt-set.ru.git
git remote -v

# Первый коммит
echo ""
echo "💾 Создаю первый коммит..."
git add .
git commit -m "🎉 Initial commit: AI Service Platform + structure" || echo "Коммит уже есть"

# Переименовать ветку
git branch -M main

echo ""
echo "=================================================="
echo "✅ МИГРАЦИЯ ЗАВЕРШЕНА!"
echo "=================================================="
echo ""
echo "📍 Новый путь: $TARGET_BASE/ai-service-platform"
echo "🌐 GitHub: https://github.com/Heallshoking/balt-set.ru"
echo ""
echo "📝 СЛЕДУЮЩИЕ ШАГИ:"
echo ""
echo "1. Создайте репозиторий на GitHub:"
echo "   https://github.com/new"
echo "   Имя: balt-set.ru"
echo ""
echo "2. Выполните первый push:"
echo "   cd $TARGET_BASE"
echo "   git push -u origin main"
echo ""
echo "3. Настройте GitHub Desktop:"
echo "   File → Add Local Repository"
echo "   Выберите: $TARGET_BASE"
echo ""
echo "4. Обновите Timeweb:"
echo "   Репозиторий: Heallshoking/balt-set.ru"
echo "   Root: ai-service-platform"
echo ""
