DEALLOCATE day7_2;

PREPARE day7_2 AS
WITH RECURSIVE data AS (
    SELECT
        tokens[1] AS name,
        tokens[2]::bigint AS weight,
        nullif(items, '{""}') AS items
    FROM
        trim($1::text) AS t(input),
        LATERAL regexp_split_to_table(input, E'\n') AS rstt(line),
        LATERAL regexp_matches(line, '(\w+) \((\d+)\)(?: -> (.*))?') AS rm(tokens),
        LATERAL regexp_split_to_array(coalesce(tokens[3], ''), ', ') AS rstt2(items)
), root AS (
    SELECT
        name,
        weight,
        items,
        ARRAY[name] AS path,
        0 AS level,
        items is null AS leaf
    FROM
        data
    WHERE
        name NOT IN (SELECT unnest(items) FROM data)
    UNION ALL
    SELECT
        b.name,
        b.weight,
        b.items,
        path||b.name,
        level + 1,
        b.items is null
    FROM
        root a
    JOIN
        data b ON (b.name = ANY (a.items))
), test AS (
    SELECT
        a.name,
        a.level,
        sum(b.weight) + a.weight AS sum_weight,
        a.path
    FROM
        root a
    JOIN
        root b ON (b.path @> a.path AND a.name != b.name)
    GROUP BY
        a.name,
        a.level,
        a.weight,
        a.path
), discrepancy AS (
    SELECT
        level,
        path[:level] AS path
    FROM
        test
    GROUP BY
        level,
        path[:level]
    HAVING
        min(sum_weight) != max(sum_weight)
    ORDER BY
        level DESC
    LIMIT 1
), mode (path, mode) AS (
    SELECT
        a.path,
        mode() WITHIN GROUP (ORDER BY sum_weight)
    FROM 
        discrepancy a
    JOIN
        test b ON (a.path||b.name = b.path)
    GROUP BY
        a.path
)
SELECT
    c.name,
    weight::bigint AS current_weight,
    (weight + (mode - sum_weight))::bigint AS correct_weight
FROM
    mode a
JOIN
    test b ON (a.path||b.name = b.path)
JOIN
    root c ON (b.path = c.path)
WHERE
    sum_weight != mode
;

-- my personal value
SELECT input FROM adventofcode.input WHERE day=7
\gset
EXECUTE day7_2(:'input');
