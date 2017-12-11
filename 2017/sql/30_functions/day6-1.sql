DEALLOCATE day6_1;
PREPARE day6_1 AS
WITH RECURSIVE data(banks, size) AS (
    SELECT
        banks::bigint[],
        array_length(banks, 1)
    FROM
        trim(coalesce(nullif($1, ''), (SELECT input FROM input WHERE day=6))) AS sub(t),
        LATERAL regexp_split_to_array(t, '\s+') WITH ordinality AS rsta(banks)
) , iterate AS (
    SELECT
        0::int AS round,
        banks,
        size,
        null::bigint AS max,
        null::bigint AS idx,
        banks AS new_bank
    FROM
        data
    UNION ALL
    SELECT
        round + 1,
        i.new_bank,
        size,
        m.max,
        if.idx,
        d.new_bank
    FROM
        iterate AS i,
        LATERAL (SELECT max(unnest) FROM unnest(i.new_bank)) AS m(max),
        LATERAL (SELECT min(ordinality) FROM unnest(i.new_bank) WITH ORDINALITY WHERE unnest=m.max) AS if(idx),
        LATERAL (SELECT
                    array_agg(
                        CASE ORDINALITY
                            WHEN if.idx 
                            THEN 0
                            ELSE unnest
                        END +
                        (m.max/size) +
                        CASE 
                            WHEN if.idx <= (m.max%size)
                            THEN 1
                            ELSE 0
                        END
                    )
                 FROM
                    unnest(i.new_bank) WITH ORDINALITY
                ) as d(new_bank)
    WHERE
        round < 200
)
SELECT
    *
FROM
    iterate
;