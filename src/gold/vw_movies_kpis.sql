CREATE OR REFRESH MATERIALIZED VIEW gold.vw_movies_kpis
COMMENT 'Média, total, desvio padrão e timestamps de ratings por filme'
AS
SELECT
    r.movie_id,
    m.title,
    m.genres,
    m.release_year,
    COUNT(*) AS total_rating,
    AVG(r.rating) AS avg_rating,
    STDDEV(r.rating) AS std_rating,
    MIN(r.rating_ts) AS first_rating_ts,
    MAX(r.rating_ts) AS last_rating_ts
FROM silver.fact_ratings AS r
LEFT JOIN silver.dim_movies AS m
    ON r.movie_id = m.movie_id
GROUP BY r.movie_id, m.title, m.genres, m.release_year;
