WITH RECURSIVE input(value) AS (
    VALUES (12)
),
abc AS (
    SELECT null::bigint AS value,
           0 AS idx,
           null::int AS x,
           null::int AS y,
           0 AS next_x,
           0 AS next_y,
           null::point AS debug,
           null::int[] AS debug2,
           ARRAY[1,0]::int[] AS direction,
           jsonb_build_object(point(0, 0)::text, 1) AS sum_values
    UNION ALL
    SELECT (sum_values->>(point(next_x, next_y)::text))::bigint,
           idx + 1,
           next_x,
           next_y,
           next_x+direction[1],
           next_y+direction[2],
           point(next_x+direction[1], next_y+direction[2]),
           direction,
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
           (sum_values - point(next_x+direction[1],next_y+direction[2])::text)
            ||jsonb_build_object(point(next_x-1, next_y-1), value)
            ||jsonb_build_object(point(next_x-1, next_y), value)
            ||jsonb_build_object(point(next_x-1, next_y+1), value)
            ||jsonb_build_object(point(next_x, next_y-1), value)
            ||jsonb_build_object(point(next_x, next_y+1), value)
            ||jsonb_build_object(point(next_x+1, next_y-1), value)
            ||jsonb_build_object(point(next_x+1, next_y), value)
            ||jsonb_build_object(point(next_x+1, next_y+1), value)
      FROM abc
     WHERE idx < (SELECT value FROM input)
)
SELECT
    value,
    idx,
    x,
    y,
    debug,
    debug2,
    direction
    --jsonb_pretty(sum_values)
FROM
    abc;
