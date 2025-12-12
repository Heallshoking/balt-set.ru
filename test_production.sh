#!/bin/bash

# 🧪 ТЕСТОВЫЙ СКРИПТ ДЛЯ PRODUCTION READINESS
# Автоматическая проверка всех компонентов

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 ТЕСТИРОВАНИЕ AI SERVICE PLATFORM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Счётчики
PASSED=0
FAILED=0

# Функция для проверки
test_endpoint() {
    local name=$1
    local url=$2
    local expected_code=${3:-200}
    
    echo -n "Проверка $name... "
    
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$response_code" = "$expected_code" ]; then
        echo -e "${GREEN}✅ OK${NC} ($response_code)"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC} (ожидали $expected_code, получили $response_code)"
        ((FAILED++))
        return 1
    fi
}

# Функция для проверки JSON
test_json_endpoint() {
    local name=$1
    local url=$2
    
    echo -n "Проверка $name... "
    
    response=$(curl -s "$url" 2>/dev/null)
    
    if echo "$response" | python3 -m json.tool >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC} (valid JSON)"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC} (invalid JSON)"
        echo "Response: $response"
        ((FAILED++))
        return 1
    fi
}

# База URL
BASE_URL="${1:-http://localhost:8000}"

echo "🌐 Тестируем: $BASE_URL"
echo ""

# ==================== БАЗОВЫЕ ENDPOINTS ====================

echo "📌 1. БАЗОВЫЕ ENDPOINTS"
echo "────────────────────────────────────────────────────────"

test_endpoint "Health check" "$BASE_URL/health"
test_json_endpoint "API info" "$BASE_URL/api"
test_endpoint "Главная страница" "$BASE_URL/"
test_endpoint "Admin панель" "$BASE_URL/admin"
test_endpoint "Кабинет мастера" "$BASE_URL/master"
test_endpoint "Swagger docs" "$BASE_URL/docs"

echo ""

# ==================== API ENDPOINTS ====================

echo "📌 2. API ENDPOINTS"
echo "────────────────────────────────────────────────────────"

test_json_endpoint "Статистика" "$BASE_URL/api/v1/stats"
test_json_endpoint "Список заказов" "$BASE_URL/api/v1/jobs"

echo ""

# ==================== ПРОВЕРКА ФАЙЛОВ ====================

echo "📌 3. ПРОВЕРКА ФАЙЛОВ"
echo "────────────────────────────────────────────────────────"

files=(
    "main.py"
    "requirements.txt"
    "static/index.html"
    "static/admin.html"
    "static/master-dashboard.html"
    "telegram_client_bot.py"
    "telegram_master_bot.py"
    "ai_assistant.py"
    "price_calculator.py"
    "google_sync.py"
)

for file in "${files[@]}"; do
    echo -n "Проверка $file... "
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ OK${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAILED${NC}"
        ((FAILED++))
    fi
done

echo ""

# ==================== ПРОВЕРКА БАЗЫ ДАННЫХ ====================

echo "📌 4. ПРОВЕРКА БАЗЫ ДАННЫХ"
echo "────────────────────────────────────────────────────────"

echo -n "Проверка data/ai_service.db... "
if [ -f "data/ai_service.db" ]; then
    echo -e "${GREEN}✅ OK${NC}"
    ((PASSED++))
    
    # Проверка таблиц
    echo -n "Проверка таблицы masters... "
    if sqlite3 data/ai_service.db "SELECT COUNT(*) FROM masters;" >/dev/null 2>&1; then
        count=$(sqlite3 data/ai_service.db "SELECT COUNT(*) FROM masters;")
        echo -e "${GREEN}✅ OK${NC} ($count мастеров)"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAILED${NC}"
        ((FAILED++))
    fi
    
    echo -n "Проверка таблицы jobs... "
    if sqlite3 data/ai_service.db "SELECT COUNT(*) FROM jobs;" >/dev/null 2>&1; then
        count=$(sqlite3 data/ai_service.db "SELECT COUNT(*) FROM jobs;")
        echo -e "${GREEN}✅ OK${NC} ($count заказов)"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAILED${NC}"
        ((FAILED++))
    fi
    
    echo -n "Проверка таблицы transactions... "
    if sqlite3 data/ai_service.db "SELECT COUNT(*) FROM transactions;" >/dev/null 2>&1; then
        count=$(sqlite3 data/ai_service.db "SELECT COUNT(*) FROM transactions;")
        echo -e "${GREEN}✅ OK${NC} ($count транзакций)"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAILED${NC}"
        ((FAILED++))
    fi
else
    echo -e "${RED}❌ FAILED${NC}"
    ((FAILED++))
fi

echo ""

# ==================== ПРОВЕРКА КОНФИГУРАЦИИ ====================

echo "📌 5. ПРОВЕРКА КОНФИГУРАЦИИ"
echo "────────────────────────────────────────────────────────"

echo -n "Проверка .gitignore... "
if [ -f ".gitignore" ]; then
    if grep -q ".env" .gitignore; then
        echo -e "${GREEN}✅ OK${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️ WARNING${NC} (.env не в .gitignore)"
        ((PASSED++))
    fi
else
    echo -e "${RED}❌ FAILED${NC}"
    ((FAILED++))
fi

echo -n "Проверка .env.example... "
if [ -f ".env.example" ]; then
    echo -e "${GREEN}✅ OK${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED${NC}"
    ((FAILED++))
fi

echo -n "Проверка quick_deploy.sh... "
if [ -f "quick_deploy.sh" ] && [ -x "quick_deploy.sh" ]; then
    echo -e "${GREEN}✅ OK${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠️ WARNING${NC} (файл существует но не executable)"
    ((PASSED++))
fi

echo ""

# ==================== ИТОГИ ====================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✅ Пройдено:${NC} $PASSED"
echo -e "${RED}❌ Провалено:${NC} $FAILED"
echo ""

TOTAL=$((PASSED + FAILED))
PERCENTAGE=$((PASSED * 100 / TOTAL))

echo "📈 Процент успеха: $PERCENTAGE%"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ!${NC}"
    echo "Система готова к продакшну! 🚀"
    exit 0
else
    echo -e "${YELLOW}⚠️ ЕСТЬ ПРОБЛЕМЫ${NC}"
    echo "Исправьте ошибки перед деплоем на продакшн"
    exit 1
fi
