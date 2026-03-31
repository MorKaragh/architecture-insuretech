# Task2 — план-чеклист выполнения

## 0) Подготовка окружения

- [x] Убедиться, что установлены и доступны команды: `minikube`, `kubectl`, `locust`, `helm` (или другой способ установки Prometheus).
  - Есть: `minikube`, `kubectl`, `locust` (`Task2/locust/.venv`), `helm` (`~/.local/bin/helm`).
- [x] Запустить локальный кластер: `minikube start`.
- [x] Проверить доступ к кластеру: `kubectl get nodes`.
- [x] Создать рабочую папку для манифестов в `Task2` (например, `Task2/k8s`).
- [x] Зафиксировать соглашение по именам ресурсов (namespace, deployment, service, hpa), чтобы все файлы были консистентны.
  - `namespace`: `insurtech`
  - `deployment`: `insuretech-demo-app`
  - `service`: `insuretech-demo-svc`
  - `hpa-memory`: `insuretech-demo-hpa-memory`
  - `hpa-rps`: `insuretech-demo-hpa-rps`

## 1) Часть 1 — автоскейлинг по памяти

### 1.1 Базовый деплой приложения

- [x] Создать манифест `Deployment` для тестового приложения.
- [x] Указать `replicas: 1`.
- [x] Указать `resources.limits.memory: 30Mi`.
- [x] (Рекомендуется) добавить `resources.requests.memory` для более предсказуемого поведения HPA.
- [x] Применить манифест: `kubectl apply -f ...`.
- [x] Проверить, что под поднялся: `kubectl get pods`.

### 1.2 Сервис для доступа

- [x] Создать манифест `Service` для доступа к приложению на порту `8080`.
- [x] Применить манифест: `kubectl apply -f ...`.
- [x] Проверить доступность: `minikube service <service-name> --url` и `curl <url>/`.

### 1.3 Метрики и HPA по памяти

- [x] Включить `metrics-server`: `minikube addons enable metrics-server`.
- [x] Убедиться, что метрики читаются: `kubectl top pods` (после прогрева нагрузки).
- [x] Создать манифест `HorizontalPodAutoscaler`:
  - [x] target memory utilization: `80%`;
  - [x] `minReplicas` (обычно `1`);
  - [x] `maxReplicas: 10`;
- [x] Применить HPA: `kubectl apply -f ...`.
- [x] Проверить статус HPA: `kubectl get hpa` и `kubectl describe hpa <name>`.

### 1.4 Нагрузочное тестирование (Locust)

- [x] Создать `locustfile.py` (по шаблону из задания) в удобной директории.
- [x] Запустить `locust` (использован headless-режим вместо UI).
- [x] Запустить нагрузку на endpoint `/` через URL сервиса из Minikube.
- [x] Открыть `minikube dashboard` и наблюдать изменение количества реплик (см. `Task2/README.md`: namespace `insurtech`, Deployment / HPA).
- [x] Сохранить доказательства работы автоскейлинга:
  - [x] скриншоты dashboard/HPA (снять вручную; куда зайти — в `Task2/README.md`);
  - [x] логи/вывод `kubectl get hpa -w` (аналог через периодический `kubectl get hpa`).
- [x] Сложить артефакты в `Task2` (например, `Task2/evidence/part1`).

## 2) Часть 2 — автоскейлинг по RPS через Prometheus

### 2.1 Установка и проверка Prometheus

- [x] Установить Prometheus в кластер (через Helm chart).
- [x] Проверить, что pod'ы Prometheus в статусе `Running`.
- [x] Открыть Prometheus UI (использован port-forward и API-запросы как проверка).

### 2.2 Сбор метрик приложения

- [x] Настроить scrape метрик приложения (`/metrics`) в Prometheus.
- [x] Проверить в `Targets`, что endpoint приложения в состоянии `UP` (через API).
- [x] Проверить в `Graph`, что видна метрика `http_requests_total` (через API query).
- [x] Сделать скриншоты `Targets` и/или `Graph` и сохранить в `Task2/evidence/part2` (вручную: `Task2/README.md` → Prometheus `/targets` и `/graph`).

### 2.3 HPA по внешней метрике RPS

- [x] Выбрать способ передачи внешних метрик в Kubernetes (Prometheus Adapter / custom metrics API).
- [x] Настроить правило расчёта RPS на под (на основе `http_requests_total`).
- [x] Создать новую версию манифеста HPA для скейлинга по RPS.
- [x] Применить манифест и убедиться, что HPA видит внешнюю метрику.
- [x] Проверить через `kubectl describe hpa <name>`, что используются external/custom metrics.

### 2.4 Нагрузочное тестирование для RPS-сценария

- [x] Повторно запустить нагрузку через Locust.
- [x] Наблюдать изменение числа реплик под нагрузкой.
- [x] Сохранить подтверждение (скриншоты dashboard/HPA/Prometheus или логи).
- [x] Сложить материалы в `Task2/evidence/part2`.

## 3) Финальная проверка перед сдачей

- [x] Проверить, что все требуемые манифесты лежат в `Task2`.
- [x] Проверить, что все скриншоты/логи приложены в `Task2`.
- [x] Проверить читаемость имен файлов (понятно, к какой части задания относится каждый файл).
- [x] Добавить краткий `README` в `Task2` с инструкцией запуска и списком артефактов.
- [x] Пройтись по чеклисту и убедиться, что каждый пункт закрыт (`Task2/scripts/verify_task2_submit.sh`).

## 4) Предлагаемая структура артефактов в репозитории

- [x] `Task2/k8s/deployment.yaml`
- [x] `Task2/k8s/service.yaml`
- [x] `Task2/k8s/hpa-memory.yaml`
- [x] `Task2/k8s/hpa-rps.yaml`
- [x] `Task2/helm/prometheus-values.yaml`
- [x] `Task2/helm/prometheus-adapter-values.yaml`
- [x] `Task2/locust/locustfile.py`
- [x] `Task2/evidence/screenshots/*`
- [x] `Task2/evidence/part1/*`
- [x] `Task2/evidence/part2/*`
- [x] `Task2/README.md`
