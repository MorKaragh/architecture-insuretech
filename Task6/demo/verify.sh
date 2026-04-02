#!/usr/bin/env bash
# Проверка демо: rate limit 10 req/min, ответ 429 при превышении.
set -u

cd "$(dirname "$0")"
BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

ok() { echo -e "${GREEN}OK${NC}"; }
fail() { echo -e "${RED}FAIL${NC}"; }
warn() { echo -e "${YELLOW}$*${NC}"; }

die_fail() {
  warn "$*"
  fail
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die_fail "Нужна команда: $1"
}

need_cmd docker
need_cmd curl

if ! docker compose version >/dev/null 2>&1; then
  die_fail "Нужен Docker Compose v2 (docker compose)"
fi

echo "==> Сборка и запуск контейнеров..."
docker compose up -d --build

echo "==> Перезапуск edge (сброс зоны limit_req)..."
docker compose restart edge
# Не делаем отдельный curl до нагрузочного теста — он съел бы одну квоту из 10/мин.
sleep 3

echo "==> Шквал из 15 запросов (ожидается 10×200 и 5×429)..."
n200=0
n429=0
other=""
first=""
for i in $(seq 1 15); do
  c=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$BASE_URL/" || echo "000")
  [[ -z "$first" ]] && first="$c"
  case "$c" in
    200) n200=$((n200 + 1)) ;;
    429) n429=$((n429 + 1)) ;;
    *) other="${other} [$i:$c]" ;;
  esac
done

if [[ "$first" != "200" ]]; then
  die_fail "Первый запрос должен быть 200 (сервис поднят), получено: $first"
fi

if [[ -n "$other" ]]; then
  die_fail "Неожиданные коды:$other"
fi
if [[ "$n200" -ne 10 || "$n429" -ne 5 ]]; then
  die_fail "Ожидалось 10 ответов 200 и 5 ответов 429, получено: 200=$n200, 429=$n429"
fi

echo "    200: $n200, 429: $n429"
echo -n "==> Итог: "
ok
exit 0
