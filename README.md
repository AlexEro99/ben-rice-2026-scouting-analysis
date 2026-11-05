# Ben Rice | 2026 Hitter Weakness & Matchup Analysis

## Project Overview

This project uses MLB Statcast pitch-level data to analyze Ben Rice's swing-and-miss tendencies, pitch-type matchups, strike-zone weaknesses, and contact quality during the 2026 regular season.

The objective is to translate baseball data into actionable insights that could support advance scouting and pitcher game planning.

## Scouting Visualization

![Ben Rice 2026 In-Zone Whiff Rate](outputs/ben_rice_whiff_heatmap.png)


## Tools & Technologies

- **Python:** pybaseball, pandas, NumPy, Matplotlib
- **SQL:** PostgreSQL
- **Database Management:** pgAdmin / VS Code
- **Data Source:** MLB Statcast via pybaseball

## Dataset

- 2,695 pitches analyzed
- 154 games
- 11 pitch types
- 1,157 swings
- 294 whiffs
- 25.41% overall whiff rate

## Key Findings

**1. Below-zone vulnerability**

Rice recorded a 54.50% whiff rate on 200 swings at pitches below the strike zone.

**2. Slider effectiveness**

Sliders generated a 35.96% overall whiff rate. Sliders finishing below the zone generated a 61.54% whiff rate against left-handed pitchers and 62.96% against right-handed pitchers.

**3. Right-handed curveballs**

Curveballs below the strike zone generated a 65.22% whiff rate on 23 swings against right-handed pitchers.

**4. Four-seam fastball contact**

Rice averaged 96.29 mph exit velocity and a .609 estimated contact value on 88 tracked balls put in play against four-seam fastballs.

**5. Strike-zone location**

The lower third of the strike zone generated a 24.62% whiff rate, compared with approximately 9.97% in the middle third.

## Scouting Implications

The analysis suggests that breaking balls finishing below the strike zone may be useful for generating swings and misses against Rice. Pitchers should also be cautious about leaving hittable offerings in the middle of the strike zone.

These findings are descriptive and should be interpreted alongside sample sizes, pitch sequencing, count, and pitcher-specific characteristics.

## Methodology

Pitch-level data was collected using pybaseball, imported into PostgreSQL, and analyzed using SQL queries.

Swing and whiff rates were calculated using Statcast pitch descriptions. Strike-zone locations were grouped into approximate zones using recorded pitch coordinates and batter-specific strike-zone heights.

Python and Matplotlib were used to create the visualizations.

## Project Deliverables

- [Advance Scouting Report (PDF)](reports/Ben_Rice_2026_Advance_Scouting_Report.pdf)
- [In-Zone Whiff Heatmap](outputs/ben_rice_whiff_heatmap.png)
- [Strike-Zone Comparison](outputs/ben_rice_zone_comparison.png)
- [Pitch Types Faced](outputs/ben_rice_pitch_types.png)
- [SQL Analysis](sql/Ben_Rice_Analysis.sql)

## Limitations

This is an exploratory scouting analysis based on one season of pitch-level data. Some pitch-type and matchup comparisons contain small samples. Contact-value metrics describe balls put in play rather than overall offensive production, and the strike-zone boundaries are approximations.
