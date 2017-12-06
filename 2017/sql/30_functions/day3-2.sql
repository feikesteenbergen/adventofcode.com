WITH RECURSIVE input(value) AS (
    VALUES (289326)
),
my_recursion AS (
    SELECT null::bigint AS value,
           0 AS idx,
           null::int AS x,
           null::int AS y,
           0 AS next_x,
           0 AS next_y,
           ARRAY[1,0]::int[] AS direction,
           jsonb_build_object(point(0, 0)::text, 1) AS sum_values
    UNION ALL
    SELECT v,
           idx + 1,
           next_x,
           next_y,
           next_x+direction[1],
           next_y+direction[2],
           -- Any time we don't see any value in front of us we need
           -- to "turn left"
           CASE sum_values ? point(next_x+2*direction[1], next_y+2*direction[2])::text
                WHEN true
                THEN direction
                ELSE
                CASE direction
                    WHEN ARRAY[0,1]
                    THEN ARRAY[1,0]
                    WHEN ARRAY[1,0]
                    THEN ARRAY[0,-1]
                    WHEN ARRAY[0,-1]
                    THEN ARRAY[-1,0]
                    WHEN ARRAY[-1,0]
                    THEN ARRAY[0,1]
                END
           END,
            -- We add the current value to all our neighbours
            sum_values||
            (SELECT jsonb_object_agg(p::text, v + coalesce((sum_values->>(p::text))::int, 0))
               FROM (
                    VALUES (point(next_x-1, next_y-1)),
                           (point(next_x-1, next_y)),
                           (point(next_x-1, next_y+1)),
                           (point(next_x, next_y-1)),
                           (point(next_x, next_y+1)),
                           (point(next_x+1, next_y+1)),
                           (point(next_x+1, next_y)),
                           (point(next_x+1, next_y-1))
               ) sub(p)
            )
      FROM my_recursion,
      LATERAL (VALUES ((sum_values->>(point(next_x, next_y)::text))::bigint)) AS v(v)
     WHERE v < (SELECT value*10 FROM input)
)
SELECT
    idx,
    mr.value
FROM
    my_recursion mr
JOIN
    input i ON (mr.value > i.value)
ORDER BY
    mr.value
LIMIT 1;
