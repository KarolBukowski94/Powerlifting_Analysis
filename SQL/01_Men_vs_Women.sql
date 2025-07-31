-- 🏋️🏋️‍♀️ Men vs Women

-- Q1: How many total meet entries and unique lifters are recorded?

SELECT 
    COUNT(*) AS total_meet_entries,             -- 3,041,186 total entries
    COUNT(DISTINCT lifter_id) AS unique_lifters -- 797,946 individual lifters
FROM powerlifting_facts;

-- Each row in the fact table represents a single competition entry.
-- This query provides two metrics:
--   • Total number of recorded meet entries (1 entry = 1 lifter at 1 meet)
--   • Number of unique lifters in the dataset (based on lifter_id)
-- Used in Power BI card visual and tooltip for overview summary.

-- Q2: What is the sex distribution among all meet entries?

WITH counts AS (
    SELECT 
        l.sex,
        COUNT(*) AS entry_count
    FROM powerlifting_facts f
    JOIN dim_lifter l ON f.lifter_id = l.lifter_id
    GROUP BY l.sex
)
SELECT 
    sex,
    ROUND(100.0 * entry_count::numeric / SUM(entry_count) OVER (), 1) AS percent_share
FROM counts;

-- Calculates how entries are distributed between male and female lifters.
-- Percentage is computed from grouped entry counts.

-- Q3: What is the average total lifted (kg) by sex?

SELECT 
    l.sex,
    ROUND(AVG(f.total), 0) AS avg_total_kg
FROM powerlifting_facts f
JOIN dim_lifter l ON f.lifter_id = l.lifter_id
WHERE 
    f.squat IS NOT NULL AND
    f.bench IS NOT NULL AND
    f.deadlift IS NOT NULL AND
    f.total IS NOT NULL
GROUP BY l.sex
ORDER BY l.sex;

-- Considers only valid full competitions (squat + bench + deadlift present, and a recorded total).
-- Excludes disqualifications and incomplete entries with missing total score.
-- Matches the logic used in Power BI to report average performance in completed meets.

-- Q4: What are the average lift results (kg) by sex ?

SELECT 
    l.sex,
    ROUND(AVG(squat), 0) AS avg_squat_kg,
    ROUND(AVG(bench), 0) AS avg_bench_kg,
    ROUND(AVG(deadlift), 0) AS avg_deadlift_kg
FROM powerlifting_facts f
JOIN dim_lifter l ON f.lifter_id = l.lifter_id
WHERE f.total IS NOT NULL
GROUP BY l.sex;

-- Computes the average for each lift type (squat, bench, deadlift), grouped by sex.
-- Entries are included only if the lifter received a valid 'total' score.
-- This excludes disqualifications and incomplete attempts.
-- Matches logic used in Power BI for clean lift summaries.

-- Q5: What is the breakdown of lift combinations by sex?

SELECT 
    l.sex,
    f.lift_combination,
    ROUND(100.0 * COUNT(*)::numeric / SUM(COUNT(*)) OVER (PARTITION BY l.sex), 1) AS percent_share
FROM powerlifting_facts f
JOIN dim_lifter l ON f.lifter_id = l.lifter_id
WHERE f.lift_combination IS NOT NULL
GROUP BY l.sex, f.lift_combination
ORDER BY l.sex, percent_share DESC;

-- Uses the derived column 'lift_combination' (All lifts, Two lifts, Single lift).
-- Shows participation pattern across complete/incomplete events.
-- Lift combination classification excludes disqualified entries (total IS NULL).


-- Q6: Among single-lift entries, which event is most popular by sex?

SELECT 
    l.sex,
    f.single_lift_type AS lift_type,
    ROUND(100.0 * COUNT(*)::numeric / SUM(COUNT(*)) OVER (PARTITION BY l.sex), 1) AS percent_share
FROM powerlifting_facts f
JOIN dim_lifter l ON f.lifter_id = l.lifter_id
WHERE f.single_lift_type IS NOT NULL
GROUP BY l.sex, f.single_lift_type
ORDER BY l.sex, percent_share DESC;

-- Shows popularity of individual lifts (Bench, Squat, Deadlift) for single-lift events.
-- Uses derived column 'single_lift_type', excluding disqualified entries.


-- Q7: How much does each lift contribute to the total (by sex)?

WITH avg_lifts AS (
    SELECT 
        l.sex,
        AVG(f.squat) AS avg_squat,
        AVG(f.bench) AS avg_bench,
        AVG(f.deadlift) AS avg_deadlift
    FROM powerlifting_facts f
    JOIN dim_lifter l ON f.lifter_id = l.lifter_id
    WHERE f.total IS NOT NULL
    GROUP BY l.sex
)
SELECT 
    sex,
    ROUND(100.0 * avg_bench / (avg_bench + avg_squat + avg_deadlift), 1) AS bench_pct_of_total,
    ROUND(100.0 * avg_squat / (avg_bench + avg_squat + avg_deadlift), 1) AS squat_pct_of_total,
    ROUND(100.0 * avg_deadlift / (avg_bench + avg_squat + avg_deadlift), 1) AS deadlift_pct_of_total
FROM avg_lifts;

-- Calculates relative contribution of each lift to the total average performance.
-- Based only on valid entries (where total is recorded), including partial events.
-- Excludes disqualified and null-total entries to reflect clean comparative trends.