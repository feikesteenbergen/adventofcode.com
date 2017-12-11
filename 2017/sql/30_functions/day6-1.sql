DEALLOCATE day6_1;
PREPARE day6_1 AS
WITH RECURSIVE data(banks, size) AS (
    SELECT
        banks::smallint[],
        array_length(banks, 1)
    FROM
        trim(coalesce($1, (SELECT input FROM input WHERE day=6))) AS sub(t),
        LATERAL regexp_split_to_array(t, '\s+') WITH ordinality AS rsta(banks)
) , iterate AS (
    SELECT
        1::int AS round,
        banks,
        size,
        null::bigint AS max,
        null::bigint AS idx,
        banks AS new_bank,
        ARRAY[]::text[] AS history
    FROM
        data
    UNION ALL
    SELECT
        round + 1,
        i.new_bank,
        size,
        m.max,
        if.idx,
        d.new_bank,
        history||d.new_bank::text
    FROM
        iterate AS i,
        LATERAL (SELECT max(unnest) FROM unnest(i.new_bank)) AS m(max),
        LATERAL (SELECT min(ordinality) FROM unnest(i.new_bank) WITH ORDINALITY WHERE unnest=m.max) AS if(idx),
        LATERAL (SELECT
                    array_agg(
                        CASE ordinality
                            WHEN if.idx 
                            THEN m.max/size
                            ELSE 
                                unnest +
                                m.max/size +
                                CASE 
                                    -- We need to index the bank being emptied as 0, as
                                    -- we distribute the items clockwise
                                    WHEN (ordinality-if.idx+size)%size <= (m.max%size)
                                    THEN 1
                                    ELSE 0
                                END     
                        END
                    )::smallint[]
                 FROM
                    unnest(i.new_bank) WITH ORDINALITY
                ) as d(new_bank)
    WHERE
        NOT d.new_bank::text = ANY (history)
)
SELECT
    max(round)
FROM
    iterate
;
EXECUTE day6_1('0 2 7 0');