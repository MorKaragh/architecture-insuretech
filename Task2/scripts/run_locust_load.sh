#!/usr/bin/env bash
# Нагрузка на insuretech-demo-svc (часть 1: HPA по памяти).
# Запускай из корня репозитория: ./Task2/scripts/run_locust_load.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOCUST="$ROOT/Task2/locust/.venv/bin/locust"
LOCUSTFILE="$ROOT/Task2/locust/locustfile.py"

USERS="${LOCUST_USERS:-180}"
SPAWN_RATE="${LOCUST_SPAWN_RATE:-40}"
RUN_TIME="${LOCUST_RUN_TIME:-90s}"
WARMUP_SEC="${LOCUST_WARMUP_SEC:-8}"

if [[ ! -x "$LOCUST" ]]; then
  echo "Нет Locust в venv. Создай: python3 -m venv Task2/locust/.venv && Task2/locust/.venv/bin/pip install locust" >&2
  exit 1
fi

if ! command -v minikube >/dev/null 2>&1; then
  echo "minikube не найден в PATH" >&2
  exit 1
fi

BASE_URL="$(minikube service insuretech-demo-svc -n insurtech --url)"
BASE_URL="${BASE_URL%/}"

echo "URL сервиса: $BASE_URL"
echo "Параметры: users=$USERS spawn_rate=$SPAWN_RATE run_time=$RUN_TIME"
echo "Через ${WARMUP_SEC}s начнётся нагрузка — успей открыть Dashboard (ns insurtech → Deployment / HPA)."
sleep "$WARMUP_SEC"

exec "$LOCUST" -f "$LOCUSTFILE" --headless \
  --host "$BASE_URL" \
  -u "$USERS" \
  -r "$SPAWN_RATE" \
  --run-time "$RUN_TIME" \
  --stop-timeout 10 \
  --only-summary
