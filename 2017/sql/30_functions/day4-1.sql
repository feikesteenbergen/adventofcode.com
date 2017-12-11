DEALLOCATE day4_1;

PREPARE day4_1 AS
WITH input (input) AS (
    SELECT $1::text
), valid_phrases AS (
    SELECT
        line
    FROM
        input,
        LATERAL regexp_split_to_table(input, E'\n') WITH ORDINALITY AS s(passphrase, line),
        LATERAL regexp_split_to_table(passphrase, '\s+') AS p(word)
    GROUP BY
        line
    HAVING
        count(word) = count(distinct word)
)
SELECT
    count(*)
FROM
    valid_phrases;

-- my personal value
SELECT input FROM adventofcode.input WHERE day=4
\gset
EXECUTE day4_1(:'input');