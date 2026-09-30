CREATE OR REFRESH STREAMING TABLE bronze.raw_movies
COMMENT 'Filmes brutos do MovieLens (CSV sem transformação)'
AS
SELECT
    *,
    _metadata.file_path AS _source_file,
    current_timestamp() AS _ingested_at
FROM STREAM read_files(
    '${landing_path}/movies/',
    format => 'csv',
    header => true,
    multiLine => true,
    escape => '"',
    schema => 'movieid STRING, title STRING, genres STRING'
);
