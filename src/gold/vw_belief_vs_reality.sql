CREATE OR REFRESH MATERIALIZED VIEW gold.vw_belief_vs_reality
COMMENT 'Gap entre o rating esperado antes de assistir e o rating real'
AS
SELECT
    b.user_id,
    b.movie_id,
    m.title,
    m.genres,
    b.user_predict_rating AS expected_rating,
    f.rating AS actual_rating,
    b.user_certainty,
    f.rating - b.user_predict_rating AS expectation_gap,
    ABS(f.rating - b.user_predict_rating) AS abs_expectation_gap
FROM silver.fact_belief_data AS b
INNER JOIN silver.fact_ratings AS f
    ON b.user_id = f.user_id AND b.movie_id = f.movie_id
INNER JOIN silver.dim_movies AS m
    ON b.movie_id = m.movie_id
WHERE
    b.is_seen = 0
    AND b.user_predict_rating IS NOT NULL
    AND f.rating IS NOT NULL;
