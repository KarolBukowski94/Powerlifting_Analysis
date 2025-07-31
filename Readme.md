# Powerlifting Analysis

## 📌 Project Summary

Dive into the world of strength sports with an interactive report that explores global trends in competitive powerlifting.

- ✅ **3M+ cleaned meet entries** and **798K+ unique athletes** from [OpenPowerlifting](https://www.openpowerlifting.org/) database.
- ✅ Modeled via **SQL star schema** (dim/fact logic).
- ✅ **Custom DAX** measures for advanced percentile logic and comparisons.
- ✅ **6-page interactive Power BI** dashboard with rich filtering.

🔗 [Interactive Power BI Dashboard](https://app.powerbi.com/view?r=eyJrIjoiOGM4Y2I5ZDUtY2RjYS00ODBjLThhYWQtZjI2YzllMzNmNmE5IiwidCI6ImRmODY3OWNkLWE4MGUtNDVkOC05OWFjLWM4M2VkN2ZmOTVhMCJ9&pageName=4e52e86104a6a09054c9) | [SQL Code](./SQL) | [DAX Measures](./DAX)

## 📂 Data Source

- 💾 Dataset: [Open Powerlifting (Kaggle)](https://www.kaggle.com/datasets/open-powerlifting/powerlifting-database)  
- 📖 Data dictionary: [CSV Field Descriptions](https://openpowerlifting.gitlab.io/opl-csv/bulk-csv-docs.html)

## 🔎 **Note on interactivity**:  

- The Power BI report, depending on the page, supports dynamic filtering by **sex**, **equipment type**, **lifter country**, **weight class**, and **age group**.   
- Many visuals are also **clickable and cross-filtered** — bars and charts can be explored interactively for deeper insights.   
- The insights below highlight selected patterns and comparisons, but they represent only a **subset of possible combinations**. Users are encouraged to explore the full report to uncover more detailed trends.

## 🧠 Logic Separation: SQL vs DAX

- To ensure performance and validation, this project separates logic across two layers:

    - **SQL (PostgreSQL)** – used for exploratory queries, aggregation checks, and validating logic used in Power BI.
    - **DAX Measures** – used for dynamic calculations, tooltips, slicers, and interactive logic inside Power BI.

- Most SQL files contain standalone `SELECT` queries that **replicate results shown in Power BI** — allowing for **double-checking** of measures, labels, and filtered visuals.
- Additionally, the **Hall of Fame** page uses a dedicated SQL view to **pre-aggregate lifter statistics**, reducing DAX complexity and improving report performance.

🔍 To clarify:

- Each `.md` file in the `/dax/` folder documents **only the DAX-based logic** used on that report page.
- All supporting **SQL queries** are available in the `/sql/` folder and match the chart logic 1:1 — whether the Power BI chart uses DAX, a field, or a SQL view.

This layered approach demonstrates how SQL and DAX can complement each other — offering both backend robustness and frontend flexibility.

## 🛠️ Data Preparation & Modeling

Before analysis, the raw OpenPowerlifting data.csv file was cleaned and modeled using SQL. Key steps included:

- Filtering out **invalid or unrealistic entries**, such as:
  - Lifters younger than 8 years
  - Bodyweight below 30 kg
  - Ambiguous sex entries (e.g., 'Mx')
- Standardizing key columns:
  - Converted 'M'/'F' → 'Male'/'Female'
  - Replaced missing country info with `'Unknown'`
- Deriving analytical fields:
  - **Age groups** and **weight classes** (based on IPF standards)
  - **First place**, **tested status**, **lift combinations**, and **single-lift types**
- Modeling the data using a **star schema**:
  - `dim_lifter` and `dim_meet` as dimension tables
  - `powerlifting_facts` as the central fact table
- Creating **indexes** for efficient querying
- Populating all tables using joins on multiple keys (e.g., name, sex, country for lifters)

> 🔗 [SQL](SQL/00_Setup_data.sql)

![Power BI Data Model](/images/00_Data_Modeling.PNG)

## 📌 Report Pages

| Page | Focus |
|------|-------|
| 🏋️🏋️‍♀️ Men vs Women | Sex Distribution, Average Total, Average Lifts, Lift Contribution, Lift Combination Events, Single-lift Event Popularity |
| 👥 Entry Demographics | Entries by Nationality, Age Group Breakdown, Age vs Performance, Weight Class Breakdown, Bodyweight vs Total |
| 🌍 Competition Landscape | Participation Rate, Drug Testing Share, Meet Entries Over Time, Top Locations Worldwide, Most Popular Federations, Most Popular Competitions |
| 🧤 Equipment Analysis | Popular Equipment Types, Strength Boost From Equipment vs Raw, Disqualification Rate, Average Total by Equipment Type in Full Competitions, Average Lift Result by Equipment Type |
| 🏆 Hall of Fame | Top 3 Lifters by Best Total, Top 3 Lifters by Best Bench, Deadlift, and Squat, Most Meets Entered, Most Meet Wins |
| 💪 Personal Lift Calculator | Compare your lifts to filtered global population |

## 🏋️🏋️‍♀️ Men vs Women

![01_Men_vs_Women](/images/01_Men_vs_Women.PNG)

*🎯 This page explores participation trends in global powerlifting based on meet entries — including sex distribution, average lift totals, and event formats. It highlights how men and women differ in performance patterns, specialization, and event type preferences.*

### Key insights

- **Sex Distribution**

    - Men dominate participation **(75.3%)**, but women now account for nearly 1 in 4 entries **(24.7%)** — reflecting growing inclusivity in a once male-dominated sport.

- **Average Total**

    - Men lift **540 kg** on average vs **305 kg** for women — a difference aligned with physiological factors, yet still showcasing impressive female performance.

- **Average Lifts**

    - The biggest gap is in **bench press** (women <50% of male avg), likely due to upper body strength. **Squat** and **deadlift** gaps are smaller but notable.

- **Lift Contribution**

    - **Bench press** contributes the least to total, while **deadlift** dominates. **Bench press** is slightly more important for men, **deadlift** for women — possibly reflecting biological differences.

- **Lift Combination Events**

    - About **75%** of entries are traditional **3-lift** meets. **Single-lift** events are common too — especially for men (**31.4%** vs **22.2%** in women). **Two-lift** formats are rare (**2.2%**).

- **Single-lift Event Popularity**

    - **Bench press** dominates single-lift meets (>70%), followed by **deadlift**. Men prefer bench-only, while women lean more toward deadlift — highlighting differing specialization trends.

> 🔗 [SQL](SQL/01_Men_vs_Women.sql) | [DAX](DAX/01_Men_vs_Women.md)

---

## 👥 Entry Demographics

![02_Entry_Demographics](/images/02_Entry_Demographics.PNG)

*🎯 This page explores the demographic patterns of competition entries — by age, weight class, and nationality. It also examines how performance varies with age (DOTS) and how strength scales with bodyweight.*

### Key insights

- **Entries by Nationality**

    - The **USA** dominates entry volume, far ahead of other nations — reflecting the maturity and infrastructure of American powerlifting federations.

- **Age Group Breakdown**

    - The **Open (24–39)** category is by far the most common. Youth and Masters groups are present but less represented, with participation tapering at both extremes.

- **Weight Class Breakdown**

    -  The most common class is **83 kg for men** and **63 kg for women**. Women’s entries are more evenly spread across weight classes compared to men.   

- **Age vs Performance**

    - Peak average DOTS scores — a normalized strength metric — occur between ages **20–26**, suggesting this is the **prime performance window** for most lifters.
    - However, many of the **world’s top competitors** remain highly competitive well into their **30s and 40s**, highlighting the impact of training experience and longevity in strength sports.

- **Bodyweight vs Total**

    - For both sexes, average total **rises steadily with bodyweight** up to **~140 kg (men)** and **~130 kg (women)**. 
    - Beyond that, the trend becomes **erratic**, with sharp ups and downs — likely due to smaller sample sizes and shifting strength-to-mass dynamics.
    - Interestingly, **some of the highest all-time totals** are achieved in these extreme bodyweight categories.

> 🔗 [SQL](SQL/02_Entry_Demographics.sql) | [DAX](DAX/02_Entry_Demographics.md)

---

## 🌍 Competition Landscape

![03_Competition_Landscape](/images/03_Competition_Landscape.PNG)

*🎯 This page analyzes structural patterns of the powerlifting ecosystem — including how often athletes return to compete, how prevalent drug-testing is, and which federations dominate the scene. It also tracks the global growth of the sport over time, highlights the most popular competitions by entry volume, and shows which countries host the largest number of meets.*

### Key insights

- **Participation Rate**  

    - Meet entries are nearly evenly split between lifters who competed only once (**47.9%**) and those who returned for multiple meets (**52.1%**) — indicating strong retention and long-term engagement within the sport.

- **Drug Testing Share**

    - About **73.6%** of entries come from **tested federations**, while **26.4%** are untested — showing that drug-tested competitions make up the majority of the global powerlifting scene.

- **Meet Entries Over Time**

    - Participation remained low through the 1980s, then spiked between **1979 and 1986** — likely due to the emergence of early international federations and better historical data capture during that period.  
    - After a decline, meet entries began to rise again, followed by a sharp surge after **2009**, reflecting the sport’s global expansion.
    - The pronounced drop in entries after **2019** aligns with widespread **COVID‑19 cancellations and restrictions** across sports.

- **Top Locations Worldwide**

  - Out of **47.4K recorded meets**, over **half** took place in the **USA (23.8K)** — followed by **Russia (3.9K)** and **Norway (2.9K)**.
  - While competitions have been held in **122 countries**, the vast majority are concentrated in just a few regions.  
  - This reflects both the sport’s **broad international reach** and its **heavy localization** in certain powerlifting hubs.

- **Most Popular Federations**  

    - The top federations by entry volume are **THSPA (378K)**, **USAPL (282K)**, and **USPA (190K)** — suggesting the strong influence of U.S.-based organizations.

- **Most Popular Competitions**  

    - **World Championships (76K entries)** top the list, followed by **European Championships (28K)** and **World Cup (19K)** — highlighting the global prestige of these events.

> 🔗 [SQL](SQL/03_Competition_Landscape.sql) | [DAX](DAX/03_Competition_Landscape.md)

---

## 🧤 Equipment Analysis 

![04_Equipment_Analysis](/images/04_Equipment_Analysis.PNG)

*🎯 This page compares lifting performance across different equipment categories — such as Raw, Wraps, and Multi-ply — while also examining disqualification rates and the popularity of each gear type. It highlights how equipment choices influence average results and overall competitiveness.*

### Key insights

- **Popular Equipment Types**  
  
    - **Raw (44.9%)** and **Single-ply (44.1%)** together account for nearly **90% of all entries**.  
    - More advanced equipment like **Wraps (6.7%)**, **Multi-ply (4.1%)**, and **Unlimited (0.3%)** is used far less frequently.

- **Strength Boost from Equipment vs Raw**  

    - **Bench press** sees the most dramatic impact: **Unlimited gear** offers a **+105.5% boost**, while **Multi-ply** adds **+54.5%**.  
    - In **deadlift**, gains are much smaller: **Unlimited +22.2%**, **Multi-ply +21.3%**.  
    - **Squat** falls in between: **Unlimited +74.6%**, **Multi-ply +57.4%**.  
    - Wraps and Single-ply offer only modest gains — and in some cases, almost none or even negative effect (e.g., **Single-ply deadlift: −4.6%**).

- **Average Lift Results by Equipment Type**  

    - Equipment consistently enhances average lift results, but the **effect size varies by lift** 
    - **Bench press** shows the largest differences between gear types.  
    - **Deadlift** is the least affected.  
    - **Squat** results reflect a middle ground — strongly boosted by higher-tier equipment.

- **Disqualification Rate by Equipment Type**  

  Disqualification rates vary by gear, possibly due to stricter judging or higher technical difficulty:  
    - **Raw: 3.9%**  
    - **Multi-ply: 4.1%**
    - **Wraps: 4.9%**  
    - **Unlimited: 8.5%**
    - **Single-ply: 9.4%**  

- **Average Total by Equipment Type in Full Competitions** 

    - Overall total performance increases with the level of equipment used.
    - **Unlimited and Multi-ply lifters** record the highest totals, followed by **Wraps**, **Single-ply**, and **Raw** — confirming the gear’s impact on output.

> 🔗 [SQL](SQL/04_Equipment_Analysis.sql) | [DAX](DAX/04_Equipment_Analysis.md)

---

## 🏆 Hall of Fame

![05_Hall_of_Fame](/images/05_Hall_of_Fame.PNG)

*🎯 This page celebrates the top performers in powerlifting history. It highlights athletes with the highest totals, best individual lifts, most wins, and most meet appearances — offering a leaderboard-style perspective on elite performance.*

### Key insights

- **Top Lifters by Total**

    - The heaviest totals exceed **1400 kg (men)** and **930 kg (women)** — led by legends like Dave Hoff and Leah Reichman.
    - In the Raw category, best totals are still staggering: Ray Williams tops men with **1113 kg**, while Tamara Walcott leads women with **721 kg**.

- **Best Individual Lifts**

    - Jimmy Kolb’s **636 kg bench press**, Danny Grigsby’s **488 kg deadlift**, and Nathan Baptist’s **595 kg squat** stand among the most jaw-dropping feats of strength ever recorded. On the women’s side, Leah Reichman’s **433 kg squat**, Becca Swanson’s **315 kg deadlift**, and Ashleigh Hoeta’s **318 kg bench press** push the boundaries of performance.
    - In the Raw divisions, Ray Williams leads the men’s **squat** with **490 kg**, while Danny Grigsby and Spencer Mather dominate **deadlift (488 kg)** and **bench press (455 kg)**, respectively. For the women, Brittany Schlater **squats 281 kg**, Tamara Walcott **deadlifts 285 kg**, and Maria Mersberg **bench press 220 kg** — showing that elite strength is equally present without supportive gear.

- **Most Wins**
    
    - Magomedamin Israpilov has a staggering **296 wins**, closely followed by Evgeniy Svoboda **(239)** and Gary Teeter **(228)**.
    - Among women, Bonnie Aerts leads with **226 wins**, ahead of Judy Gedney **(172)**, and Heena Patel **(163)**.

- **Most Competitions Entered**

    - Magomedamin Israpilov again tops with **411 entries** — reflecting extreme consistency and dedication.
    - On the women’s side, Bonnie Aerts leads with **277 competitions**.

> 🔗 [SQL](SQL/05_Hall_of_Fame.sql)

---

## 💪 Personal Lift Calculator

![06_Personal_Lift_Calculator](/images/06_Personal_Lift_Calculator.PNG)

*🎯 This page allows users to input their personal bests and compare them to the global powerlifting population — filtered by **sex**, **age group**, **weight class**, and optionally **country**. It offers percentile-based feedback and clear visual context for evaluating personal strength.*

### Key features

- **Lift Percentile Calculator**

    - Enter your **bench press**, **squat**, and **deadlift** to instantly see how your results compare to thousands of meet entries from lifters in the same demographic group.

    - Percentile feedback highlights where you stand — from beginner level up to elite — based on real-world distribution data.

- **Dynamic Visual Feedback**

    - Compare your lifts directly against group averages via clear bar charts.

    - The visuals update in real-time based on your selected filters and inputs, showing if you're outperforming, matching, or trailing the typical lifter in your group.

- **Progress Classification**

    - Each lift receives a badge — **Beginner**, **Intermediate**, **Skilled**, **Advanced**, or **Elite** — tied to your percentile bracket, offering an intuitive benchmark for goal setting and self-assessment.

> 🔗 [DAX](DAX/06_Personal_Lift_Calculator.md)

---

## 📄 Closing Thoughts

- This project sharpened my ability to **clean**, **model**, and **visualize** large-scale sports data using a full-stack data analytics workflow (raw CSV → SQL schema → Power BI insights)
- It combines **SQL-based logic** with **interactive Power BI storytelling** — delivering a cohesive, user-friendly, and insight-rich analytics experience.

Along the way, I gained hands-on experience with:

- Designing a **star schema model** (fact/dimension separation, foreign key logic).
- Performing **data cleaning and transformation** (e.g. filtering, standardization, derived columns) to prepare a high-quality schema-ready dataset.
- Writing advanced **SQL queries** (JOINs, CTEs, subqueries, aggregation, window functions).
- Creating custom **DAX measures** (percentiles, badges, label cards, dynamic slicer-driven logic).
- Applying **data joins, filters, and group-level calculations** across backend and frontend.
- Building an **interactive Power BI dashboard** with slicers (sex, country, equipment, age group, weight class), tooltips, and cross-filtered visuals.
- Applying **analytical problem-solving** to uncover insights (e.g. lift contribution, disqualification trends, equipment impact).
- Communicating **complex metrics** to both technical and non-technical audiences through visual storytelling.

**Tools used:** PostgreSQL, Power BI, DAX, Visual Studio Code, Git & GitHub.

**Supported by:** ChatGPT (Plus) – assisted in coding (SQL/DAX), validating logic, refining insights, and ensuring high-quality documentation in both technical and written form.

---