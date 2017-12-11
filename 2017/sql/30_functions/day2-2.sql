DEALLOCATE day2_2;

PREPARE day2_2 AS
WITH input(input, line) AS (
    SELECT
        regexp_split_to_array(regexp_split_to_table, '\s+')::bigint[],
        ordinality
    FROM
        regexp_split_to_table($1::text, '\n')
            WITH ordinality
),  exploded(line, cell) AS (
    SELECT
        line,
        unnest(input)
    FROM
        input
)
SELECT
    sum(a.cell/b.cell)
FROM
    exploded a
JOIN
    exploded b ON (a.line = b.line AND a.cell%b.cell=0 AND a.cell != b.cell);

-- my personal value
SELECT input FROM adventofcode.input WHERE day=2
\gset
EXECUTE day2_2(:'input');