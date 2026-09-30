CREATE OR REFRESH STREAMING TABLE bronze.raw_movie_elicitation_set
COMMENT 'Conjunto de filmes usados na elicitação (CSV sem transformação)'
AS
SELECT
    *,
    _metadata.file_path AS _source_file,
    current_timestamp() AS _ingested_at
FROM STREAM read_files(
    '${landing_path}/movie_elicitation_set/',
    format => 'csv',
    header => true,
    multiLine => true,
    schema => 'movieid STRING, month_idx STRING, source STRING, tstamp STRING'
);
