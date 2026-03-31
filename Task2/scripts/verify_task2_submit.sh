#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail() { echo "[FAIL] $1" >&2; exit 1; }
ok() { echo "[OK] $1"; }

echo "=== Task2: проверка перед сдачей ==="

test -f Task2/k8s/deployment.yaml || fail "нет Task2/k8s/deployment.yaml"
test -f Task2/k8s/service.yaml || fail "нет Task2/k8s/service.yaml"
test -f Task2/k8s/hpa-memory.yaml || fail "нет Task2/k8s/hpa-memory.yaml"
test -f Task2/k8s/hpa-rps.yaml || fail "нет Task2/k8s/hpa-rps.yaml"
test -f Task2/locust/locustfile.py || fail "нет Task2/locust/locustfile.py"
test -f Task2/README.md || fail "нет Task2/README.md"
ok "Обязательные файлы на месте"

for f in deployment.yaml service.yaml hpa-memory.yaml hpa-rps.yaml; do
  kubectl apply --dry-run=client -f "Task2/k8s/$f" >/dev/null || fail "dry-run: Task2/k8s/$f"
done
ok "kubectl apply --dry-run=client для манифестов в Task2/k8s/"

test -f Task2/helm/prometheus-values.yaml || fail "нет Task2/helm/prometheus-values.yaml"
test -f Task2/helm/prometheus-adapter-values.yaml || fail "нет Task2/helm/prometheus-adapter-values.yaml"
ok "Helm values (Prometheus / adapter) на месте"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  for f in Task2/evidence/part1/*.log Task2/evidence/part2/*.log; do
    if [[ -f "$f" ]]; then
      if git check-ignore -q "$f" 2>/dev/null; then
        fail "файл игнорируется git и не попадёт в репозиторий: $f"
      fi
    fi
  done
  ok "Логи в Task2/evidence/**/*.log не попадают под игнор .gitignore"
fi

echo "=== Готово ==="
