CREATE OR REFRESH MATERIALIZED VIEW gold.vw_user_activity
COMMENT 'Atividade e engajamento por usuário'
AS
SELECT
    user_id,
    COUNT(*) AS total_ratings,
    COUNT(DISTINCT movie_id) AS distinct_movies_rated,
    AVG(rating) AS avg_rating,
    STDDEV(rating) AS std_rating,
    MIN(rating_ts) AS first_activity_ts,
    MAX(rating_ts) AS last_activity_ts
FROM silver.fact_ratings
GROUP BY user_id;
