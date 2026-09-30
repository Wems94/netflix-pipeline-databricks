CREATE OR REFRESH MATERIALIZED VIEW gold.vw_recommendation_accuracy
COMMENT 'MAE e RMSE do sistema de recomendação por filme'
AS
SELECT
    r.movie_id,
    m.title,
    m.genres,
    COUNT(*) AS total_predictions,
    AVG(ABS(r.predicted_rating - f.rating)) AS mae,
    SQRT(AVG(POW(r.predicted_rating - f.rating, 2))) AS rmse,
    AVG(r.predicted_rating) AS avg_predicted,
    AVG(f.rating) AS avg_actual
FROM silver.fact_recommendation_history AS r
INNER JOIN silver.fact_ratings AS f
    ON r.user_id = f.user_id AND r.movie_id = f.movie_id
INNER JOIN silver.dim_movies AS m
    ON r.movie_id = m.movie_id
GROUP BY r.movie_id, m.title, m.genres;
