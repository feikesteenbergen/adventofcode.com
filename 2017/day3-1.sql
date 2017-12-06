WITH input AS (
    SELECT
        input,
        -- We determine the outer ring of the spiral, by
        -- calculating the min and max
        CASE WHEN lower%2=0
             THEN lower-1
             ELSE lower
        END::bigint AS lower,
        CASE WHEN lower%2=0
             THEN lower+1
             ELSE lower+2
        END::bigint AS upper
    FROM
        (VALUES (289326), (1024), (25), (26), (54), (49), (34), (39), (48), (3), (8)) AS v(input),
    LATERAL floor((input-1)^0.5) AS lb(lower)
) , spiral_info AS (
    SELECT
        upper/2 AS center_distance,
        lower,
        upper,
        input,
        -- The center positions can be reached by center_distance,
        -- The corner positions by center_distance+center_distance
        ARRAY[upper^2-circumference/8,
              upper^2-circumference/8*3,
              upper^2-circumference/8*5,
              upper^2-circumference/8*7]::bigint[] AS center_positions
    FROM
        input,
    LATERAL int8mi((upper^2)::bigint, (lower^2)::bigint) AS c(circumference)
)
SELECT
    input,
    center_distance + (SELECT min(abs(input-unnest)) FROM unnest(center_positions)) AS manhattan_distance
FROM
    spiral_info
ORDER BY
    input;
