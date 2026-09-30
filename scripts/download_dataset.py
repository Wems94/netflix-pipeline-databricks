"""Baixa o MovieLens Beliefs 2024 do GroupLens, extrai os CSVs em data/data_release/
e remove o zip ao final."""

import shutil
import urllib.request
import zipfile
from pathlib import Path

URL = "https://files.grouplens.org/datasets/movielens/ml_belief_2024_data_release_2.zip"

ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT / "data"
ZIP_PATH = DATA_DIR / "ml_belief_2024_data_release_2.zip"
OUT_DIR = DATA_DIR / "data_release"

CSVS_ESPERADOS = {
    "movies.csv",
    "belief_data.csv",
    "user_rating_history.csv",
    "ratings_for_additional_users.csv",
    "movie_elicitation_set.csv",
    "user_recommendation_history.csv",
}


def dataset_ja_existe() -> bool:
    return all((OUT_DIR / nome).exists() for nome in CSVS_ESPERADOS)


def baixar() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    temp = ZIP_PATH.with_suffix(".zip.part")  # evita zip corrompido se o download cair
    print(f"Baixando {URL} ...")
    with urllib.request.urlopen(URL) as resp, temp.open("wb") as f:
        shutil.copyfileobj(resp, f)
    temp.rename(ZIP_PATH)
    print(f"[baixado]  {ZIP_PATH.stat().st_size / 1024 / 1024:.1f} MB")


def extrair() -> set[str]:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    extraidos = set()
    with zipfile.ZipFile(ZIP_PATH) as z:
        for membro in z.infolist():
            nome = Path(membro.filename)
            # só CSVs; ignora lixo do macOS (__MACOSX, ._arquivo)
            if nome.suffix != ".csv" or "__MACOSX" in nome.parts or nome.name.startswith("._"):
                continue
            destino = OUT_DIR / nome.name
            with z.open(membro) as src, destino.open("wb") as dst:
                shutil.copyfileobj(src, dst)
            extraidos.add(nome.name)
            print(f"[extraído] {nome.name} ({destino.stat().st_size / 1024 / 1024:.1f} MB)")
    return extraidos


def main() -> None:
    if dataset_ja_existe():
        print(f"[ok] os 6 CSVs já existem em {OUT_DIR} — nada a fazer.")
        return

    if not ZIP_PATH.exists():
        baixar()

    extraidos = extrair()

    faltando = CSVS_ESPERADOS - extraidos
    if faltando:
        raise RuntimeError(f"CSVs não encontrados no zip: {sorted(faltando)} (zip mantido)")

    ZIP_PATH.unlink()
    print(f"[removido] {ZIP_PATH.name}")
    print("Dataset pronto em", OUT_DIR)


if __name__ == "__main__":
    main()