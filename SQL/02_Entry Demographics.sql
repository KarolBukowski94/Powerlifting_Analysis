-- # 👥 Entry Demographics

-- Q1: Where do most competing lifters come from?

SELECT 
    l.country_lifter,
    COUNT(*) AS entry_count
FROM powerlifting_facts f
JOIN dim_lifter l ON f.lifter_id = l.lifter_id
WHERE l.country_lifter <> 'Unknown'
GROUP BY l.country_lifter
ORDER BY entry_count DESC
LIMIT 5;

-- Returns top 5 countries by number of recorded entries.
-- Country field was standardized in cleaning step; 'Unknown' is excluded.

-- Q2: Which age groups compete the most?

SELECT 
    f.age_group,
    ROUND(100.0 * COUNT(*)::numeric / SUM(COUNT(*)) OVER (), 1) AS percent_share
FROM powerlifting_facts f
WHERE f.age_group IS NOT NULL
GROUP BY f.age_group
ORDER BY
    CASE f.age_group
        WHEN 'Youth (8–13)' THEN 1
        WHEN 'Sub-Junior (14–18)' THEN 2
        WHEN 'Junior (19–23)' THEN 3
        WHEN 'Open (24–39)' THEN 4
        WHEN 'Masters I (40–49)' THEN 5
        WHEN 'Masters II (50–59)' THEN 6
        WHEN 'Masters III (60–69)' THEN 7
        WHEN 'Masters IV+ (70+)' THEN 8
        ELSE 99
    END;

-- Uses derived 'age_group' column assigned in populating step.
-- Returns percentage share of each age group across all valid entries.
-- Age group boundaries match IPF-style classification, including 'Youth (8–13)'.

-- Q3: Which weight classes (kg) are most common by sex?

-- 🏋️‍♂️ Male lifters

WITH male_entries AS (
    SELECT 
        f.weight_class,
        COUNT(*) AS count_entries
    FROM powerlifting_facts f
    JOIN dim_lifter l ON f.lifter_id = l.lifter_id
    WHERE f.weight_class IS NOT NULL AND l.sex = 'Male'
    GROUP BY f.weight_class
),
male_total AS (
    SELECT SUM(count_entries) AS total_entries FROM male_entries
)
SELECT 
    e.weight_class,
    ROUND(100.0 * e.count_entries::numeric / t.total_entries, 1) AS percent_share
FROM male_entries e
CROSS JOIN male_total t
ORDER BY 
    CASE 
        WHEN e.weight_class = '59' THEN 1
        WHEN e.weight_class = '66' THEN 2
        WHEN e.weight_class = '74' THEN 3
        WHEN e.weight_class = '83' THEN 4
        WHEN e.weight_class = '93' THEN 5
        WHEN e.weight_class = '105' THEN 6
        WHEN e.weight_class = '120' THEN 7
        WHEN e.weight_class = '120+' THEN 8
    END;

-- 🏋️‍♀️ Female lifters

WITH female_entries AS (
    SELECT 
        f.weight_class,
        COUNT(*) AS count_entries
    FROM powerlifting_facts f
    JOIN dim_lifter l ON f.lifter_id = l.lifter_id
    WHERE f.weight_class IS NOT NULL AND l.sex = 'Female'
    GROUP BY f.weight_class
),
female_total AS (
    SELECT SUM(count_entries) AS total_entries FROM female_entries
)
SELECT 
    e.weight_class,
    ROUND(100.0 * e.count_entries::numeric / t.total_entries, 1) AS percent_share
FROM female_entries e
CROSS JOIN female_total t
ORDER BY 
    CASE 
        WHEN e.weight_class = '43' THEN 1
        WHEN e.weight_class = '47' THEN 2
        WHEN e.weight_class = '52' THEN 3
        WHEN e.weight_class = '57' THEN 4
        WHEN e.weight_class = '63' THEN 5
        WHEN e.weight_class = '69' THEN 6
        WHEN e.weight_class = '76' THEN 7
        WHEN e.weight_class = '84' THEN 8
        WHEN e.weight_class = '84+' THEN 9
    END;

-- Based on IPF official weight classes for men and women.
-- Percentages computed within each sex group to show distribution.

-- Q4: How does age affect lifting performance?

SELECT 
    FLOOR(age) AS age_year,
    ROUND(AVG(dots), 2) AS avg_dots
FROM powerlifting_facts
WHERE age IS NOT NULL AND dots IS NOT NULL
GROUP BY age_year
ORDER BY age_year;

-- Average DOTS score by age (rounded down to integer).
-- Only entries with known age and valid DOTS value are included.

-- Q5: How does bodyweight affect lifting performance?

-- 🏋️‍♂️ Male lifters

SELECT 
    FLOOR(bodyweight) AS bodyweight_bin,
    ROUND(AVG(total), 2) AS avg_total
FROM powerlifting_facts f
JOIN dim_lifter l ON f.lifter_id = l.lifter_id
WHERE 
    bodyweight IS NOT NULL
    AND total IS NOT NULL
    AND f.squat IS NOT NULL
    AND f.bench IS NOT NULL
    AND f.deadlift IS NOT NULL
    AND l.sex = 'Male'
GROUP BY bodyweight_bin
ORDER BY bodyweight_bin;

-- 🏋️‍♀️ Female lifters

SELECT 
    FLOOR(bodyweight) AS bodyweight_bin,
    ROUND(AVG(total), 2) AS avg_total
FROM powerlifting_facts f
JOIN dim_lifter l ON f.lifter_id = l.lifter_id
WHERE 
    bodyweight IS NOT NULL
    AND total IS NOT NULL
    AND f.squat IS NOT NULL
    AND f.bench IS NOT NULL
    AND f.deadlift IS NOT NULL
    AND l.sex = 'Female'
GROUP BY bodyweight_bin
ORDER BY bodyweight_bin;

-- Average total by rounded bodyweight bins.
-- Only valid full competitions are included (all 3 lifts + total present).
-- Split by sex.