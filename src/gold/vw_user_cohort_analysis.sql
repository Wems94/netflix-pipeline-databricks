CREATE OR REFRESH MATERIALIZED VIEW gold.vw_user_cohort_analysis
COMMENT 'Retenção e engajamento de usuários por coorte de entrada'
AS
WITH first_rating AS (
    SELECT
        user_id,
        trunc(to_date(min(rating_ts)), 'MM') AS cohort_month
    FROM silver.fact_ratings
    GROUP BY user_id
),

activity AS (
    SELECT
        f.user_id,
        fr.cohort_month,
        trunc(to_date(f.rating_ts), 'MM') AS activity_month,
        timestampdiff(
            MONTH,
            fr.cohort_month,
            trunc(to_date(f.rating_ts), 'MM')
        ) AS months_since_cohort,
        count(*) AS ratings_in_month
    FROM silver.fact_ratings AS f
    INNER JOIN first_rating AS fr
        ON f.user_id = fr.user_id
    GROUP BY f.user_id, fr.cohort_month, activity_month, months_since_cohort
)

SELECT
    cohort_month,
    months_since_cohort,
    count(DISTINCT user_id) AS active_users,
    sum(ratings_in_month) AS total_ratings
FROM activity
GROUP BY cohort_month, months_since_cohort;
