# Competition Landscape

## Q1: How many lifters compete only once vs multiple times?

```
05_Lifter Participation = 
DATATABLE(
    "Participation", STRING,
    {
        {"Single meet"},
        {"Multiple meets"}
    }
)
```
*Commentary: Helper table defining the two categories of participation (single vs multiple meets). Used to drive SWITCH logic in calculated measure.*

```
% of Lifters (Filtered) = 
VAR SingleMeet =
    CALCULATE(
        DISTINCTCOUNT('01_Powerlifting_facts'[lifter_id]),
        FILTER(
            VALUES('01_Powerlifting_facts'[lifter_id]),
            CALCULATE(DISTINCTCOUNT('01_Powerlifting_facts'[meet_id])) = 1
        )
    )

VAR MultiMeet =
    CALCULATE(
        DISTINCTCOUNT('01_Powerlifting_facts'[lifter_id]),
        FILTER(
            VALUES('01_Powerlifting_facts'[lifter_id]),
            CALCULATE(DISTINCTCOUNT('01_Powerlifting_facts'[meet_id])) > 1
        )
    )

VAR Total = SingleMeet + MultiMeet

RETURN
SWITCH(
    SELECTEDVALUE('05_Lifter Participation'[Participation]),
    "Single meet", DIVIDE(SingleMeet, Total),
    "Multiple meets", DIVIDE(MultiMeet, Total)
)
```
*Commentary: Calculates the share of lifters who competed once vs multiple times.*

## Q2: What percentage of meet entries are tested for drugs?

```
% of Entries by Tested Status = 
VAR TotalEntries =
    CALCULATE(
        COUNTROWS('01_Powerlifting_facts'),
        REMOVEFILTERS('01_Powerlifting_facts'[tested_status])
    )

VAR CurrentGroupEntries =
    COUNTROWS('01_Powerlifting_facts')

RETURN
DIVIDE(CurrentGroupEntries, TotalEntries)
```
*Commentary: Calculates the percentage of entries that are in tested federations. Percentage is computed over meet entries (rows), not distinct lifters.*

## Q5: How many countries have hosted powerlifting meets?

```
Country Count - Label = 
"Number of Countries: " & COUNTROWS(VALUES('03_Dim_meet'[meet_country]))
```
*Commentary: Dynamic label showing number of countries with powerlifting meets.*

## Q6: What is the total number of meets held globally?

```
Meet Count - Label = 
"Number of Meets: " & 
FORMAT(COUNTROWS(VALUES('03_Dim_meet'[meet_id])) / 1000, "0.0") & "K"
```
*Commentary: Dynamic label showing total number of meets globally.*

## Q7: How many federations are represented?

```
Federation Count - Label = 
"Number of Federations: " & COUNTROWS(VALUES('03_Dim_meet'[federation]))
```
*Commentary: Dynamic label showing number of federations.*