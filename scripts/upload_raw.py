"""Envia os CSVs locais para o volume netflix.bronze.landing (uma pasta por tabela)."""

from pathlib import Path

from databricks.sdk import WorkspaceClient

LOCAL_DIR = Path(__file__).resolve().parent.parent / "data" / "data_release"
VOLUME_PATH = "/Volumes/netflix/bronze/landing"

ARQUIVOS = [
    "movies",
    "belief_data",
    "user_rating_history",
    "ratings_for_additional_users",
    "movie_elicitation_set",
    "user_recommendation_history",
]

w = WorkspaceClient()


def main() -> None:
    for nome in ARQUIVOS:
        origem = LOCAL_DIR / f"{nome}.csv"
        destino = f"{VOLUME_PATH}/{nome}/{nome}.csv"

        if not origem.exists():
            raise FileNotFoundError(f"Arquivo não encontrado: {origem}")

        tamanho_mb = origem.stat().st_size / 1024 / 1024
        print(f"Enviando {nome}.csv ({tamanho_mb:.1f} MB)...")
        with origem.open("rb") as f:
            w.files.upload(destino, f, overwrite=True)
        print(f"  ok -> {destino}")

    print("Upload concluído.")


if __name__ == "__main__":
    main()