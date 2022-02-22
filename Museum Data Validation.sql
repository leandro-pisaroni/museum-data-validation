%%sql
postgresql:///roman

WITH birthplaces AS(
    SELECT
        index,
        (CASE WHEN birth_city IS NOT NULL
        THEN birth_city
        ELSE 'Unknown' END) AS city,
        (CASE WHEN birth_province IS NOT NULL
        THEN birth_province
        ELSE 'Unknown' END) AS province
    FROM emperors
),
ages AS(
    SELECT
        index,
        DATE_PART('year', AGE(CAST(death AS DATE), CAST(birth AS DATE))) AS age_death
    FROM emperors
),
reigns AS(
    SELECT
        index,
        DATE_PART('year', AGE(CAST(reign_end AS DATE), CAST(reign_start AS DATE))) AS reign_duration
    FROM emperors
)


SELECT
    DISTINCT CAST(UPPER(e.name) AS TEXT) AS name,
    CAST(LOWER(full_name) AS TEXT) as full_name,
    (CASE WHEN (bp.city = 'Unknown' AND bp.province = 'Unknown') THEN CAST('Unknown' AS TEXT)
         ELSE CAST(bp.city || ', ' || bp.province AS TEXT) END) AS birthplace,
    (CASE WHEN a.age_death IS NOT NULL THEN CAST(a.age_death AS TEXT) ELSE CAST('Unknown' AS TEXT) END) AS age,
    (CASE WHEN r.reign_duration IS NOT NULL THEN CAST(r.reign_duration AS TEXT) ELSE CAST('Unknown' AS TEXT) END) AS reign,
    (CASE WHEN LOWER(cause) IN ('assassination', 'natural causes', 'execution', 'died in battle', 'suicide')
        THEN CAST(cause AS TEXT)
        ELSE CAST('Other' AS TEXT) END) AS cod,
    (CASE WHEN DATE_PART('year', CAST(reign_start AS DATE)) < 284 THEN 'Principate' ELSE 'Dominate' END) AS era
FROM emperors AS e
INNER JOIN birthplaces AS bp
USING(index)
INNER JOIN ages AS a
USING(index)
INNER JOIN reigns AS r
USING(index)
ORDER BY name;
