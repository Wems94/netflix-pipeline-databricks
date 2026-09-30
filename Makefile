# Carrega DATABRICKS_HOST / DATABRICKS_TOKEN do .env (se existir)
-include .env
export

.PHONY: setup data upload deploy run pipeline full-refresh lint fix all

## Infra: cria catálogo (já existente), schemas e volume
setup:
	uv run scripts/setup_catalog.py

## Baixa e extrai o dataset MovieLens em data/data_release/
data:
	uv run scripts/download_dataset.py

## Envia os CSVs para o volume netflix.bronze.landing
upload:
	uv run scripts/upload_raw.py

## Publica o bundle (pipeline + job) no workspace
deploy:
	databricks bundle deploy

## Roda o job completo (pipeline + catálogo)
run:
	databricks bundle run netflix_job

## Roda só o pipeline (Bronze → Silver → Gold)
pipeline:
	databricks bundle run netflix_pipeline

## Reprocessa todas as tabelas do zero
full-refresh:
	databricks bundle run netflix_pipeline --full-refresh-all

## Lint Python + SQL
lint:
	uv run ruff check scripts/
	uv run sqlfluff lint src/

## Corrige automaticamente o que for possível no lint
fix:
	uv run ruff check scripts/ --fix
	uv run sqlfluff fix src/

## Fluxo completo do zero: dados → volume → deploy → job
all: data upload deploy run