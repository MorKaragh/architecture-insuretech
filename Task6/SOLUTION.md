# Задание 6

Конфигурация Nginx: **`nginx.conf`**. Лимит **10 запросов/мин** на IP (`limit_req`), при превышении — **HTTP 429** (`limit_req_status 429`).
