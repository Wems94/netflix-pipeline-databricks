CREATE OR REFRESH MATERIALIZED VIEW silver.dim_movie_elicitation
COMMENT 'Filmes do processo de elicitação com critério de seleção decodificado'
AS
SELECT
    try_cast(nullif(movieid, '') AS BIGINT) AS movie_id,
    try_cast(month_idx AS INT) AS month_idx,
    try_cast(source AS INT) AS source,
    CASE try_cast(source AS INT)
        WHEN 1 THEN 'Popularidade'
        WHEN 2 THEN 'Rating'
        WHEN 3 THEN 'Lancamentos Populares'
        WHEN 4 THEN 'Lancamentos em Alta'
        WHEN 5 THEN 'Serendipidade'
        ELSE 'Desconhecido'
    END AS source_label,
    coalesce(
        try_to_timestamp(tstamp, 'yyyy-MM-dd HH:mm:ssXXX'),
        try_to_timestamp(tstamp, 'yyyy-MM-dd HH:mm:ss')
    ) AS elicitation_ts
FROM bronze.raw_movie_elicitation_set
WHERE movieid IS NOT NULL
QUALIFY row_number() OVER (
    PARTITION BY try_cast(movieid AS BIGINT), try_cast(month_idx AS INT)
    ORDER BY tstamp DESC
) = 1;
