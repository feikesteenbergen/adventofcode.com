DEALLOCATE day1_1;  
PREPARE day1_1 AS
WITH RECURSIVE input (no, item) AS (
    SELECT *
      FROM regexp_split_to_table($1::text, '')
        WITH ORDINALITY
), linked AS (
    SELECT
        no::int,
        coalesce(lead(no) OVER (ORDER BY item ASC), first_value(no) OVER (ORDER BY item ASC))::int AS next_no
    FROM
        input
)
SELECT
    coalesce(sum(no), 0) AS captcha
FROM
    linked
WHERE
    no = next_no;

-- example values
EXECUTE day1_1('1122');
EXECUTE day1_1('1111');
EXECUTE day1_1('1234');
EXECUTE day1_1('91212129');

-- my personal value
SELECT input FROM adventofcode.input WHERE day=1
\gset
EXECUTE day1_1(:'input');