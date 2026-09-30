CREATE OR REFRESH STREAMING TABLE bronze.raw_user_rating_history
COMMENT 'Histórico de avaliações dos usuários (CSV sem transformação)'
AS
SELECT
    *,
    _metadata.file_path AS _source_file,
    current_timestamp() AS _ingested_at
FROM STREAM read_files(
    '${landing_path}/user_rating_history/',
    format => 'csv',
    header => true,
    multiLine => true,
    schema => 'userid STRING, movieid STRING, rating STRING, tstamp STRING'
);
