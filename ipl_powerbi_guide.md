# ══════════════════════════════════════════════════════════════
# IPL ANALYTICS — POWER BI DASHBOARD GUIDE
# Author : Suraj Vaidya | GitHub: surajvaidya20
# ══════════════════════════════════════════════════════════════

================================================================
IMPORT THESE FILES INTO POWER BI
================================================================
1. matches.csv             (cleaned from Python)
2. deliveries.csv          (enriched from Python)
3. batsman_summary.csv     (aggregated from Python)
4. bowler_summary.csv      (aggregated from Python)
5. team_wins.csv           (aggregated from Python)

Or connect directly to MySQL:
  Get Data → MySQL → host: localhost → database: ipl_db
  Import both tables: ipl_matches + ipl_deliveries

================================================================
DAX MEASURES — PASTE IN MODELING → NEW MEASURE
================================================================

Total Matches      = COUNTROWS('ipl_matches')
Total Seasons      = DISTINCTCOUNT('ipl_matches'[season])
Total Runs         = SUM('ipl_deliveries'[batsman_runs])
Total Wickets      = SUM('ipl_deliveries'[is_wicket])
Total Sixes        = SUM('ipl_deliveries'[is_six])
Total Fours        = SUM('ipl_deliveries'[is_four])

Team Wins =
CALCULATE(
    COUNTROWS('ipl_matches'),
    'ipl_matches'[winner] <> BLANK()
)

Toss Win Match Win % =
DIVIDE(
    CALCULATE(COUNTROWS('ipl_matches'),
        'ipl_matches'[toss_winner] = 'ipl_matches'[winner]),
    COUNTROWS('ipl_matches'),
    0
) * 100

Avg Strike Rate =
DIVIDE([Total Runs], [Total Balls]) * 100

Total Balls = COUNT('ipl_deliveries'[ball])

Economy Rate =
DIVIDE([Total Runs], DIVIDE([Total Balls], 6), 0)

Dot Ball % =
DIVIDE(SUM('ipl_deliveries'[is_dot_ball]), [Total Balls]) * 100

Boundary % =
DIVIDE(SUM('ipl_deliveries'[is_boundary]), [Total Balls]) * 100

================================================================
CALCULATED COLUMNS
================================================================

-- In ipl_matches: Match Result Label
Match Result Label =
IF(ISBLANK('ipl_matches'[winner]), "No Result",
    IF('ipl_matches'[toss_winner] = 'ipl_matches'[winner],
       "Toss & Match Won", "Toss Lost, Match Won"))

-- In ipl_deliveries: Over Category (if phase column missing)
Over Category =
SWITCH(TRUE(),
    'ipl_deliveries'[over] <= 6,  "Powerplay",
    'ipl_deliveries'[over] <= 15, "Middle",
    "Death"
)

================================================================
PAGE 1 — TOURNAMENT OVERVIEW
================================================================

KPI CARDS (top row):
  [Total Matches]  [Total Seasons]  [Total Teams]
  [Total Runs]     [Total Sixes]    [Total Wickets]

VISUALS:

1. LINE CHART — Matches per Season
   X: season | Y: Count of id

2. STACKED BAR — Top 10 Teams by Wins
   Y: winner | X: Team Wins
   Sort: descending

3. DONUT — Toss Decision Breakdown
   Legend: toss_decision | Values: Count of id

4. MAP / FILLED MAP — Venue locations
   Location: venue | Bubble size: Count of matches

5. MATRIX TABLE — Head-to-Head Records
   Rows: team1 | Columns: team2 | Values: Count

SLICERS: season (range slider), team1, venue

================================================================
PAGE 2 — BATTING ANALYSIS
================================================================

KPI CARDS:
  [Total Runs]  [Total Sixes]  [Total Fours]
  [Avg Strike Rate]  [Boundary %]

VISUALS:

1. HORIZONTAL BAR — Top 15 Run Scorers
   Y: batsman | X: Total Runs
   Data labels on

2. CLUSTERED BAR — Runs by Innings Phase
   X: Over Category | Y: Total Runs
   Colors: Blue/Amber/Red for Powerplay/Middle/Death

3. SCATTER CHART — Runs vs Strike Rate (player bubbles)
   X: Total Runs | Y: Avg Strike Rate
   Size: Total matches | Legend: batsman (top 20 only)

4. TABLE — Orange Cap Per Season
   Columns: season, batsman, runs
   Conditional format: top row green

5. COLUMN CHART — Sixes per Season trend
   X: season | Y: Total Sixes

SLICERS: season, batting_team, phase

================================================================
PAGE 3 — BOWLING ANALYSIS
================================================================

KPI CARDS:
  [Total Wickets]  [Economy Rate]  [Dot Ball %]
  [Total Balls]    [Avg Wickets per Match]

VISUALS:

1. HORIZONTAL BAR — Top 15 Wicket Takers
   Y: bowler | X: Total Wickets

2. CLUSTERED BAR — Economy Rate by Phase
   X: Over Category | Y: Economy Rate

3. SCATTER — Wickets vs Economy (bowler comparison)
   X: Economy Rate | Y: Total Wickets
   Size: Matches | Tooltip: bowler name

4. TABLE — Purple Cap Per Season
   Columns: season, bowler, wickets
   Conditional format: top row green

5. BAR — Dismissal Types breakdown
   X: dismissal_kind | Y: Count

SLICERS: season, bowling_team, phase

================================================================
PAGE 4 — TEAM ANALYTICS
================================================================

KPI CARDS (filter by team slicer):
  [Team Wins]  [Win Rate %]  [Toss Win Match Win %]
  [Avg Runs Scored]  [Avg Wickets Taken]

VISUALS:

1. LINE CHART — Win % Trend over Seasons
   X: season | Y: Win % | Legend: team
   Show top 5 teams only

2. CLUSTERED COLUMN — Home vs Away wins
   X: team | Y: wins | Split: home/away

3. MATRIX — Team vs Team Head-to-Head
   Rows: team1 | Columns: team2 | Values: wins
   Conditional formatting: darker green = more wins

4. BAR — Biggest victories by run margin
   Top 10 matches with highest result_margin (runs)

5. DONUT — Wins by result type (runs vs wickets)

SLICERS: season, team, venue

================================================================
FORMATTING GUIDE
================================================================

THEME: Download "Modern" theme from Power BI community
OR use these manual colors:

Primary Blue  : #185FA5
Accent Green  : #1D9E75
Warning Amber : #EF9F27
Danger Red    : #E24B4A
Background    : #F8F9FA
Card bg       : #FFFFFF
Text dark     : #1A1A2E
Text muted    : #6B7280

FONT: Segoe UI (Power BI default — keep it)
Title size    : 14px Bold
Axis labels   : 10px
Data labels   : 10px

LAYOUT TIPS:
- Add IPL logo (PNG) top-left of each page
- Add navigation buttons between pages
- Keep filter panel consistent across all pages
- Add "Last Updated: 2024" text box bottom-right

================================================================
TIME ESTIMATE
================================================================
Data import + relationships  : 30 min
DAX measures                 : 45 min
Page 1 (Overview)            : 1.5 hrs
Page 2 (Batting)             : 1.5 hrs
Page 3 (Bowling)             : 1.5 hrs
Page 4 (Team Analytics)      : 1.5 hrs
Formatting + polish          : 1 hr
Total                        : ~8 hrs across 2 days
================================================================
