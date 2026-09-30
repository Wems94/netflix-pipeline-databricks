CREATE OR REFRESH STREAMING TABLE bronze.raw_user_recommendation_history
COMMENT 'Histórico de recomendações do sistema (CSV sem transformação)'
AS
SELECT
    *,
    _metadata.file_path AS _source_file,
    current_timestamp() AS _ingested_at
FROM STREAM read_files(
    '${landing_path}/user_recommendation_history/',
    format => 'csv',
    header => true,
    multiLine => true,
    schema => 'userid STRING, tstamp STRING, movieid STRING, predictedrating STRING'
);
