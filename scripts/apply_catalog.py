"""Aplica as descrições do catalog/catalog.yml nas tabelas e colunas do Unity Catalog.

Roda como tarefa do job, depois do pipeline (equivale ao aplicar_descricoes() do projeto GCP).
"""

import argparse

import yaml
from pyspark.sql import SparkSession

# tipo de objeto por camada (define o comando ALTER correto)
TIPO_POR_CAMADA = {
    "bronze": "STREAMING TABLE",
    "silver": "MATERIALIZED VIEW",
    "gold": "MATERIALIZED VIEW",
}


def escapar(texto: str) -> str:
    """Escapa barras e aspas simples para uso dentro de string SQL."""
    return str(texto).replace("\\", "\\\\").replace("'", "\\'")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--catalog-file", required=True, help="Caminho do catalog.yml")
    parser.add_argument("--catalog", help="Sobrescreve o catálogo definido no yml")
    args = parser.parse_args()

    with open(args.catalog_file, encoding="utf-8") as f:
        cfg = yaml.safe_load(f)

    catalogo = args.catalog or cfg["catalog"]
    spark = SparkSession.builder.getOrCreate()
    avisos = 0

    for camada, tipo in TIPO_POR_CAMADA.items():
        for tabela, info in (cfg.get(camada) or {}).items():
            fqn = f"{catalogo}.{camada}.{tabela}"

            if not spark.catalog.tableExists(fqn):
                print(f"[aviso] tabela não encontrada: {fqn}")
                avisos += 1
                continue

            colunas_tabela = set(spark.table(fqn).columns)
            colunas_yml = info.get("columns") or {}

            descricao = info.get("description", "")
            spark.sql(f"COMMENT ON TABLE {fqn} IS '{escapar(descricao)}'")

            for coluna, desc in colunas_yml.items():
                if coluna not in colunas_tabela:
                    print(f"[aviso] {fqn}: coluna '{coluna}' está no yml mas não existe na tabela")
                    avisos += 1
                    continue
                spark.sql(f"ALTER {tipo} {fqn} ALTER COLUMN `{coluna}` COMMENT '{escapar(desc)}'")

            sem_descricao = colunas_tabela - set(colunas_yml)
            for coluna in sorted(sem_descricao):
                print(f"[aviso] {fqn}: coluna '{coluna}' existe na tabela mas não está no yml")
                avisos += 1

            print(f"[ok] {fqn}: {len(colunas_yml)} colunas descritas")

    print(f"Catálogo aplicado com {avisos} aviso(s).")


if __name__ == "__main__":
    main()