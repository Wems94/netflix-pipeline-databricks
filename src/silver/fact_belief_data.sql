CREATE OR REFRESH MATERIALIZED VIEW silver.fact_belief_data
COMMENT 'Crenças elicitadas: rating esperado pelo usuário antes de assistir'
AS
SELECT
    try_cast(nullif(userid, '') AS BIGINT) AS user_id,
    try_cast(nullif(movieid, '') AS BIGINT) AS movie_id,
    try_cast(isseen AS INT) AS is_seen,
    try_to_date(left(watchdate, 10), 'yyyy-MM-dd') AS watch_date,
    try_cast(userelicitrating AS DOUBLE) AS user_elicit_rating,
    try_cast(userpredictrating AS DOUBLE) AS user_predict_rating,
    try_cast(usercertainty AS DOUBLE) AS user_certainty,
    coalesce(
        try_to_timestamp(tstamp, 'yyyy-MM-dd HH:mm:ssXXX'),
        try_to_timestamp(tstamp, 'yyyy-MM-dd HH:mm:ss')
    ) AS belief_ts,
    try_cast(movie_idx AS INT) AS movie_idx,
    try_cast(source AS INT) AS source,
    try_cast(systempredictrating AS DOUBLE) AS system_predict_rating
FROM bronze.raw_belief_data
WHERE
    userid IS NOT NULL
    AND movieid IS NOT NULL;
