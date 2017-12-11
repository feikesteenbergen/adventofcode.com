DEALLOCATE day4_2;

PREPARE day4_2 AS
WITH input (input) AS (
    SELECT $1::text
), sorted_phrases AS (
    SELECT
        line,
        item,
        string_agg(letter, '' order by letter) AS word_sorted
    FROM
        input,
        LATERAL regexp_split_to_table(input, E'\n') WITH ORDINALITY AS s(passphrase, line),
        LATERAL regexp_split_to_table(passphrase, '\s+') WITH ORDINALITY AS p(word, item),
        LATERAL regexp_split_to_table(word, '') AS w(letter)
    GROUP BY
        line,
        item
), valid_phrases AS (
    SELECT
        line
    FROM
        sorted_phrases
    GROUP BY
        line
    HAVING
        count(word_sorted) = count(distinct word_sorted)
)
SELECT
    count(*)
FROM
    valid_phrases;


EXECUTE day4_2('abcde fghij');
EXECUTE day4_2('abcde xyz ecdab');
EXECUTE day4_2('iiii oiii ooii oooi oooo');
EXECUTE day4_2('oiii ioii iioi iiio');
EXECUTE day4_2('a ab abc abd abf abj');

-- my personal value
SELECT input FROM adventofcode.input WHERE day=4
\gset
EXECUTE day4_2(:'input');