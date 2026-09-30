CREATE OR REFRESH MATERIALIZED VIEW gold.vw_scatter_popularity_vs_quality
COMMENT 'Filmes com 50+ avaliações: popularidade vs qualidade'
AS
SELECT
    movie_id,
    title,
    genres,
    total_rating,
    avg_rating
FROM gold.vw_movies_kpis
WHERE total_rating >= 50;
