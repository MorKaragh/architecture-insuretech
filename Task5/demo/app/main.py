"""Демо GraphQL API client-info."""

from __future__ import annotations

from fastapi import FastAPI
from strawberry.fastapi import GraphQLRouter

from app.schema import schema

app = FastAPI(title="client-info GraphQL (demo)", version="1.0.0")

graphql_app = GraphQLRouter(schema)
app.include_router(graphql_app, prefix="/graphql")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
