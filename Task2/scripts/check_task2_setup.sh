#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FAILURES=0
WARNINGS=0

ok() {
  echo "[OK] $1"
}

warn() {
  echo "[WARN] $1"
  WARNINGS=$((WARNINGS + 1))
}

fail() {
  echo "[FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "Команда '$cmd' доступна"
  else
    fail "Команда '$cmd' не найдена"
  fi
}

check_dir() {
  local path="$1"
  if [ -d "$ROOT_DIR/$path" ]; then
    ok "Директория '$path' существует"
  else
    fail "Директория '$path' отсутствует"
  fi
}

echo "=== Проверка настроек Task2 ==="
echo "ROOT: $ROOT_DIR"
echo

echo "1) Базовые утилиты"
check_cmd minikube
check_cmd kubectl
check_cmd python3
echo

echo "2) Состояние Kubernetes (Minikube)"
if command -v kubectl >/dev/null 2>&1; then
  if kubectl get nodes >/dev/null 2>&1; then
    READY_NODES="$(kubectl get nodes --no-headers 2>/dev/null | awk '$2=="Ready"{c++} END{print c+0}')"
    if [ "$READY_NODES" -ge 1 ]; then
      ok "Есть Ready-ноды: $READY_NODES"
    else
      fail "Ноды найдены, но нет Ready-нод"
    fi
  else
    fail "kubectl не может получить список нод (кластер недоступен)"
  fi
fi
echo

echo "3) Структура Task2"
check_dir "Task2/k8s"
check_dir "Task2/locust"
check_dir "Task2/evidence/part1"
check_dir "Task2/evidence/part2"
check_dir "Task2/scripts"
echo

echo "4) Python venv и Locust"
if [ -x "$ROOT_DIR/Task2/locust/.venv/bin/python" ]; then
  ok "venv найден: Task2/locust/.venv"
else
  fail "venv не найден: Task2/locust/.venv"
fi

if [ -x "$ROOT_DIR/Task2/locust/.venv/bin/locust" ]; then
  LOCUST_VERSION="$("$ROOT_DIR/Task2/locust/.venv/bin/locust" --version 2>/dev/null || true)"
  if [ -n "$LOCUST_VERSION" ]; then
    ok "locust в venv работает: $LOCUST_VERSION"
  else
    fail "locust в venv найден, но не запускается"
  fi
else
  fail "locust не найден в venv: Task2/locust/.venv/bin/locust"
fi
echo

echo "5) Подсказка для части 2 (Prometheus)"
if command -v helm >/dev/null 2>&1; then
  ok "helm доступен (можно ставить Prometheus через Helm)"
else
  warn "helm не найден (для части 2 понадобится Helm или альтернативный способ установки Prometheus)"
fi
echo

echo "=== Итог ==="
if [ "$FAILURES" -eq 0 ]; then
  echo "Проверка пройдена: критичных проблем нет."
  if [ "$WARNINGS" -gt 0 ]; then
    echo "Предупреждений: $WARNINGS"
  fi
  exit 0
else
  echo "Найдено проблем: $FAILURES (предупреждений: $WARNINGS)"
  exit 1
fi
