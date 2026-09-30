CREATE OR REFRESH MATERIALIZED VIEW silver.dim_movies
COMMENT 'Dimensão de filmes com tipos corrigidos, deduplicada por movie_id'
AS
SELECT
    try_cast(movieid AS BIGINT) AS movie_id,
    title,
    genres,
    try_cast(regexp_extract(title, r'\((\d{4})\)\s*$', 1) AS INT) AS release_year
FROM bronze.raw_movies
WHERE movieid IS NOT NULL
QUALIFY row_number() OVER (
    PARTITION BY try_cast(movieid AS BIGINT)
    ORDER BY title
) = 1;
