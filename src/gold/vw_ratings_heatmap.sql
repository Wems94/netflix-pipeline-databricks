CREATE OR REFRESH MATERIALIZED VIEW gold.vw_ratings_heatmap
COMMENT 'Volume de ratings por mês e ano'
AS
SELECT
    year(rating_ts) AS year,
    month(rating_ts) AS month_number,
    date_format(rating_ts, 'MMM') AS month_name,
    count(*) AS total_ratings
FROM silver.fact_ratings
GROUP BY year, month_number, month_name;
