CREATE OR REFRESH STREAMING TABLE bronze.raw_ratings_for_additional_users
COMMENT 'Avaliações de usuários adicionais (CSV sem transformação)'
AS
SELECT
    *,
    _metadata.file_path AS _source_file,
    current_timestamp() AS _ingested_at
FROM STREAM read_files(
    '${landing_path}/ratings_for_additional_users/',
    format => 'csv',
    header => true,
    multiLine => true,
    schema => 'userid STRING, movieid STRING, rating STRING, tstamp STRING'
);
