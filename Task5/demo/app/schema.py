"""GraphQL-типы, согласованные с Task5/schema.graphql."""

from __future__ import annotations

import strawberry

from app.data import CLIENTS, DOCUMENTS_BY_CLIENT, RELATIVES_BY_CLIENT


@strawberry.type
class Document:
    id: strawberry.ID
    type: str
    number: str
    issue_date: str = strawberry.field(name="issueDate")
    expiry_date: str = strawberry.field(name="expiryDate")


@strawberry.type
class Relative:
    id: strawberry.ID
    relation_type: str = strawberry.field(name="relationType")
    name: str
    age: int


@strawberry.type
class Client:
    id: strawberry.ID
    name: str
    age: int

    @strawberry.field
    def documents(self) -> list[Document]:
        rows = DOCUMENTS_BY_CLIENT.get(str(self.id), [])
        return [
            Document(
                id=r["id"],
                type=r["type"],
                number=r["number"],
                issue_date=r["issueDate"],
                expiry_date=r["expiryDate"],
            )
            for r in rows
        ]

    @strawberry.field
    def relatives(self) -> list[Relative]:
        rows = RELATIVES_BY_CLIENT.get(str(self.id), [])
        return [
            Relative(
                id=r["id"],
                relation_type=r["relationType"],
                name=r["name"],
                age=r["age"],
            )
            for r in rows
        ]


@strawberry.type
class Query:
    @strawberry.field(description="Получить клиента по ID (эквивалент GET /v1/clients/{id}).")
    def client(self, id: strawberry.ID) -> Client | None:
        row = CLIENTS.get(str(id))
        if row is None:
            return None
        return Client(id=row["id"], name=row["name"], age=row["age"])


schema = strawberry.Schema(query=Query)
