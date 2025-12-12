#!/bin/bash

# 🔥 ФИНАЛЬНАЯ ПРОВЕРКА PRODUCTION
# Автоматическая диагностика всех компонентов

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔥 PRODUCTION DIAGNOSTIC - app.balt-set.ru"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

# Функция проверки
check() {
    local name=$1
    local url=$2
    local expected=$3
    
    echo -n "Проверка $name... "
    
    code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$code" = "$expected" ]; then
        echo -e "${GREEN}✅ OK${NC} (HTTP $code)"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} (HTTP $code, ожидался $expected)"
        ((FAILED++))
    fi
}

# Функция проверки JSON
check_json() {
    local name=$1
    local url=$2
    
    echo -n "Проверка $name... "
    
    response=$(curl -s "$url" 2>/dev/null)
    
    if echo "$response" | python3 -m json.tool >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC} (Valid JSON)"
        echo "   Ответ: $(echo $response | head -c 60)..."
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} (Invalid JSON)"
        echo "   Ответ: $(echo $response | head -c 60)..."
        ((FAILED++))
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 ТЕСТИРУЕМ ENDPOINTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# API Endpoints
check_json "Health Check" "https://app.balt-set.ru/health"
check_json "API Info" "https://app.balt-set.ru/api"

echo ""

# HTML Pages
check "Главная страница" "https://app.balt-set.ru/" "200"
check "Админ-панель" "https://app.balt-set.ru/admin" "200"
check "Кабинет мастера" "https://app.balt-set.ru/master" "200"
check "AI Chat" "https://app.balt-set.ru/ai-chat" "200"
check "Отслеживание" "https://app.balt-set.ru/track" "200"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 ПРОВЕРКА КОНТЕНТА"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Проверка что главная страница возвращает HTML
echo -n "Проверка HTML главной страницы... "
main_page=$(curl -s https://app.balt-set.ru/ 2>/dev/null | head -5)
if echo "$main_page" | grep -q "<!DOCTYPE html"; then
    echo -e "${GREEN}✅ OK${NC} (Valid HTML)"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL${NC} (Not HTML)"
    echo "   Контент: $main_page"
    ((FAILED++))
fi

# Проверка что админка возвращает HTML или 404
echo -n "Проверка админки... "
admin_code=$(curl -s -o /dev/null -w "%{http_code}" https://app.balt-set.ru/admin 2>/dev/null)
if [ "$admin_code" = "200" ]; then
    admin_page=$(curl -s https://app.balt-set.ru/admin 2>/dev/null | head -5)
    if echo "$admin_page" | grep -q "<!DOCTYPE html\|<html"; then
        echo -e "${GREEN}✅ OK${NC} (HTML загружается)"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️ WARNING${NC} (200 OK, но не HTML)"
        echo "   Контент: $admin_page"
        ((FAILED++))
    fi
elif [ "$admin_code" = "404" ]; then
    echo -e "${YELLOW}⚠️ В ПРОЦЕССЕ${NC} (404 - деплой еще идёт)"
    ((FAILED++))
else
    echo -e "${RED}❌ FAIL${NC} (HTTP $admin_code)"
    ((FAILED++))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 РЕЗУЛЬТАТЫ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TOTAL=$((PASSED + FAILED))
PERCENT=$((PASSED * 100 / TOTAL))

echo -e "Успешно: ${GREEN}$PASSED${NC}"
echo -e "Провалено: ${RED}$FAILED${NC}"
echo -e "Готовность: ${BLUE}$PERCENT%${NC}"
echo ""

if [ $PERCENT -ge 80 ]; then
    echo -e "${GREEN}✅ СИСТЕМА ГОТОВА К ИСПОЛЬЗОВАНИЮ!${NC}"
    exit 0
elif [ $PERCENT -ge 50 ]; then
    echo -e "${YELLOW}⏳ СИСТЕМА В ПРОЦЕССЕ ДЕПЛОЯ (подождите 1-2 минуты)${NC}"
    exit 1
else
    echo -e "${RED}❌ ТРЕБУЕТСЯ ДИАГНОСТИКА${NC}"
    echo ""
    echo "Рекомендации:"
    echo "1. Проверьте логи Timeweb: https://timeweb.cloud/my/apps"
    echo "2. Проверьте GitHub Actions: https://github.com/Heallshoking/balt-set.ru/actions"
    echo "3. Попробуйте ручной деплой: ./quick_deploy.sh \"fix\""
    exit 2
fi
