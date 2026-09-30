CREATE OR REFRESH MATERIALIZED VIEW gold.vw_genre_performance
COMMENT 'Performance e volume de avaliações por gênero'
AS
WITH exploded AS (
    SELECT
        r.rating,
        g.genre
    FROM silver.fact_ratings AS r
    INNER JOIN silver.dim_movies AS m
        ON r.movie_id = m.movie_id
        LATERAL VIEW explode(split(coalesce(m.genres, ''), r'\|')) g AS genre
)

SELECT
    genre,
    count(*) AS total_ratings,
    avg(rating) AS avg_rating,
    stddev(rating) AS std_rating
FROM exploded
WHERE
    genre IS NOT NULL
    AND genre != ''
    AND genre != '(no genres listed)'
GROUP BY genre;
