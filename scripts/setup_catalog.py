"""Cria catálogo, schemas e volume do projeto. Idempotente: pode rodar várias vezes."""

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors import NotFound
from databricks.sdk.service.catalog import VolumeType

PROFILE = "free"
CATALOG = "netflix"
SCHEMAS = ["bronze", "silver", "gold"]
VOLUME_SCHEMA = "bronze"
VOLUME = "landing"

w = WorkspaceClient(profile=PROFILE)


def criar_catalogo(nome: str) -> None:
    try:
        w.catalogs.get(nome)
        print(f"[ok]     catálogo {nome} já existe")
    except NotFound:
        w.catalogs.create(name=nome, comment="Pipeline MovieLens - arquitetura Medallion")
        print(f"[criado] catálogo {nome}")


def criar_schema(catalogo: str, nome: str) -> None:
    full_name = f"{catalogo}.{nome}"
    try:
        w.schemas.get(full_name)
        print(f"[ok]     schema {full_name} já existe")
    except NotFound:
        w.schemas.create(name=nome, catalog_name=catalogo, comment=f"Camada {nome}")
        print(f"[criado] schema {full_name}")


def criar_volume(catalogo: str, schema: str, nome: str) -> None:
    full_name = f"{catalogo}.{schema}.{nome}"
    try:
        w.volumes.read(full_name)
        print(f"[ok]     volume {full_name} já existe")
    except NotFound:
        w.volumes.create(
            catalog_name=catalogo,
            schema_name=schema,
            name=nome,
            volume_type=VolumeType.MANAGED,
            comment="Arquivos CSV brutos (landing zone)",
        )
        print(f"[criado] volume {full_name}")


def main() -> None:
    criar_catalogo(CATALOG)
    for schema in SCHEMAS:
        criar_schema(CATALOG, schema)
    criar_volume(CATALOG, VOLUME_SCHEMA, VOLUME)
    print("Setup concluído.")


if __name__ == "__main__":
    main()