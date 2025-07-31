# 🏋️🏋️‍♀️ Men vs Women

## Q1: How many total meet entries and unique lifters are recorded?

```
Total Meet Entry Summary - Label = 
VAR _count = COUNTROWS('01_Powerlifting_facts')
VAR _lifters = DISTINCTCOUNT('01_Powerlifting_facts'[lifter_id])

VAR _formatted_count = FORMAT(_count / 1000000, "0.00") & "M"
VAR _formatted_lifters = FORMAT(_lifters / 1000, "0") & "K"

RETURN 
"Total Meet Entries: " & _formatted_count & UNICHAR(10) &
"Unique Lifters: " & _formatted_lifters
```
*💬 Dynamically returns a multiline label showing the total number of entries and distinct lifters.*

## Q5: What is the breakdown of lift combinations by sex?

```
Total Meet Entry % (Valid Only) = 
DIVIDE(
    COUNTROWS('01_Powerlifting_facts'),
    CALCULATE(
        COUNTROWS('01_Powerlifting_facts'),
        NOT ISBLANK('01_Powerlifting_facts'[lift_combination])
    )
)
```
*💬 Calculates the percentage of each lift combination type (Full, Two-lift, Single-lift) among entries that have a valid classification.*

## Q6: Among single-lift entries, which event is most popular by sex?

```
% of Specialised Lift = 
VAR TotalSingleLiftForSex =
    CALCULATE(
        COUNTROWS('01_Powerlifting_facts'),
        FILTER(
            ALL('01_Powerlifting_facts'),
            NOT ISBLANK('01_Powerlifting_facts'[single_lift_type]) &&
            RELATED('02_Dim_lifter'[sex]) = SELECTEDVALUE('02_Dim_lifter'[sex])
        )
    )
RETURN
DIVIDE(
    COUNTROWS('01_Powerlifting_facts'),
    TotalSingleLiftForSex
)
```
*💬 Computes the share of entries (within a given sex) that participated in a specific single-lift event (e.g., Bench-only).*

## Q7: How much does each lift contribute to the total (by sex)?

```
Total Avg Lift Sum (Valid Only) = 
VAR _valid_entries = 
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[total])
    )
RETURN
    AVERAGEX(_valid_entries, '01_Powerlifting_facts'[squat]) +
    AVERAGEX(_valid_entries, '01_Powerlifting_facts'[bench]) +
    AVERAGEX(_valid_entries, '01_Powerlifting_facts'[deadlift])
```
*💬 Helper measure used in all 3 lift contribution metrics. Calculates the combined average of squat, bench, and deadlift from valid entries.*

```
Bench % of Total (Valid Only) = 
VAR _valid_entries = 
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[total])
    )
VAR _avg_bench = AVERAGEX(_valid_entries, '01_Powerlifting_facts'[bench])
VAR _avg_total = [Total Avg Lift Sum (Valid Only)]
RETURN 
IF(_avg_total > 0, _avg_bench / _avg_total)
```

```
Deadlift % of Total (Valid Only) = 
VAR _valid_entries = 
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[total])
    )
VAR _avg_deadlift = AVERAGEX(_valid_entries, '01_Powerlifting_facts'[deadlift])
VAR _avg_total = [Total Avg Lift Sum (Valid Only)]
RETURN 
IF(_avg_total > 0, _avg_deadlift / _avg_total)
```

```
Squat % of Total (Valid Only) = 
VAR _valid_entries = 
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[total])
    )
VAR _avg_squat = AVERAGEX(_valid_entries, '01_Powerlifting_facts'[squat])
VAR _avg_total = [Total Avg Lift Sum (Valid Only)]
RETURN 
IF(_avg_total > 0, _avg_squat / _avg_total)
```
*💬 These three measures calculate the relative contribution of each lift to the total performance, based on valid entries with non-null totals. They help visualize which lift contributes most to an athlete’s overall result, enabling comparison across sexes and groups.*