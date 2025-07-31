-- # 🌍 Competition Landscape

-- Q1: How many lifters compete only once vs multiple times?

SELECT 
    CASE 
        WHEN meet_count = 1 THEN 'Single meet'
        ELSE 'Multiple meets'
    END AS competition_type,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percent_share
FROM (
    SELECT l.lifter_id, COUNT(DISTINCT f.meet_id) AS meet_count
    FROM powerlifting_facts f
    JOIN dim_lifter l ON f.lifter_id = l.lifter_id
    GROUP BY l.lifter_id
) sub
GROUP BY competition_type;

-- Categorizes lifters into two groups based on how often they appear across meets.
-- Result is presented as percent share of unique lifters by participation pattern.

-- Q2: What percentage of meet entries are tested for drugs?

SELECT 
    tested_status,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_lifters
FROM powerlifting_facts
GROUP BY tested_status
ORDER BY pct_lifters DESC;

-- Based on derived 'tested_status' column (Tested / Untested).
-- Shows overall drug-testing prevalence among all entries.

-- Q3: How has the number of meet entries changed over time?

SELECT 
    m.meet_year,
    COUNT(*) AS annual_lifter_count
FROM powerlifting_facts f
JOIN dim_meet m ON f.meet_id = m.meet_id
GROUP BY m.meet_year
ORDER BY m.meet_year;

-- Uses extracted meet_year from the meet dimension table.
-- Helps illustrate the global growth or decline in participation.

-- Q4: Where do meets take place most often?

SELECT 
    m.meet_country,
    COUNT(DISTINCT m.meet_id) AS total_meets
FROM powerlifting_facts f
JOIN dim_meet m ON f.meet_id = m.meet_id
WHERE m.meet_country <> 'Unknown'
GROUP BY m.meet_country
ORDER BY total_meets DESC
LIMIT 5;

-- Returns the top countries by number of distinct meet IDs held there.
-- 'Unknown' locations are excluded to ensure data quality.

-- Q5: How many countries have hosted powerlifting meets?

SELECT 
    COUNT(DISTINCT meet_country) AS number_of_countries
FROM dim_meet
WHERE meet_country IS NOT NULL AND meet_country <> 'Unknown';

-- Returns the number of distinct countries where at least one meet was recorded.
-- 'Unknown' entries are excluded to ensure only valid locations are counted.

-- Q6: What is the total number of meets held globally?

SELECT 
    COUNT(DISTINCT meet_id) AS total_meets
FROM dim_meet
WHERE meet_country IS NOT NULL AND meet_country <> 'Unknown';

-- Calculates the total number of distinct meet events in the dataset.
-- Aggregates across all countries and federations.
-- Only includes entries with valid meet_country.

-- Q7: How many federations are represented?

SELECT 
    COUNT(DISTINCT m.federation) AS federation_count
FROM dim_meet m
WHERE m.federation IS NOT NULL;

-- Counts the number of unique federations hosting meets in the dataset.

-- Q8: Which federations host the most meet entries?

SELECT 
    m.federation,
    COUNT(*) AS total_entries
FROM powerlifting_facts f
JOIN dim_meet m ON f.meet_id = m.meet_id
GROUP BY m.federation
ORDER BY total_entries DESC
LIMIT 5;

-- Aggregates all competition entries by hosting federation.
-- Returns the top 5 federations by volume.

-- Q9: Which competitions have the most entries?

SELECT 
    m.meet_name,
    COUNT(f.fact_id) AS total_entries
FROM powerlifting_facts f
JOIN dim_meet m ON f.meet_id = m.meet_id
GROUP BY m.meet_name
ORDER BY total_entries DESC
LIMIT 5;

-- Shows the most popular competitions based on number of entries.
-- Limited to top 5 by meet_name.