DEALLOCATE day7_1;

PREPARE day7_1 AS
WITH input(input) AS (
    SELECT trim($1::text)
), data AS (
    SELECT
        tokens[1] AS name,
        tokens[2] AS weight,
        item
    FROM
        input,
        LATERAL regexp_split_to_table(input, E'\n') AS rstt(line),
        LATERAL regexp_matches(line, '(\w+) \((\d+)\) -> (.*)') AS rm(tokens),
        LATERAL regexp_split_to_table(tokens[3], ', ') AS rstt2(item)
)
SELECT DISTINCT
    a.name
FROM
    data a
LEFT JOIN
    data b ON (a.name=b.item)
WHERE
    b.item IS NULL;

-- my personal value
SELECT input FROM adventofcode.input WHERE day=7
\gset
EXECUTE day7_1(:'input');
