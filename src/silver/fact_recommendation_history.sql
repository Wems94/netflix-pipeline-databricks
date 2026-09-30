CREATE OR REFRESH MATERIALIZED VIEW silver.fact_recommendation_history
COMMENT 'Histórico de recomendações do sistema com rating previsto'
AS
SELECT
    try_cast(nullif(userid, '') AS BIGINT) AS user_id,
    timestamp_seconds(try_cast(tstamp AS BIGINT)) AS recommendation_ts,
    try_cast(nullif(movieid, '') AS BIGINT) AS movie_id,
    try_cast(predictedrating AS DOUBLE) AS predicted_rating
FROM bronze.raw_user_recommendation_history
WHERE
    userid IS NOT NULL
    AND movieid IS NOT NULL;
