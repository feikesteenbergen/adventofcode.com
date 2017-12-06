WITH RECURSIVE input(value) AS (
    VALUES (10)
),
abc AS (
    SELECT 1::bigint AS value,
           0 AS idx,
           0 AS x,
           -1 AS y,
           ARRAY[0,1]::int[] AS direction,
           jsonb_build_object(point(0, 0)::text, 1) AS sum_values
    UNION ALL
    SELECT (sum_values->>(point(x+direction[1], y+direction[2])::text))::bigint,
           idx + 1,
           x + direction[1],
           y + direction[2],
           CASE
                WHEN direction = ARRAY[1,0] AND NOT sum_values ? point(x+1, y-1)::text
                THEN ARRAY[0,-1]
                WHEN direction = ARRAY[0,-1] AND NOT sum_values ? point(x-1, y-1)::text
                THEN ARRAY[-1,0]
                WHEN direction = ARRAY[-1,0] AND NOT sum_values ? point(x-1, y+1)::text
                THEN ARRAY[0,1]
                WHEN direction = ARRAY[0,1] AND NOT sum_values ? point(x+1, y-1)::text
                THEN ARRAY[1,0]
                ELSE direction
           END,
           (sum_values - point(x+direction[1],y+direction[2])::text)
            ||jsonb_build_object(point(x-1, y-1), value)
            ||jsonb_build_object(point(x-1, y), value)
            ||jsonb_build_object(point(x-1, y+1), value)
            ||jsonb_build_object(point(x, y-1), value)
            ||jsonb_build_object(point(x, y+1), value)
            ||jsonb_build_object(point(x+1, y-1), value)
            ||jsonb_build_object(point(x+1, y), value)
            ||jsonb_build_object(point(x+1, y+1), value)
      FROM abc
     WHERE idx < (SELECT value FROM input)
)
SELECT
    value,
    idx,
    x,
    y,
    direction
    --jsonb_pretty(sum_values)
FROM
    abc;
