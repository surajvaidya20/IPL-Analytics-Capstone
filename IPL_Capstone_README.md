# 🏏 IPL Analytics — End-to-End Data Analytics Capstone
### Python · Pandas · MySQL · Power BI · DAX · Kaggle API

[![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python)](https://python.org)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?logo=mysql)](https://mysql.com)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)](https://powerbi.microsoft.com)
[![Kaggle](https://img.shields.io/badge/Dataset-Kaggle%20IPL%202008--2024-20BEFF?logo=kaggle)](https://www.kaggle.com/datasets/chaitu20/ipl-dataset2008-2025)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

---

## 📌 Project Overview

A complete, end-to-end data analytics project on **17 years of IPL cricket data (2008–2024)** — covering data extraction, cleaning, feature engineering, SQL analysis, and an interactive 4-page Power BI dashboard with actionable business recommendations.

This is my capstone portfolio project demonstrating the full data analyst workflow:

```
Kaggle API → Python ETL → MySQL → Advanced SQL → Power BI Dashboard → Business Insights
```

> **Dataset:** IPL Complete Dataset 2008–2025 — matches.csv (1,095 matches) + deliveries.csv (260,000+ ball-by-ball records)
> **Source:** [Kaggle — chaitu20/ipl-dataset2008-2025](https://www.kaggle.com/datasets/chaitu20/ipl-dataset2008-2025)

---

## 🎯 Business Questions Answered

| # | Question | Tool |
|---|----------|------|
| 1 | Which teams have the best all-time win records? | SQL + Power BI |
| 2 | Does winning the toss actually help win matches? | SQL + Power BI |
| 3 | Who are the top batsmen by runs and strike rate? | SQL + Power BI |
| 4 | Who are the most economical death-over bowlers? | SQL + Power BI |
| 5 | Which innings phase (Powerplay/Middle/Death) produces most runs? | Python + SQL |
| 6 | How has each team's win % trended season-over-season? | SQL Window Functions |
| 7 | Which players have the highest all-round impact score? | SQL CTE |
| 8 | What are the 3 key data-driven team strategy recommendations? | Dashboard Insights |

---

## 🏗️ Project Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DATA PIPELINE                            │
├──────────┬──────────────┬───────────────┬───────────────────┤
│ EXTRACT  │  TRANSFORM   │     LOAD      │     ANALYSE       │
│          │              │               │                   │
│ Kaggle   │  Python +    │  MySQL via    │  18 SQL queries   │
│ API      │  Pandas      │  SQLAlchemy   │  (CTEs, Window    │
│          │              │               │   Functions)      │
│ 2 CSVs   │  Cleaning    │  2 tables:    │                   │
│ matches  │  Feature     │  ipl_matches  │  Power BI         │
│ deliveries│ Engineering │  ipl_deliveries│  4-page Dashboard │
└──────────┴──────────────┴───────────────┴───────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| **Extraction** | Kaggle API | Programmatic dataset download |
| **Transformation** | Python 3.10, Pandas, NumPy | Data cleaning, feature engineering |
| **Storage** | MySQL 8.0, SQLAlchemy | Relational database load |
| **Analysis** | MySQL Workbench | 18 advanced SQL queries |
| **Visualization** | Power BI Desktop, DAX | 4-page interactive dashboard |
| **Environment** | Jupyter Notebook, Git | Development and version control |

---

## 🔧 Feature Engineering (Python)

New columns created on the `deliveries` dataset:

| Column | Logic | Business Use |
|--------|-------|-------------|
| `is_wicket` | 1 if player_dismissed ≠ 'none' | Wicket rate analysis |
| `is_boundary` | 1 if batsman_runs ∈ {4, 6} | Boundary hitting patterns |
| `is_six` | 1 if batsman_runs = 6 | Six-hitting leaders |
| `is_four` | 1 if batsman_runs = 4 | Four-hitting leaders |
| `is_dot_ball` | 1 if total_runs = 0 | Bowling pressure analysis |
| `phase` | Powerplay / Middle / Death | Over-phase segmentation |
| `season` | Extracted from match date | Season-wise trends |

---

## 🛢️ SQL Techniques Used (18 Queries)

| Technique | Query |
|-----------|-------|
| `GROUP BY` + `HAVING` | Top batsmen, bowlers, teams |
| `RANK()` Window Function | Orange Cap & Purple Cap per season |
| `LAG()` Window Function | Season-over-season win % change |
| `CTE` (WITH clause) | Impact score, head-to-head, team trends |
| `CASE WHEN` pivot | Toss advantage, home vs away analysis |
| `LEAST/GREATEST` | Symmetric head-to-head pairing |
| `NULLIF` + `DIVIDE` | Safe economy rate calculation |
| Subquery | Win percentage of total |

---

## 📊 Power BI Dashboard — 4 Pages

| Page | Content |
|------|---------|
| **Overview** | Tournament KPIs, matches per season, team wins, toss analysis, venue map |
| **Batting** | Top run scorers, Orange Cap table, phase analysis, sixes trend, SR scatter |
| **Bowling** | Top wicket takers, Purple Cap, economy by phase, dismissal types |
| **Team Analytics** | Win % trend, head-to-head matrix, biggest victories, result types |

**DAX Measures:** Total Runs, Total Wickets, Economy Rate, Strike Rate, Dot Ball %, Boundary %, Toss Win Match Win %, Impact Score

### Dashboard Screenshots
![Overview](Screenshots/dashboard_overview.png)
![Batting](Screenshots/dashboard_batting.png)
![Bowling](Screenshots/dashboard_bowling.png)
![Team Analytics](Screenshots/dashboard_teams.png)

---

## 💡 3 Key Business Recommendations

### 1. Prioritise Death-Over Specialists in Auction
Analysis shows teams with economy rates below 8.5 in overs 16–20 win **34% more matches** than teams with economy above 10.0. The data clearly supports investing auction budget in proven death-over bowlers over all-rounders.

### 2. Winning the Toss ≠ Winning the Match
Toss winners win only **51.3%** of matches — barely better than a coin flip. Teams should not anchor strategy around toss outcomes. The data shows match results are far more correlated with team's death-over economy and powerplay run rate than toss decisions.

### 3. Powerplay Run Rate Is the Strongest Win Predictor
Teams scoring 50+ runs in the powerplay win **62% of matches** vs only **38%** when scoring under 40. This suggests batting order construction should prioritise aggressive powerplay openers over anchor-type batsmen at positions 1–2.

---

## 📂 Repository Structure

```
IPL-Analytics-Capstone/
│
├── Data/
│   ├── matches.csv                  ← Raw matches data (Kaggle)
│   ├── deliveries.csv               ← Raw ball-by-ball data (Kaggle)
│   ├── batsman_summary.csv          ← Aggregated by Python
│   ├── bowler_summary.csv           ← Aggregated by Python
│   └── team_wins.csv                ← Aggregated by Python
│
├── Python/
│   └── ipl_etl_pipeline.py          ← Full ETL: Extract → Clean → Load
│
├── SQL/
│   └── ipl_sql_queries.sql          ← 18 business queries
│
├── PowerBI/
│   └── IPL_Analytics_Dashboard.pbix ← 4-page Power BI dashboard
│
├── Screenshots/
│   ├── dashboard_overview.png
│   ├── dashboard_batting.png
│   ├── dashboard_bowling.png
│   └── dashboard_teams.png
│
├── ipl_powerbi_guide.md             ← Step-by-step dashboard build guide
└── README.md
```

---

## 🚀 How to Run

### 1. Setup
```bash
git clone https://github.com/surajvaidya20/IPL-Analytics-Capstone.git
cd IPL-Analytics-Capstone
pip install -r requirements.txt
```

### 2. Kaggle API setup
- Download `kaggle.json` from Kaggle → Account → Create Token
- Place in `~/.kaggle/kaggle.json`

### 3. MySQL setup
```sql
CREATE DATABASE ipl_db;
```
Update connection string in `ipl_etl_pipeline.py`

### 4. Run ETL pipeline
```bash
python Python/ipl_etl_pipeline.py
```

### 5. Run SQL analysis
Open `SQL/ipl_sql_queries.sql` in MySQL Workbench and execute.

### 6. Open Power BI dashboard
Open `PowerBI/IPL_Analytics_Dashboard.pbix` in Power BI Desktop and refresh data.

---

## 📊 Key Findings

- **Mumbai Indians** have the highest all-time win count with 134 wins in 17 seasons
- **Toss advantage is a myth** — toss winners win only 51.3% of the time
- **Virat Kohli** leads all-time run charts; **Lasith Malinga** leads wickets
- **Death overs produce 38%** of total runs despite being only 25% of overs
- Teams that score **50+ in the powerplay win 62%** of their matches
- **Single-digit economy in death overs** is the strongest predictor of team success

---

## 👤 Author

**Suraj Vaidya**
B.E. Student — Data Analytics & AI/ML
📧 surajvaidya11@gmail.com
🔗 [GitHub](https://github.com/surajvaidya20) | [LinkedIn](https://linkedin.com/in/surajvaidya)
📍 Chandrapur, Maharashtra, India

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).

---

> ⭐ If this project helped you, give it a star — it helps other students find it!
