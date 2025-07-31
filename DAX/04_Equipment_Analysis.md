# 🧤 Equipment Analysis 

## Q1: What is the distribution of equipment types among meet entries?

```
% of Entries by Equipment = 
DIVIDE(
    COUNTROWS('01_Powerlifting_facts'),
    CALCULATE(
        COUNTROWS('01_Powerlifting_facts'),
        REMOVEFILTERS('01_Powerlifting_facts'[equipment])
    )
)
```
*💬 Calculates the distribution of entries across different equipment types (e.g., Raw, Single-ply, Multi-ply).*

## Q2: By how much does each equipment type improve performance compared to Raw?

```
06_Lift Selector = DATATABLE(
    "Lift", STRING,
    {
        {"Squat"},
        {"Bench"},
        {"Deadlift"}
    }
)
```
*💬 Helper table used to let users select lift type (Squat, Bench, Deadlift) in slicers or visuals.*

```
Gain vs Raw % = 
VAR lift = SELECTEDVALUE('06_Lift Selector'[Lift])

-- Raw benchmark (stała)
VAR raw_bench = 
    CALCULATE(
        AVERAGE('01_Powerlifting_facts'[bench]),
        '01_Powerlifting_facts'[equipment] = "Raw",
        NOT ISBLANK('01_Powerlifting_facts'[total])
    )
VAR raw_squat = 
    CALCULATE(
        AVERAGE('01_Powerlifting_facts'[squat]),
        '01_Powerlifting_facts'[equipment] = "Raw",
        NOT ISBLANK('01_Powerlifting_facts'[total])
    )
VAR raw_deadlift = 
    CALCULATE(
        AVERAGE('01_Powerlifting_facts'[deadlift]),
        '01_Powerlifting_facts'[equipment] = "Raw",
        NOT ISBLANK('01_Powerlifting_facts'[total])
    )

-- Final return
RETURN
SWITCH(
    TRUE(),
    lift = "Bench" && NOT ISBLANK(raw_bench),
        DIVIDE(
            CALCULATE(AVERAGE('01_Powerlifting_facts'[bench]), NOT ISBLANK('01_Powerlifting_facts'[total])) - raw_bench,
            raw_bench
        ),
    lift = "Squat" && NOT ISBLANK(raw_squat),
        DIVIDE(
            CALCULATE(AVERAGE('01_Powerlifting_facts'[squat]), NOT ISBLANK('01_Powerlifting_facts'[total])) - raw_squat,
            raw_squat
        ),
    lift = "Deadlift" && NOT ISBLANK(raw_deadlift),
        DIVIDE(
            CALCULATE(AVERAGE('01_Powerlifting_facts'[deadlift]), NOT ISBLANK('01_Powerlifting_facts'[total])) - raw_deadlift,
            raw_deadlift
        ),
    BLANK()
)
```

*💬 Calculates the average performance improvement (in %) of each equipment type compared to Raw, based on selected lift type. Ignores disqualified entries.

## Q3: What is the disqualification rate across all entries?

```
Disqualification - % of Entries = 
VAR dq = CALCULATE(COUNTROWS('01_Powerlifting_facts'), ISBLANK('01_Powerlifting_facts'[total]))
VAR totalRows = COUNTROWS('01_Powerlifting_facts')
RETURN DIVIDE(dq, totalRows) * 100
```
*💬 Calculates the disqualification rate among all meet entries.*

```
Disqualification - Label = 
VAR _dqRate = [Disqualification - % of Entries]
RETURN 
"❌ Disqualification Rate: " & FORMAT(_dqRate, "0.0") & "%"
```
*💬 Dynamic label displaying the disqualification rate with context text (used in card or tooltip).*

## Q5: What is the average lift result (per type) by equipment?

```
Selected Lift Avg = 
VAR lift = SELECTEDVALUE('06_Lift Selector'[Lift])
RETURN
    SWITCH(
        lift,
        "Bench", CALCULATE(
            ROUND(AVERAGE('01_Powerlifting_facts'[bench]), 1),
            NOT ISBLANK('01_Powerlifting_facts'[bench]),
            NOT ISBLANK('01_Powerlifting_facts'[total]),
            KEEPFILTERS('01_Powerlifting_facts'[equipment] <> "Straps")
        ),
        "Squat", CALCULATE(
            ROUND(AVERAGE('01_Powerlifting_facts'[squat]), 1),
            NOT ISBLANK('01_Powerlifting_facts'[squat]),
            NOT ISBLANK('01_Powerlifting_facts'[total]),
            KEEPFILTERS('01_Powerlifting_facts'[equipment] <> "Straps")
        ),
        "Deadlift", CALCULATE(
            ROUND(AVERAGE('01_Powerlifting_facts'[deadlift]), 1),
            NOT ISBLANK('01_Powerlifting_facts'[deadlift]),
            NOT ISBLANK('01_Powerlifting_facts'[total]),
            KEEPFILTERS('01_Powerlifting_facts'[equipment] <> "Straps")
        )
    )
```
*💬 Calculates the user's average lift (if multiple values are selected or compared).*