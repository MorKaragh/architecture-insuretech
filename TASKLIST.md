# Task2 — план-чеклист выполнения

## 0) Подготовка окружения

- [ ] Убедиться, что установлены и доступны команды: `minikube`, `kubectl`, `locust`, `helm` (или другой способ установки Prometheus).
  - Выполнено: `minikube`, `kubectl`, `locust` (в `Task2/locust/.venv`).
  - В работе: `helm` (для части 2 можно выбрать альтернативную установку Prometheus без Helm).
- [x] Запустить локальный кластер: `minikube start`.
- [x] Проверить доступ к кластеру: `kubectl get nodes`.
- [x] Создать рабочую папку для манифестов в `Task2` (например, `Task2/k8s`).
- [x] Зафиксировать соглашение по именам ресурсов (namespace, deployment, service, hpa), чтобы все файлы были консистентны.
  - `namespace`: `insuretech-task2`
  - `deployment`: `insuretech-demo-app`
  - `service`: `insuretech-demo-svc`
  - `hpa-memory`: `insuretech-demo-hpa-memory`
  - `hpa-rps`: `insuretech-demo-hpa-rps`

## 1) Часть 1 — автоскейлинг по памяти

### 1.1 Базовый деплой приложения

- [ ] Создать манифест `Deployment` для тестового приложения.
- [ ] Указать `replicas: 1`.
- [ ] Указать `resources.limits.memory: 30Mi`.
- [ ] (Рекомендуется) добавить `resources.requests.memory` для более предсказуемого поведения HPA.
- [ ] Применить манифест: `kubectl apply -f ...`.
- [ ] Проверить, что под поднялся: `kubectl get pods`.

### 1.2 Сервис для доступа

- [ ] Создать манифест `Service` для доступа к приложению на порту `8080`.
- [ ] Применить манифест: `kubectl apply -f ...`.
- [ ] Проверить доступность: `minikube service <service-name> --url` и `curl <url>/`.

### 1.3 Метрики и HPA по памяти

- [ ] Включить `metrics-server`: `minikube addons enable metrics-server`.
- [ ] Убедиться, что метрики читаются: `kubectl top pods` (после прогрева нагрузки).
- [ ] Создать манифест `HorizontalPodAutoscaler`:
  - [ ] target memory utilization: `80%`;
  - [ ] `minReplicas` (обычно `1`);
  - [ ] `maxReplicas: 10`;
- [ ] Применить HPA: `kubectl apply -f ...`.
- [ ] Проверить статус HPA: `kubectl get hpa` и `kubectl describe hpa <name>`.

### 1.4 Нагрузочное тестирование (Locust)

- [ ] Создать `locustfile.py` (по шаблону из задания) в удобной директории.
- [ ] Запустить `locust` и открыть UI: `http://localhost:8089`.
- [ ] Запустить нагрузку на endpoint `/` через URL сервиса из Minikube.
- [ ] Открыть `minikube dashboard` и наблюдать изменение количества реплик.
- [ ] Сохранить доказательства работы автоскейлинга:
  - [ ] скриншоты dashboard/HPA;
  - [ ] при необходимости логи/вывод `kubectl get hpa -w`.
- [ ] Сложить артефакты в `Task2` (например, `Task2/evidence/part1`).

## 2) Часть 2 — автоскейлинг по RPS через Prometheus

### 2.1 Установка и проверка Prometheus

- [ ] Установить Prometheus в кластер (например, через Helm chart).
- [ ] Проверить, что pod'ы Prometheus в статусе `Running`.
- [ ] Открыть Prometheus UI (port-forward или service URL).

### 2.2 Сбор метрик приложения

- [ ] Настроить scrape метрик приложения (`/metrics`) в Prometheus.
- [ ] Проверить в `Targets`, что endpoint приложения в состоянии `UP`.
- [ ] Проверить в `Graph`, что видна метрика `http_requests_total`.
- [ ] Сделать скриншоты `Targets` и/или `Graph` и сохранить в `Task2/evidence/part2`.

### 2.3 HPA по внешней метрике RPS

- [ ] Выбрать способ передачи внешних метрик в Kubernetes (Prometheus Adapter / custom metrics API).
- [ ] Настроить правило расчёта RPS на под (на основе `http_requests_total`).
- [ ] Создать новую версию манифеста HPA для скейлинга по RPS.
- [ ] Применить манифест и убедиться, что HPA видит внешнюю метрику.
- [ ] Проверить через `kubectl describe hpa <name>`, что используются external/custom metrics.

### 2.4 Нагрузочное тестирование для RPS-сценария

- [ ] Повторно запустить нагрузку через Locust.
- [ ] Наблюдать изменение числа реплик под нагрузкой.
- [ ] Сохранить подтверждение (скриншоты dashboard/HPA/Prometheus или логи).
- [ ] Сложить материалы в `Task2/evidence/part2`.

## 3) Финальная проверка перед сдачей

- [ ] Проверить, что все требуемые манифесты лежат в `Task2`.
- [ ] Проверить, что все скриншоты/логи приложены в `Task2`.
- [ ] Проверить читаемость имен файлов (понятно, к какой части задания относится каждый файл).
- [ ] Добавить краткий `README` в `Task2` с инструкцией запуска и списком артефактов.
- [ ] Пройтись по чеклисту и убедиться, что каждый пункт закрыт.

## 4) Предлагаемая структура артефактов в репозитории

- [ ] `Task2/k8s/deployment.yaml`
- [ ] `Task2/k8s/service.yaml`
- [ ] `Task2/k8s/hpa-memory.yaml`
- [ ] `Task2/k8s/hpa-rps.yaml`
- [ ] `Task2/locust/locustfile.py`
- [ ] `Task2/evidence/part1/*`
- [ ] `Task2/evidence/part2/*`
- [ ] `Task2/README.md`
