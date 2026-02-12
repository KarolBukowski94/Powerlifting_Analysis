# Personal Lift Calculator

## Age Group Slicer

*Commentary: Age Group List defined in helper table on [page 2](DAX/02_Entry_Demographics.md).*

## Weight Class Slicer

*Commentary: Weight Class List defined in helper table on [page 2](DAX/02_Entry_Demographics.md).*

```
Selected Sex = SELECTEDVALUE('02_Dim_lifter'[sex])
```
*Commentary: Returns the selected sex (Male/Female) from slicer.*

```
Show Valid Class = 
IF (
    SELECTEDVALUE('08_Weight Class List'[sex]) = [Selected Sex],
    1,
    0
)
```
*Commentary: Returns 1 if the selected weight class matches the selected sex, 0 otherwise (used to filter invalid slicer combinations).*

## Bench Card

```
Bench Input = GENERATESERIES(0, 650, 1)
```
*Commentary: Creates a numeric input range (kg) for user-entered lift values.*

```
Bench User Value = SELECTEDVALUE('09. Lift Comparison - Bench'[Bench Input])
```
*Commentary: Returns the user's selected bench press value from the input slicer.*

```
Bench Group Avg = 
VAR _group =
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[bench]) &&
        RELATED('02_Dim_lifter'[sex]) = SELECTEDVALUE('02_Dim_lifter'[sex]) &&
        '01_Powerlifting_facts'[age_group] = SELECTEDVALUE('01_Powerlifting_facts'[age_group]) &&
        '01_Powerlifting_facts'[weight_class] = SELECTEDVALUE('08_Weight Class List'[weight_class]) &&
        (
            ISBLANK(SELECTEDVALUE('02_Dim_lifter'[country_lifter])) ||
            RELATED('02_Dim_lifter'[country_lifter]) = SELECTEDVALUE('02_Dim_lifter'[country_lifter])
        )
    )

RETURN AVERAGEX(_group, '01_Powerlifting_facts'[bench])
```
*Commentary: Computes the average bench press within the filtered comparison group.*

```
Bench Group Size = 
VAR _group =
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[bench]) &&
        RELATED('02_Dim_lifter'[sex]) = SELECTEDVALUE('02_Dim_lifter'[sex]) &&
        '01_Powerlifting_facts'[age_group] = SELECTEDVALUE('01_Powerlifting_facts'[age_group]) &&
        '01_Powerlifting_facts'[weight_class] = SELECTEDVALUE('08_Weight Class List'[weight_class]) &&
        (
            ISBLANK(SELECTEDVALUE('02_Dim_lifter'[country_lifter])) ||
            RELATED('02_Dim_lifter'[country_lifter]) = SELECTEDVALUE('02_Dim_lifter'[country_lifter])
        )
    )

RETURN COUNTROWS(_group)
```
*Commentary: Returns the number of valid entries in the comparison group (sample size).*

```
Bench Percentile in Group = 
VAR _user_bench = [Bench User Value]

VAR _group =
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[bench]) &&
        RELATED('02_Dim_lifter'[sex]) = SELECTEDVALUE('02_Dim_lifter'[sex]) &&
        '01_Powerlifting_facts'[age_group] = SELECTEDVALUE('01_Powerlifting_facts'[age_group]) &&
        '01_Powerlifting_facts'[weight_class] = SELECTEDVALUE('08_Weight Class List'[weight_class]) &&
        (
            ISBLANK(SELECTEDVALUE('02_Dim_lifter'[country_lifter])) ||
            RELATED('02_Dim_lifter'[country_lifter]) = SELECTEDVALUE('02_Dim_lifter'[country_lifter])
        )
    )

VAR _lower_or_equal = COUNTROWS(FILTER(_group, '01_Powerlifting_facts'[bench] <= _user_bench))
VAR _total = COUNTROWS(_group)

RETURN DIVIDE(_lower_or_equal, _total)
```
*Commentary: Calculates user's percentile based on bench press relative to filtered group (same sex, age, weight class, and optionally country).*

```
Bench Summary Text = 
VAR _count = [Bench Group Size]
VAR _pct = [Bench Percentile in Group]
VAR _top_pct = MAX(0, MIN(_pct, 1))

VAR _rank_msg = 
    "your bench is stronger than " & FORMAT(_top_pct * 100, "0.0") & "% of recorded meet results."

VAR _feedback =
    SWITCH(
        TRUE(),
        _pct >= 0.90, "Elite Lifter 🏆",
        _pct >= 0.70, "Advanced Lifter 🟥",
        _pct >= 0.40, "Skilled Lifter 🟦",
        _pct >= 0.10, "Intermediate Lifter 🟩",
        _pct >= 0,    "Beginner Lifter 🟨",
        "Not calculated"
    )

RETURN
IF(
    ISBLANK(_count),
    "Not enough data for this group",
    "Compared to " & FORMAT(_count, "#,0") & " meet entries" & UNICHAR(10) &
    _rank_msg & UNICHAR(10) &
    _feedback
)
```
*Commentary: Generates a summary message with percentile rank and lifter level classification.*

## Squat Card

```
Squat Input = GENERATESERIES(0, 600, 1)
```
*Commentary: Creates a numeric input range (kg) for user-entered lift values.*

```
Squat User Value = SELECTEDVALUE('10. Lift Comparison - Squat'[Squat Input])
```
*Commentary: Returns the user's selected squat value from the input slicer.*

```
Squat Group Avg = 
VAR _group =
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[squat]) &&
        RELATED('02_Dim_lifter'[sex]) = SELECTEDVALUE('02_Dim_lifter'[sex]) &&
        '01_Powerlifting_facts'[age_group] = SELECTEDVALUE('01_Powerlifting_facts'[age_group]) &&
        '01_Powerlifting_facts'[weight_class] = SELECTEDVALUE('08_Weight Class List'[weight_class]) &&
        (
            ISBLANK(SELECTEDVALUE('02_Dim_lifter'[country_lifter])) ||
            RELATED('02_Dim_lifter'[country_lifter]) = SELECTEDVALUE('02_Dim_lifter'[country_lifter])
        )
    )

RETURN AVERAGEX(_group, '01_Powerlifting_facts'[squat])
```
*Commentary: Computes the average squat value within the filtered comparison group.*

```
Squat Group Size = 
VAR _group =
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[squat]) &&
        RELATED('02_Dim_lifter'[sex]) = SELECTEDVALUE('02_Dim_lifter'[sex]) &&
        '01_Powerlifting_facts'[age_group] = SELECTEDVALUE('01_Powerlifting_facts'[age_group]) &&
        '01_Powerlifting_facts'[weight_class] = SELECTEDVALUE('08_Weight Class List'[weight_class]) &&
        (
            ISBLANK(SELECTEDVALUE('02_Dim_lifter'[country_lifter])) ||
            RELATED('02_Dim_lifter'[country_lifter]) = SELECTEDVALUE('02_Dim_lifter'[country_lifter])
        )
    )

RETURN COUNTROWS(_group)
```
*Commentary: Returns the number of valid entries in the comparison group (sample size).*

```
Squat Percentile in Group = 
VAR _user_squat = [Squat User Value]

VAR _group =
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[squat]) &&
        RELATED('02_Dim_lifter'[sex]) = SELECTEDVALUE('02_Dim_lifter'[sex]) &&
        '01_Powerlifting_facts'[age_group] = SELECTEDVALUE('01_Powerlifting_facts'[age_group]) &&
        '01_Powerlifting_facts'[weight_class] = SELECTEDVALUE('08_Weight Class List'[weight_class]) &&
        (
            ISBLANK(SELECTEDVALUE('02_Dim_lifter'[country_lifter])) ||
            RELATED('02_Dim_lifter'[country_lifter]) = SELECTEDVALUE('02_Dim_lifter'[country_lifter])
        )
    )

VAR _lower_or_equal = COUNTROWS(FILTER(_group, '01_Powerlifting_facts'[squat] <= _user_squat))
VAR _total = COUNTROWS(_group)

RETURN DIVIDE(_lower_or_equal, _total)
```
*Commentary: Calculates user's percentile based on squat value relative to filtered group (same sex, age, weight class, and optionally country).*

```
Squat Summary Text = 
VAR _count = [Squat Group Size]
VAR _pct = [Squat Percentile in Group]
VAR _top_pct = MAX(0, MIN(_pct, 1))

VAR _rank_msg = 
    "your squat is stronger than " & FORMAT(_top_pct * 100, "0.0") & "% of recorded meet results."

VAR _feedback =
    SWITCH(
        TRUE(),
        _pct >= 0.90, "Elite Lifter 🏆",
        _pct >= 0.70, "Advanced Lifter 🟥",
        _pct >= 0.40, "Skilled Lifter 🟦",
        _pct >= 0.10, "Intermediate Lifter 🟩",
        _pct >= 0,    "Beginner Lifter 🟨",
        "Not calculated"
    )

RETURN
IF(
    ISBLANK(_count),
    "Not enough data for this group",
    "Compared to " & FORMAT(_count, "#,0") & " meet entries" & UNICHAR(10) &
    _rank_msg & UNICHAR(10) &
    _feedback
)
```
*Commentary: Generates a summary message with percentile rank and lifter level classification for squat.*

## Deadlift Card

```
Deadlift Input = GENERATESERIES(0, 500, 1)
```
*Commentary: Creates a numeric input range (kg) for user-entered lift values.*

```
Deadlift User Value = SELECTEDVALUE('11. Lift Comparison - Deadlift'[Deadlift Input])
```
*Commentary: Returns the user's selected deadlift value from the input slicer.*

```
Deadlift Group Avg = 
VAR _group =
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[deadlift]) &&
        RELATED('02_Dim_lifter'[sex]) = SELECTEDVALUE('02_Dim_lifter'[sex]) &&
        '01_Powerlifting_facts'[age_group] = SELECTEDVALUE('01_Powerlifting_facts'[age_group]) &&
        '01_Powerlifting_facts'[weight_class] = SELECTEDVALUE('08_Weight Class List'[weight_class]) &&
        (
            ISBLANK(SELECTEDVALUE('02_Dim_lifter'[country_lifter])) ||
            RELATED('02_Dim_lifter'[country_lifter]) = SELECTEDVALUE('02_Dim_lifter'[country_lifter])
        )
    )

RETURN AVERAGEX(_group, '01_Powerlifting_facts'[deadlift])
```
*Commentary: Computes the average deadlift value within the filtered comparison group.*

```
Deadlift Group Size = 
VAR _group =
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[deadlift]) &&
        RELATED('02_Dim_lifter'[sex]) = SELECTEDVALUE('02_Dim_lifter'[sex]) &&
        '01_Powerlifting_facts'[age_group] = SELECTEDVALUE('01_Powerlifting_facts'[age_group]) &&
        '01_Powerlifting_facts'[weight_class] = SELECTEDVALUE('08_Weight Class List'[weight_class]) &&
        (
            ISBLANK(SELECTEDVALUE('02_Dim_lifter'[country_lifter])) ||
            RELATED('02_Dim_lifter'[country_lifter]) = SELECTEDVALUE('02_Dim_lifter'[country_lifter])
        )
    )

RETURN COUNTROWS(_group)
```
*Commentary: Returns the number of valid entries in the comparison group (sample size).*

```
Deadlift Percentile in Group = 
VAR _user_deadlift = [Deadlift User Value]

VAR _group =
    FILTER(
        '01_Powerlifting_facts',
        NOT ISBLANK('01_Powerlifting_facts'[deadlift]) &&
        RELATED('02_Dim_lifter'[sex]) = SELECTEDVALUE('02_Dim_lifter'[sex]) &&
        '01_Powerlifting_facts'[age_group] = SELECTEDVALUE('01_Powerlifting_facts'[age_group]) &&
        '01_Powerlifting_facts'[weight_class] = SELECTEDVALUE('08_Weight Class List'[weight_class]) &&
        (
            ISBLANK(SELECTEDVALUE('02_Dim_lifter'[country_lifter])) ||
            RELATED('02_Dim_lifter'[country_lifter]) = SELECTEDVALUE('02_Dim_lifter'[country_lifter])
        )
    )

VAR _lower_or_equal = COUNTROWS(FILTER(_group, '01_Powerlifting_facts'[deadlift] <= _user_deadlift))
VAR _total = COUNTROWS(_group)

RETURN DIVIDE(_lower_or_equal, _total)
```
*Commentary: Calculates user's percentile based on deadlift value relative to filtered group (same sex, age, weight class, and optionally country).*

```
Deadlift Summary Text = 
VAR _count = [Deadlift Group Size]
VAR _pct = [Deadlift Percentile in Group]
VAR _top_pct = MAX(0, MIN(_pct, 1))

VAR _rank_msg = 
    "your deadlift is stronger than " & FORMAT(_top_pct * 100, "0.0") & "% of recorded meet results."

VAR _feedback =
    SWITCH(
        TRUE(),
        _pct >= 0.90, "Elite Lifter 🏆",
        _pct >= 0.70, "Advanced Lifter 🟥",
        _pct >= 0.40, "Skilled Lifter 🟦",
        _pct >= 0.10, "Intermediate Lifter 🟩",
        _pct >= 0,    "Beginner Lifter 🟨",
        "Not calculated"
    )

RETURN
IF(
    ISBLANK(_count),
    "Not enough data for this group",
    "Compared to " & FORMAT(_count, "#,0") & " meet entries" & UNICHAR(10) &
    _rank_msg & UNICHAR(10) &
    _feedback
)
```
*Commentary: Generates a summary message with percentile rank and lifter level classification for deadlift.*

## Your Best Lifts vs Group Average

*Commentary: Uses the Lift Selector table (defined on page 4) to dynamically control SWITCH-based logic — assigning measures based on selected lift (Squat, Bench, Deadlift).*

```
Lift User Value = 
SWITCH(
    SELECTEDVALUE('06_Lift Selector'[Lift]),
    "Bench", [Bench User Value],
    "Squat", [Squat User Value],
    "Deadlift", [Deadlift User Value]
)
```
*Commentary: Returns the lift value entered by the user for the currently selected lift.*

```
Lift Group Avg = 
SWITCH(
    SELECTEDVALUE('06_Lift Selector'[Lift]),
    "Bench", [Bench Group Avg],
    "Squat", [Squat Group Avg],
    "Deadlift", [Deadlift Group Avg]
)
```
*Commentary: Calculates the average lift value in the selected group for the currently selected lift (Bench, Squat, or Deadlift).*