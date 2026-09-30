CREATE OR REFRESH STREAMING TABLE bronze.raw_belief_data
COMMENT 'Crenças elicitadas dos usuários (CSV sem transformação)'
AS
SELECT
    *,
    _metadata.file_path AS _source_file,
    current_timestamp() AS _ingested_at
FROM STREAM read_files(
    '${landing_path}/belief_data/',
    format => 'csv',
    header => true,
    multiLine => true,
    schema => '
        userid STRING,
        movieid STRING,
        isseen STRING,
        watchdate STRING,
        userelicitrating STRING,
        userpredictrating STRING,
        usercertainty STRING,
        tstamp STRING,
        movie_idx STRING,
        source STRING,
        systempredictrating STRING
    '
);
