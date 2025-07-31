-- # 🧤 Equipment Analysis 

-- NOTE:
-- All queries explicitly exclude entries labeled with 'Straps', as these are non-competition setups not sanctioned by federations.
-- This ensures consistency with Power BI filters and real-world meet conditions.

-- Q1: What is the distribution of equipment types among meet entries?

SELECT 
    equipment,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percent_share
FROM powerlifting_facts
WHERE equipment <> 'Straps'
GROUP BY equipment
ORDER BY percent_share DESC;

-- Returns percentage share of each equipment category (e.g., Raw, Wraps, Single-ply).

-- Q2: By how much does each equipment type improve performance compared to Raw?

WITH raw_avg AS (
    SELECT 
        ROUND(AVG(squat), 1) AS raw_squat,
        ROUND(AVG(bench), 1) AS raw_bench,
        ROUND(AVG(deadlift), 1) AS raw_deadlift
    FROM powerlifting_facts
    WHERE equipment = 'Raw'
      AND total IS NOT NULL
),
equipped_avg AS (
    SELECT 
        equipment,
        ROUND(AVG(squat), 1) AS avg_squat,
        ROUND(AVG(bench), 1) AS avg_bench,
        ROUND(AVG(deadlift), 1) AS avg_deadlift
    FROM powerlifting_facts
    WHERE total IS NOT NULL
      AND equipment NOT IN ('Straps', 'Raw')
    GROUP BY equipment
)
SELECT 
    e.equipment,
    ROUND(100.0 * (e.avg_squat - r.raw_squat) / r.raw_squat, 1) AS squat_gain_pct,
    ROUND(100.0 * (e.avg_bench - r.raw_bench) / r.raw_bench, 1) AS bench_gain_pct,
    ROUND(100.0 * (e.avg_deadlift - r.raw_deadlift) / r.raw_deadlift, 1) AS deadlift_gain_pct
FROM equipped_avg e
CROSS JOIN raw_avg r
ORDER BY bench_gain_pct DESC;

-- Calculates lift-specific gain (%) relative to Raw baseline.
-- Compares average result per lift between Raw and other equipment types.

-- Q3: What is the disqualification rate across all entries?

SELECT 
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE total IS NULL) / COUNT(*), 
        1
    ) AS dq_rate_pct
FROM powerlifting_facts;

-- Calculates the percentage of entries with no total value (total IS NULL).
-- This reflects disqualifications, failed attempts, or incomplete results.


-- Q4: What is the average total by equipment type in full competitions?

SELECT 
    equipment,
    ROUND(AVG(total), 0) AS avg_total
FROM powerlifting_facts
WHERE total IS NOT NULL
  AND squat IS NOT NULL
  AND bench IS NOT NULL
  AND deadlift IS NOT NULL
  AND equipment <> 'Straps'
GROUP BY equipment
ORDER BY avg_total DESC;

-- Includes only valid full meet entries (squat + bench + deadlift + total ≠ NULL).
-- Helps quantify overall performance level in each equipment category.

-- Q5: What is the average lift result (per type) by equipment?

SELECT 
    equipment,
    ROUND(AVG(bench), 1) AS avg_bench,
    ROUND(AVG(deadlift), 1) AS avg_deadlift,
    ROUND(AVG(squat), 1) AS avg_squat
FROM powerlifting_facts
WHERE total IS NOT NULL
  AND equipment <> 'Straps'
GROUP BY equipment
ORDER BY equipment;

-- Compares average squat, bench, and deadlift for each equipment type.
-- Includes only entries with valid total (to exclude disqualifications).