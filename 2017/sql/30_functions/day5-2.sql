CREATE OR REPLACE FUNCTION day5_part2 (text default null)
RETURNS bigint
LANGUAGE SQL AS $BODY$
WITH RECURSIVE vals AS (
    SELECT
        jumps::bigint[]
    FROM
        trim(coalesce($1, (SELECT input FROM input WHERE day=5))) AS t(v),
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
LIMIT 1
$BODY$;
