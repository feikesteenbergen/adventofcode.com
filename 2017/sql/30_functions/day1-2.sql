DEALLOCATE day1_2;
PREPARE day1_2 AS
WITH RECURSIVE input (no, item) AS (
    SELECT *
      FROM regexp_split_to_table($1::text, '')
        WITH ORDINALITY
)
SELECT
    coalesce(sum(a.no::int), 0) AS captcha
FROM
    input a
CROSS JOIN
    (SELECT count(*) FROM input) AS sub(length)
JOIN
    input b ON ((a.item+length/2)%length = b.item%length AND a.no=b.no);

-- Example values
EXECUTE day1_2('1212');
EXECUTE day1_2('1221');
EXECUTE day1_2('123425');
EXECUTE day1_2('123123');
EXECUTE day1_2('12131415');

-- my personal value
SELECT input FROM adventofcode.input WHERE day=1
\gset
EXECUTE day1_2(:'input');