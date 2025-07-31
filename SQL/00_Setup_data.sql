-- STEP 0: Reset all tables if needed (safe re-run)

DROP TABLE IF EXISTS powerlifting_raw;
DROP TABLE IF EXISTS powerlifting_cleaned;
DROP TABLE IF EXISTS dim_lifter CASCADE;
DROP TABLE IF EXISTS dim_meet CASCADE;
DROP TABLE IF EXISTS powerlifting_facts CASCADE;

-- STEP 1: CREATE RAW STAGING TABLE

-- Create raw staging table to hold unprocessed data
CREATE TABLE powerlifting_raw (

    -- Lifter identity
    name               VARCHAR(100),   -- Full name of the lifter
    sex                VARCHAR(10),    -- Gender: M, F, or Mx

    -- Meet-level setup
    event              VARCHAR(10),    -- Event type (e.g. SBD, B, D)
    equipment          VARCHAR(30),    -- Equipment category (e.g. Raw, Wraps, Single-ply)

    -- Age-related info
    age                NUMERIC,        -- Age of the lifter at the time of the meet
    ageclass           VARCHAR(20),    -- Age class (e.g. '24-34')
    birthyearclass     VARCHAR(20),    -- Birth year grouping (e.g. '1980-1989')
    division           VARCHAR(50),    -- Competition division (e.g. Collegiate, Open)

    -- Weight-related info
    bodyweightkg       NUMERIC,        -- Bodyweight recorded at weigh-in (kg)
    weightclasskg      VARCHAR(10),    -- Assigned weight class by officials

    -- Squat attempts
    squat1kg           NUMERIC,
    squat2kg           NUMERIC,
    squat3kg           NUMERIC,
    squat4kg           NUMERIC,
    best3squatkg       NUMERIC,        -- Best of 3 (or 4) squat attempts

    -- Bench press attempts
    bench1kg           NUMERIC,
    bench2kg           NUMERIC,
    bench3kg           NUMERIC,
    bench4kg           NUMERIC,
    best3benchkg       NUMERIC,        -- Best of 3 (or 4) bench attempts

    -- Deadlift attempts
    deadlift1kg        NUMERIC,
    deadlift2kg        NUMERIC,
    deadlift3kg        NUMERIC,
    deadlift4kg        NUMERIC,
    best3deadliftkg    NUMERIC,        -- Best of 3 (or 4) deadlift attempts

    -- Totals and results
    totalkg            NUMERIC,        -- Total of best 3 lifts
    place              VARCHAR(10),    -- Final placement (e.g. 1, 2, DQ, G)

    -- Scoring formulas
    dots               NUMERIC,        -- DOTS score
    wilks              NUMERIC,        -- Wilks score (legacy)
    glossbrenner       NUMERIC,        -- Glossbrenner score
    goodlift           NUMERIC,        -- Goodlift score

    -- Drug testing
    tested             VARCHAR(10),    -- 'Yes' if tested category

    -- Lifter’s origin
    country            VARCHAR(50),    -- Lifter's home country
    state              VARCHAR(50),    -- Lifter's state/province

    -- Meet metadata
    federation         VARCHAR(50),    -- Hosting federation (e.g. USAPL)
    parentfederation   VARCHAR(50),    -- Parent federation group (e.g. IPF)
    date               DATE,           -- Start date of the meet

    -- Meet location
    meetcountry        VARCHAR(50),    -- Country where meet took place
    meetstate          VARCHAR(50),    -- State/province of the meet
    meettown           VARCHAR(100),   -- City or town of the meet
    meetname           VARCHAR(200)    -- Official name of the meet
);

-- STEP 2: LOAD DATA FROM CSV FILE

-- Adjust the path based on your PostgreSQL environment
COPY powerlifting_raw
FROM '/your_path/data.csv'
DELIMITER ',' CSV HEADER;

-- STEP 3: CREATE CLEANING COPY

CREATE TABLE powerlifting_cleaned AS
SELECT *
FROM powerlifting_raw;

-- STEP 4: DATA CLEANING

-- Standardize sex column: remove ambiguous 'Mx' entries and normalize to 'Male'/'Female'

SELECT sex, COUNT(*) AS lifter_count
FROM powerlifting_cleaned
GROUP BY sex;

DELETE FROM powerlifting_cleaned
WHERE sex = 'Mx';

UPDATE powerlifting_cleaned 
SET sex = CASE
    WHEN sex = 'M' THEN 'Male'
    ELSE 'Female'
END;

-- Remove entries with unrealistic age (<8) or bodyweight (<30 kg)

SELECT COUNT(*) AS missing_age
FROM powerlifting_cleaned
WHERE age < 8;

DELETE FROM powerlifting_cleaned
WHERE age < 8;

SELECT COUNT(*) AS missing_bodyweight
FROM powerlifting_cleaned
WHERE bodyweightkg < 30;

DELETE FROM powerlifting_cleaned
WHERE bodyweightkg < 30;

-- Standardize missing country values using COALESCE → replace NULLs with 'Unknown'

UPDATE powerlifting_cleaned
SET country_lifter = COALESCE(country_lifter, 'Unknown');

-- Rename key columns for schema consistency and easier downstream analysis

ALTER TABLE powerlifting_cleaned RENAME COLUMN bodyweightkg       TO bodyweight;
ALTER TABLE powerlifting_cleaned RENAME COLUMN best3squatkg       TO squat;
ALTER TABLE powerlifting_cleaned RENAME COLUMN best3benchkg       TO bench;
ALTER TABLE powerlifting_cleaned RENAME COLUMN best3deadliftkg    TO deadlift;
ALTER TABLE powerlifting_cleaned RENAME COLUMN totalkg            TO total;
ALTER TABLE powerlifting_cleaned RENAME COLUMN country            TO country_lifter;
ALTER TABLE powerlifting_cleaned RENAME COLUMN meetcountry        TO meet_country;
ALTER TABLE powerlifting_cleaned RENAME COLUMN meetname           TO meet_name;

-- Drop unused, redundant, or irrelevant columns to simplify data model

ALTER TABLE powerlifting_cleaned
    DROP COLUMN ageclass,
    DROP COLUMN birthyearclass,
    DROP COLUMN division,
    DROP COLUMN weightclasskg,
    DROP COLUMN squat1kg,
    DROP COLUMN squat2kg,
    DROP COLUMN squat3kg,
    DROP COLUMN squat4kg,
    DROP COLUMN bench1kg,
    DROP COLUMN bench2kg,
    DROP COLUMN bench3kg,
    DROP COLUMN bench4kg,
    DROP COLUMN deadlift1kg,
    DROP COLUMN deadlift2kg,
    DROP COLUMN deadlift3kg,
    DROP COLUMN deadlift4kg,
    DROP COLUMN parentfederation,
    DROP COLUMN wilks,
    DROP COLUMN glossbrenner,
    DROP COLUMN goodlift,
    DROP COLUMN state,
    DROP COLUMN meetstate,
    DROP COLUMN meettown,
    DROP COLUMN event;

-- STEP 5: Creating tables

-- Dim table: Lifter

CREATE TABLE dim_lifter (
    lifter_id       SERIAL PRIMARY KEY,
    name            VARCHAR(100),
    sex             VARCHAR(10),
    country_lifter  VARCHAR(50)
);

-- Dim table: Meet


CREATE TABLE dim_meet (
    meet_id         SERIAL PRIMARY KEY,
    meet_name       VARCHAR(200),
    federation      VARCHAR(50),
    meet_date       DATE,     
    meet_year       INT,
    meet_country    VARCHAR(50)
);

-- Fact table: Powerlifting Results

CREATE TABLE powerlifting_facts (
    fact_id           SERIAL PRIMARY KEY,
    lifter_id         INT REFERENCES dim_lifter(lifter_id),
    meet_id           INT REFERENCES dim_meet(meet_id),

    -- Lift results
    squat             NUMERIC,
    bench             NUMERIC,
    deadlift          NUMERIC,
    total             NUMERIC,

    -- Equipment
    equipment         VARCHAR(30),

    -- Lifter info
    age               NUMERIC,
    age_group         VARCHAR(40),
    bodyweight        NUMERIC,
    weight_class      VARCHAR(10),
    tested_status     VARCHAR(10),

    -- Scoring
    dots              NUMERIC,

    -- Result classification
    first_place       BOOLEAN,

    -- Derived fields
    age_binned        INT,
    bodyweight_binned INT,
    lift_combination  VARCHAR(20),
    single_lift_type  VARCHAR(20)

);

-- STEP 6: Populate tables

--  Populate dim_lifter

INSERT INTO dim_lifter (name, sex, country_lifter)
SELECT DISTINCT ON (name, sex)
    name,
    sex,
    country_lifter
FROM powerlifting_cleaned
WHERE name IS NOT NULL;

-- Lifters identified by name + sex (avoids ambiguity caused by inconsistent or missing country values)

-- Populate dim_meet

INSERT INTO dim_meet (meet_name, federation, meet_date, meet_year, meet_country)
SELECT DISTINCT
    meet_name,
    federation,
    date AS meet_date,
    EXTRACT(YEAR FROM date) AS meet_year,
    meet_country
FROM powerlifting_cleaned
WHERE meet_name IS NOT NULL;

-- Populate powerlifting_facts

INSERT INTO powerlifting_facts (
    lifter_id,
    meet_id,
    squat,
    bench,
    deadlift,
    total,
    equipment,
    age,
    age_group,
    bodyweight,
    weight_class,
    tested_status,
    dots,
    first_place,
    age_binned,
    bodyweight_binned,
    lift_combination,
    single_lift_type
)
SELECT
    dl.lifter_id,
    dm.meet_id,
    pr.squat,
    pr.bench,
    pr.deadlift,
    pr.total,
    pr.equipment,
    pr.age,

    -- Derived age group
    CASE 
        WHEN pr.age BETWEEN 8 AND 13 THEN 'Youth (8–13)'
        WHEN pr.age BETWEEN 14 AND 18 THEN 'Sub-Junior (14–18)'
        WHEN pr.age BETWEEN 19 AND 23 THEN 'Junior (19–23)'
        WHEN pr.age BETWEEN 24 AND 39 THEN 'Open (24–39)'
        WHEN pr.age BETWEEN 40 AND 49 THEN 'Masters I (40–49)'
        WHEN pr.age BETWEEN 50 AND 59 THEN 'Masters II (50–59)'
        WHEN pr.age BETWEEN 60 AND 69 THEN 'Masters III (60–69)'
        WHEN pr.age >= 70 THEN 'Masters IV+ (70+)'
        ELSE NULL
    END,

-- Age groups follow international powerlifting standards (e.g., IPF), including:
--   - Youth (8–13) — used in some youth/junior competitions
--   - Sub-Junior (14–18), Junior (19–23), Open (24–39), Masters I–IV (40+)

    pr.bodyweight,

    -- Derived weight class
    CASE
        WHEN pr.sex = 'Male' AND pr.bodyweight <= 59 THEN '59'
        WHEN pr.sex = 'Male' AND pr.bodyweight <= 66 THEN '66'
        WHEN pr.sex = 'Male' AND pr.bodyweight <= 74 THEN '74'
        WHEN pr.sex = 'Male' AND pr.bodyweight <= 83 THEN '83'
        WHEN pr.sex = 'Male' AND pr.bodyweight <= 93 THEN '93'
        WHEN pr.sex = 'Male' AND pr.bodyweight <= 105 THEN '105'
        WHEN pr.sex = 'Male' AND pr.bodyweight <= 120 THEN '120'
        WHEN pr.sex = 'Male' AND pr.bodyweight > 120 THEN '120+'

        WHEN pr.sex = 'Female' AND pr.bodyweight <= 43 THEN '43'
        WHEN pr.sex = 'Female' AND pr.bodyweight <= 47 THEN '47'
        WHEN pr.sex = 'Female' AND pr.bodyweight <= 52 THEN '52'
        WHEN pr.sex = 'Female' AND pr.bodyweight <= 57 THEN '57'
        WHEN pr.sex = 'Female' AND pr.bodyweight <= 63 THEN '63'
        WHEN pr.sex = 'Female' AND pr.bodyweight <= 69 THEN '69'
        WHEN pr.sex = 'Female' AND pr.bodyweight <= 76 THEN '76'
        WHEN pr.sex = 'Female' AND pr.bodyweight <= 84 THEN '84'
        WHEN pr.sex = 'Female' AND pr.bodyweight > 84 THEN '84+'
        ELSE NULL
    END,

-- Weight classes are based on official IPF divisions for men and women:
--   - Men: 59, 66, 74, 83, 93, 105, 120, 120+
--   - Women: 43, 47, 52, 57, 63, 69, 76, 84, 84+

    -- Derived tested status
    CASE 
        WHEN pr.tested = 'Yes' THEN 'Tested'
        ELSE 'Untested'
    END,

    pr.dots,

    -- Derived first place
    CASE 
        WHEN pr.place = '1' THEN TRUE
        ELSE FALSE
    END,

    FLOOR(pr.age),
    FLOOR(pr.bodyweight),

    -- Derived lift combination (excluding disqualified/incomplete entries)
    CASE 
        WHEN pr.total IS NOT NULL AND pr.squat IS NOT NULL AND pr.bench IS NOT NULL AND pr.deadlift IS NOT NULL THEN 'All lifts'
        WHEN pr.total IS NOT NULL AND (
            (pr.squat IS NOT NULL AND pr.bench IS NOT NULL AND pr.deadlift IS NULL) OR 
            (pr.squat IS NOT NULL AND pr.deadlift IS NOT NULL AND pr.bench IS NULL) OR 
            (pr.bench IS NOT NULL AND pr.deadlift IS NOT NULL AND pr.squat IS NULL)
        ) THEN 'Two lifts'
        WHEN pr.total IS NOT NULL AND (
            (pr.squat IS NOT NULL AND pr.bench IS NULL AND pr.deadlift IS NULL) OR
            (pr.squat IS NULL AND pr.bench IS NOT NULL AND pr.deadlift IS NULL) OR
            (pr.squat IS NULL AND pr.bench IS NULL AND pr.deadlift IS NOT NULL)
        ) THEN 'Single lift'
        ELSE NULL
    END,

    -- Derived single-lift type (excluding disqualified/no-total entries)
    CASE 
        WHEN pr.total IS NOT NULL AND pr.bench IS NOT NULL AND pr.squat IS NULL AND pr.deadlift IS NULL THEN 'Bench'
        WHEN pr.total IS NOT NULL AND pr.squat IS NOT NULL AND pr.bench IS NULL AND pr.deadlift IS NULL THEN 'Squat'
        WHEN pr.total IS NOT NULL AND pr.deadlift IS NOT NULL AND pr.squat IS NULL AND pr.bench IS NULL THEN 'Deadlift'
        ELSE NULL
    END

FROM powerlifting_cleaned pr
JOIN dim_lifter dl
  ON pr.name = dl.name
     AND pr.sex = dl.sex
JOIN dim_meet dm
  ON pr.meet_name = dm.meet_name 
     AND pr.federation = dm.federation 
     AND dm.meet_date = pr.date
     AND pr.meet_country = dm.meet_country;

-- STEP 7: Create indexes for performance optimization

CREATE INDEX idx_lifter_lookup ON dim_lifter (name, sex);
CREATE INDEX idx_meet_lookup   ON dim_meet (meet_name, federation, meet_date);

CREATE INDEX idx_facts_lifter       ON powerlifting_facts(lifter_id);
CREATE INDEX idx_facts_meet         ON powerlifting_facts(meet_id);
CREATE INDEX idx_facts_equipment    ON powerlifting_facts(equipment);