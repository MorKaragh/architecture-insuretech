# Task 5 — GraphQL для client-info

## Краткий анализ REST (Swagger)

| Операция | Ресурс | Назначение |
|----------|--------|------------|
| `GET` | `/v1/clients/{id}` | Карточка клиента (`Client`: id, name, age) |
| `GET` | `/v1/clients/{id}/documents` | Список документов |
| `GET` | `/v1/clients/{id}/relatives` | Список родственников |

Типы `Document` и `Relative` перенесены в GraphQL без изменения полей (имена в camelCase, как в JSON).

## Соответствие REST → GraphQL

| REST | GraphQL |
|------|---------|
| `GET /clients/{id}` | `query { client(id: "...") { id name age } }` |
| `GET /clients/{id}/documents` | `query { client(id: "...") { documents { id type number issueDate expiryDate } } }` |
| `GET /clients/{id}/relatives` | `query { client(id: "...") { relatives { id relationType name age } } }` |
| Несколько ресурсов за один round-trip | Один запрос с нужным набором полей, например карточка + документы + родственники |

Корневой запрос один: `client(id: ID!): Client`. Вложенные поля `documents` и `relatives` резолвятся только если они перечислены в запросе — это и есть гибкий выбор данных вместо множества отдельных REST-вызовов.

## Артефакты

| Файл | Описание |
|------|----------|
| `schema.graphql` | SDL-схема |
| `graphql-schema-diagram.puml` | Диаграмма типов и связей (PlantUML) |
| `demo/` | Демонстрационный сервер на Python (Strawberry + FastAPI), сборка с venv в Docker |

## Запуск демо

Из каталога `Task5/demo`:

```bash
docker compose up --build
```

GraphQL HTTP endpoint: `http://localhost:8000/graphql` (интерактивная страница Strawberry).

Локально без Docker (venv):

```bash
cd Task5/demo
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Пример запроса:

```graphql
query {
  client(id: "c1") {
    id
    name
    age
    documents { id type number }
    relatives { id relationType name }
  }
}
```
