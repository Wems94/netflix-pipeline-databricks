CREATE OR REFRESH MATERIALIZED VIEW gold.vw_top_movies
COMMENT 'Ranking dos filmes mais avaliados'
AS
SELECT
    dm.movie_id,
    dm.title,
    dm.genres,
    COUNT(fr.movie_id) AS total_rating,
    AVG(fr.rating) AS avg_rating
FROM silver.dim_movies AS dm
LEFT JOIN silver.fact_ratings AS fr
    ON dm.movie_id = fr.movie_id
GROUP BY dm.movie_id, dm.title, dm.genres;
