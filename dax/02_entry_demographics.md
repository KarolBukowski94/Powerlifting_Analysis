# Entry Demographics

## Q2: Which age groups compete the most?

```
07_Age Group List = 
DATATABLE(
    "age_group", STRING,
    "age_sort", INTEGER,
    {
        {"Youth (8–13)", 1},
        {"Sub-Junior (14–18)", 2},
        {"Junior (19–23)", 3},
        {"Open (24–39)", 4},
        {"Masters I (40–49)", 5},
        {"Masters II (50–59)", 6},
        {"Masters III (60–69)", 7},
        {"Masters IV+ (70+)", 8}
    }
)
```
*Commentary: Lookup table used to define lifter age groups and enforce correct sorting in visualizations.*

```
% of Entries by Age Group = 
DIVIDE(
    CALCULATE(
        COUNTROWS('01_Powerlifting_facts'),
        NOT ISBLANK('01_Powerlifting_facts'[age_group])
    ),
    CALCULATE(
        COUNTROWS('01_Powerlifting_facts'),
        REMOVEFILTERS('07_Age Group List'),
        NOT ISBLANK('01_Powerlifting_facts'[age_group])
    )
)
```
*Commentary: Calculates the distribution of meet entries across age groups.*

## Q3: Which weight classes (kg) are most common by sex?

```
08_Weight Class List = 
DATATABLE(
    "sex", STRING,
    "weight_class", STRING,
    "weight_sort", INTEGER,
    {
        {"Male", "59", 1},
        {"Male", "66", 2},
        {"Male", "74", 3},
        {"Male", "83", 4},
        {"Male", "93", 5},
        {"Male", "105", 6},
        {"Male", "120", 7},
        {"Male", "120+", 8},
        {"Female", "43", 1},
        {"Female", "47", 2},
        {"Female", "52", 3},
        {"Female", "57", 4},
        {"Female", "63", 5},
        {"Female", "69", 6},
        {"Female", "76", 7},
        {"Female", "84", 8},
        {"Female", "84+", 9}
    }
)
```
*Commentary: Lookup table used to define weight classes by sex and apply consistent sorting in charts.*

```
% of Entries by Weight Class = 
DIVIDE(
    CALCULATE(
        COUNTROWS('01_Powerlifting_facts'),
        TREATAS(VALUES('08_Weight Class List'[weight_class]), '01_Powerlifting_facts'[weight_class]),
        TREATAS(VALUES('02_Dim_lifter'[sex]), '08_Weight Class List'[sex])
    ),
    CALCULATE(
        COUNTROWS('01_Powerlifting_facts'),
        TREATAS(VALUES('02_Dim_lifter'[sex]), '08_Weight Class List'[sex])
    )
)
```
*Commentary: Calculates the distribution of meet entries across weight classes.*
