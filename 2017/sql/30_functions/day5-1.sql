DEALLOCATE day5_1;

PREPARE day5_1 AS
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
        jumps[0:position-1]||jumps[position]+1||jumps[position+1:]
    FROM
        jumping
    WHERE
        position + jumps[position] IS NOT NULL
)
SELECT
    max(count)
FROM
    jumping;

-- my personal value
SELECT input FROM adventofcode.input WHERE day=5
\gset
EXECUTE day5_1(:'input');