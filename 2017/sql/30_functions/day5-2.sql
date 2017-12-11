DEALLOCATE day5_2;

PREPARE day5_2 AS
WITH RECURSIVE vals AS (
    SELECT
        jumps::bigint[]
    FROM
        trim($1::text) AS t(v),
        LATERAL regexp_split_to_array(v, E'\n') AS r(jumps)
), jumping AS (
    SELECT
        0::bigint AS count,
        1::bigint AS position,
        jumps
    FROM
        vals
    UNION ALL
    SELECT
        count+1,
        position + jumps[position],
        jumps[0:position-1]
        ||
            jumps[position] +
            CASE
                WHEN jumps[position] > 2
                THEN -1
                ELSE 1
            END
        ||jumps[position+1:]
    FROM
        jumping
    WHERE
        position + jumps[position] IS NOT NULL
)
SELECT
    count
FROM
    jumping
ORDER BY
    count DESC
LIMIT 1;


-- my personal value
SELECT input FROM adventofcode.input WHERE day=5
\gset
-- You need > 100GB of free space to execute this one ...
-- EXECUTE day5_2(:'input');
