"""Тестовые данные для демо (аналог ответов REST client-info)."""

from __future__ import annotations

DOCUMENTS_BY_CLIENT: dict[str, list[dict]] = {
    "c1": [
        {
            "id": "d1",
            "type": "passport",
            "number": "4510 123456",
            "issueDate": "2015-03-20",
            "expiryDate": "2025-03-20",
        },
        {
            "id": "d2",
            "type": "driver_license",
            "number": "77 АА 123456",
            "issueDate": "2020-01-10",
            "expiryDate": "2030-01-10",
        },
    ],
    "c2": [
        {
            "id": "d3",
            "type": "passport",
            "number": "4002 987654",
            "issueDate": "2018-11-01",
            "expiryDate": "2028-11-01",
        },
    ],
}

RELATIVES_BY_CLIENT: dict[str, list[dict]] = {
    "c1": [
        {"id": "r1", "relationType": "spouse", "name": "Анна Иванова", "age": 34},
        {"id": "r2", "relationType": "child", "name": "Пётр Иванов", "age": 8},
    ],
    "c2": [],
}

CLIENTS: dict[str, dict] = {
    "c1": {"id": "c1", "name": "Иван Иванов", "age": 41},
    "c2": {"id": "c2", "name": "Мария Петрова", "age": 29},
}
