-- Hall of Fame

-- CREATE VIEW: top_lifter_facts
-- Purpose: one row per lifter with best lifts + participation and wins.

CREATE OR REPLACE VIEW top_lifter_facts AS
WITH

-- Best total per lifter (if available)
best_total AS (
    SELECT 
        lifter_id,
        MAX(total) AS best_total
    FROM powerlifting_facts
    WHERE total IS NOT NULL
    GROUP BY lifter_id
),

-- Meet details where best total occurred (used to extract equipment)
best_total_details AS (
    SELECT DISTINCT ON (f.lifter_id)
        f.lifter_id,
        f.total AS best_total,
        f.equipment
    FROM powerlifting_facts f
    JOIN best_total bt 
      ON f.lifter_id = bt.lifter_id AND f.total = bt.best_total
    ORDER BY f.lifter_id, 
             CASE WHEN f.bench IS NOT NULL THEN 1 ELSE 0 END DESC,
             f.bench DESC
),

-- Tie-break rule: if multiple entries share the same best total, pick the row with the highest bench as the representative record.

-- Best bench per lifter (from entries with total recorded)
best_bench AS (
    SELECT DISTINCT ON (f.lifter_id)
        f.lifter_id, f.bench
    FROM powerlifting_facts f
    WHERE f.bench IS NOT NULL AND f.total IS NOT NULL
    ORDER BY f.lifter_id, f.bench DESC
),

-- Best squat per lifter (from entries with total recorded)
best_squat AS (
    SELECT DISTINCT ON (f.lifter_id)
        f.lifter_id, f.squat
    FROM powerlifting_facts f
    WHERE f.squat IS NOT NULL AND f.total IS NOT NULL
    ORDER BY f.lifter_id, f.squat DESC
),

-- Best deadlift per lifter (from entries with total recorded)
best_deadlift AS (
    SELECT DISTINCT ON (f.lifter_id)
        f.lifter_id, f.deadlift
    FROM powerlifting_facts f
    WHERE f.deadlift IS NOT NULL AND f.total IS NOT NULL
    ORDER BY f.lifter_id, f.deadlift DESC
),

-- Aggregated participation and wins (raw counts)
aggregates AS (
    SELECT
        lifter_id,
        COUNT(*) AS meet_count,
        COUNT(*) FILTER (WHERE first_place = TRUE) AS win_count
    FROM powerlifting_facts
    GROUP BY lifter_id
)

-- Final lifter-centric output
SELECT
    l.lifter_id,
    l.name,
    l.sex,
    l.country_lifter,
    btd.best_total AS total,
    be.bench AS bench,
    sq.squat AS squat,
    dl.deadlift AS deadlift,
    btd.equipment AS equipment_type,
    agg.meet_count,
    agg.win_count
FROM dim_lifter l
LEFT JOIN best_total_details btd ON btd.lifter_id = l.lifter_id
LEFT JOIN best_bench be ON be.lifter_id = l.lifter_id
LEFT JOIN best_squat sq ON sq.lifter_id = l.lifter_id
LEFT JOIN best_deadlift dl ON dl.lifter_id = l.lifter_id
LEFT JOIN aggregates agg ON agg.lifter_id = l.lifter_id;

-- Notes:
-- - Best total and best lifts exclude total-null entries (disqualified/incomplete).
-- - meet_count and win_count are computed over all fact rows for the lifter (as defined in powerlifting_facts).

-- Q1: Top 3 lifters with the most competitions entered

-- Male lifters
SELECT name, meet_count
FROM top_lifter_facts
WHERE sex = 'Male' AND meet_count IS NOT NULL
ORDER BY meet_count DESC
LIMIT 3;

-- Female lifters
SELECT name, meet_count
FROM top_lifter_facts
WHERE sex = 'Female' AND meet_count IS NOT NULL
ORDER BY meet_count DESC
LIMIT 3;

-- Q2: Top 3 lifters with the most competition wins

-- Male lifters
SELECT name, win_count
FROM top_lifter_facts
WHERE sex = 'Male' AND win_count IS NOT NULL
ORDER BY win_count DESC
LIMIT 3;

-- Female lifters
SELECT name, win_count
FROM top_lifter_facts
WHERE sex = 'Female' AND win_count IS NOT NULL
ORDER BY win_count DESC
LIMIT 3;

-- Q3: Top 3 lifters by all-time total (kg)

-- Male lifters
SELECT name, total
FROM top_lifter_facts
WHERE sex = 'Male' AND total IS NOT NULL
ORDER BY total DESC
LIMIT 3;

-- Female lifters
SELECT name, total
FROM top_lifter_facts
WHERE sex = 'Female' AND total IS NOT NULL
ORDER BY total DESC
LIMIT 3;

-- Q4: Best bench press results (top 3)

-- Male lifters
SELECT name, bench
FROM top_lifter_facts
WHERE sex = 'Male' AND bench IS NOT NULL
ORDER BY bench DESC
LIMIT 3;

-- Female lifters
SELECT name, bench
FROM top_lifter_facts
WHERE sex = 'Female' AND bench IS NOT NULL
ORDER BY bench DESC
LIMIT 3;

-- Q5: Best deadlift results (top 3)

-- Male lifters
SELECT name, deadlift
FROM top_lifter_facts
WHERE sex = 'Male' AND deadlift IS NOT NULL
ORDER BY deadlift DESC
LIMIT 3;

-- Female lifters
SELECT name, deadlift
FROM top_lifter_facts
WHERE sex = 'Female' AND deadlift IS NOT NULL
ORDER BY deadlift DESC
LIMIT 3;

-- Q6: Best squat results (top 3)

-- Male lifters
SELECT name, squat
FROM top_lifter_facts
WHERE sex = 'Male' AND squat IS NOT NULL
ORDER BY squat DESC
LIMIT 3;

-- Female lifters
SELECT name, squat
FROM top_lifter_facts
WHERE sex = 'Female' AND squat IS NOT NULL
ORDER BY squat DESC
LIMIT 3;
