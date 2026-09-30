CREATE OR REFRESH MATERIALIZED VIEW silver.fact_ratings
COMMENT 'Avaliações unificadas das duas fontes, deduplicadas e com surrogate key'
CLUSTER BY (movie_id, user_id)
AS
WITH all_ratings AS (
    SELECT
        try_cast(nullif(userid, '') AS BIGINT) AS user_id,
        try_cast(nullif(movieid, '') AS BIGINT) AS movie_id,
        try_cast(nullif(nullif(rating, 'NA'), '') AS DOUBLE) AS rating,
        coalesce(
            try_to_timestamp(tstamp, 'yyyy-MM-dd HH:mm:ssXXX'),
            try_to_timestamp(tstamp, 'yyyy-MM-dd HH:mm:ss')
        ) AS rating_ts,
        'user_rating_history' AS src
    FROM bronze.raw_user_rating_history

    UNION ALL

    SELECT
        try_cast(nullif(userid, '') AS BIGINT) AS user_id,
        try_cast(nullif(movieid, '') AS BIGINT) AS movie_id,
        try_cast(nullif(nullif(rating, 'NA'), '') AS DOUBLE) AS rating,
        coalesce(
            try_to_timestamp(tstamp, 'yyyy-MM-dd HH:mm:ssXXX'),
            try_to_timestamp(tstamp, 'yyyy-MM-dd HH:mm:ss')
        ) AS rating_ts,
        'rating_for_additional_users' AS src
    FROM bronze.raw_ratings_for_additional_users
),

deduped AS (
    SELECT *
    FROM all_ratings
    WHERE
        user_id IS NOT NULL
        AND movie_id IS NOT NULL
        AND rating IS NOT NULL
        AND rating_ts IS NOT NULL
    QUALIFY row_number() OVER (
        PARTITION BY user_id, movie_id, rating_ts
        ORDER BY src
    ) = 1
)

SELECT
    md5(concat_ws(
        '-',
        cast(user_id AS STRING),
        cast(movie_id AS STRING),
        cast(rating_ts AS STRING)
    )) AS rating_id,
    user_id,
    movie_id,
    rating,
    rating_ts,
    src
FROM deduped;
