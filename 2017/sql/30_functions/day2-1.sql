DEALLOCATE day2_1;

PREPARE day2_1 AS
WITH input(input) AS (
    SELECT
        regexp_split_to_array(i, '\s+')::bigint[]
    FROM
        regexp_split_to_table($1::text, '\n')
            AS sub(i)
)
SELECT
    sum((SELECT max(unnest) FROM unnest(input)) - (SELECT min(unnest) FROM unnest(input)))
FROM
    input;

-- my personal value
SELECT input FROM adventofcode.input WHERE day=2
\gset
EXECUTE day2_1(:'input');