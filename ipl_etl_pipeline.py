# ══════════════════════════════════════════════════════════════════════
#  IPL ANALYTICS — CAPSTONE PROJECT
#  Step 1: Data Collection + Cleaning + Feature Engineering (Python)
#  Author : Suraj Vaidya | GitHub: surajvaidya20
#  Dataset : IPL Complete Dataset 2008–2024 (Kaggle)
#  Source  : https://www.kaggle.com/datasets/chaitu20/ipl-dataset2008-2025
# ══════════════════════════════════════════════════════════════════════

import kaggle
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import sqlalchemy as sal
import warnings
warnings.filterwarnings('ignore')

print("=" * 60)
print("  IPL ANALYTICS CAPSTONE — ETL PIPELINE")
print("=" * 60)

# ──────────────────────────────────────────────────────────────
# STEP 1: EXTRACT — Download via Kaggle API
# ──────────────────────────────────────────────────────────────
print("\n[1/6] Downloading dataset from Kaggle...")
kaggle.api.authenticate()
kaggle.api.dataset_download_files('chaitu20/ipl-dataset2008-2025', path='.', unzip=True)
print("      Download complete.")

# ──────────────────────────────────────────────────────────────
# STEP 2: LOAD — Read both CSV files
# ──────────────────────────────────────────────────────────────
print("\n[2/6] Loading data...")
matches    = pd.read_csv('matches.csv')
deliveries = pd.read_csv('deliveries.csv')

print(f"      matches.csv    : {matches.shape[0]:,} rows × {matches.shape[1]} columns")
print(f"      deliveries.csv : {deliveries.shape[0]:,} rows × {deliveries.shape[1]} columns")
print(f"\n      matches columns    : {list(matches.columns)}")
print(f"      deliveries columns : {list(deliveries.columns)}")

# ──────────────────────────────────────────────────────────────
# STEP 3: TRANSFORM — Clean matches.csv
# ──────────────────────────────────────────────────────────────
print("\n[3/6] Cleaning matches data...")

# 3a. Check nulls
print("\n      Null values in matches:")
print(matches.isnull().sum()[matches.isnull().sum() > 0])

# 3b. Standardize column names
matches.columns    = matches.columns.str.lower().str.replace(' ', '_')
deliveries.columns = deliveries.columns.str.lower().str.replace(' ', '_')

# 3c. Convert date to datetime
matches['date'] = pd.to_datetime(matches['date'])

# 3d. Extract year and season
matches['season'] = matches['date'].dt.year

# 3e. Fix team name inconsistencies (teams renamed over the years)
team_name_map = {
    'Delhi Daredevils'           : 'Delhi Capitals',
    'Deccan Chargers'            : 'Sunrisers Hyderabad',
    'Kings XI Punjab'            : 'Punjab Kings',
    'Rising Pune Supergiant'     : 'Rising Pune Supergiants',
    'Pune Warriors'              : 'Pune Warriors India',
}
for col in ['team1', 'team2', 'winner', 'toss_winner']:
    if col in matches.columns:
        matches[col] = matches[col].replace(team_name_map)

# 3f. Fill nulls in result_margin (ties/no result have 0)
matches['result_margin'] = matches['result_margin'].fillna(0)

# 3g. Drop duplicate match IDs if any
matches.drop_duplicates(subset='id', inplace=True)

print("      matches cleaning complete.")
print(f"      Final shape: {matches.shape}")

# ──────────────────────────────────────────────────────────────
# STEP 4: TRANSFORM — Clean deliveries.csv + Feature Engineer
# ──────────────────────────────────────────────────────────────
print("\n[4/6] Cleaning & enriching deliveries data...")

# 4a. Check nulls
print("\n      Null values in deliveries:")
print(deliveries.isnull().sum()[deliveries.isnull().sum() > 0])

# 4b. Fill nulls in player_dismissed (no wicket = 'none')
deliveries['player_dismissed'] = deliveries['player_dismissed'].fillna('none')
deliveries['dismissal_kind']   = deliveries['dismissal_kind'].fillna('none')
deliveries['fielder']          = deliveries['fielder'].fillna('none')

# 4c. Feature: is_wicket flag (1 or 0)
deliveries['is_wicket'] = deliveries['player_dismissed'].apply(lambda x: 0 if x == 'none' else 1)

# 4d. Feature: is_boundary (4 or 6)
deliveries['is_boundary'] = deliveries['batsman_runs'].apply(lambda x: 1 if x in [4, 6] else 0)
deliveries['is_six']      = deliveries['batsman_runs'].apply(lambda x: 1 if x == 6 else 0)
deliveries['is_four']     = deliveries['batsman_runs'].apply(lambda x: 1 if x == 4 else 0)

# 4e. Feature: is_dot_ball
deliveries['is_dot_ball'] = deliveries['total_runs'].apply(lambda x: 1 if x == 0 else 0)

# 4f. Feature: phase of innings
def get_phase(over):
    if over <= 6:   return 'Powerplay (1-6)'
    elif over <= 15: return 'Middle (7-15)'
    else:            return 'Death (16-20)'

deliveries['phase'] = deliveries['over'].apply(get_phase)

# 4g. Merge season into deliveries
deliveries = deliveries.merge(matches[['id', 'season', 'date']], left_on='match_id', right_on='id', how='left')

print("      deliveries enrichment complete.")
print(f"      Final shape: {deliveries.shape}")
print(f"      New columns: is_wicket, is_boundary, is_six, is_four, is_dot_ball, phase, season")

# ──────────────────────────────────────────────────────────────
# STEP 5: LOAD — Push to MySQL via SQLAlchemy
# ──────────────────────────────────────────────────────────────
print("\n[5/6] Loading to MySQL database...")

# Replace credentials with yours
engine = sal.create_engine('mysql+pymysql://root:password@localhost/ipl_db')
conn   = engine.connect()

matches.to_sql('ipl_matches',    con=conn, index=False, if_exists='replace')
deliveries.to_sql('ipl_deliveries', con=conn, index=False, if_exists='replace')

print("      Tables created: ipl_matches, ipl_deliveries")
conn.close()

# ──────────────────────────────────────────────────────────────
# STEP 6: EDA — Exploratory Visualizations (Python)
# ──────────────────────────────────────────────────────────────
print("\n[6/6] Generating EDA plots...")

plt.style.use('seaborn-v0_8-whitegrid')
fig, axes = plt.subplots(2, 3, figsize=(16, 10))
fig.suptitle('IPL Analytics (2008–2024) — EDA Overview', fontsize=14, fontweight='bold')

# Plot 1: Matches per season
season_counts = matches.groupby('season').size()
axes[0,0].bar(season_counts.index, season_counts.values, color='#185FA5', edgecolor='white')
axes[0,0].set_title('Matches per Season')
axes[0,0].set_xlabel('Season')
axes[0,0].set_ylabel('Matches')
axes[0,0].tick_params(axis='x', rotation=45)

# Plot 2: Top 10 run scorers
top_batsmen = deliveries.groupby('batsman')['batsman_runs'].sum().sort_values(ascending=False).head(10)
axes[0,1].barh(top_batsmen.index[::-1], top_batsmen.values[::-1], color='#1D9E75')
axes[0,1].set_title('Top 10 Run Scorers (All-time)')
axes[0,1].set_xlabel('Total Runs')

# Plot 3: Top 10 wicket takers
top_bowlers = deliveries[deliveries['is_wicket'] == 1].groupby('bowler')['is_wicket'].sum().sort_values(ascending=False).head(10)
axes[0,2].barh(top_bowlers.index[::-1], top_bowlers.values[::-1], color='#E24B4A')
axes[0,2].set_title('Top 10 Wicket Takers (All-time)')
axes[0,2].set_xlabel('Total Wickets')

# Plot 4: Toss decision analysis
toss_counts = matches['toss_decision'].value_counts()
axes[1,0].pie(toss_counts.values, labels=toss_counts.index, autopct='%1.1f%%',
              colors=['#378ADD', '#EF9F27'], startangle=90)
axes[1,0].set_title('Toss Decision Breakdown')

# Plot 5: Runs by innings phase
phase_runs = deliveries.groupby('phase')['total_runs'].sum()
phase_order = ['Powerplay (1-6)', 'Middle (7-15)', 'Death (16-20)']
phase_runs = phase_runs.reindex(phase_order)
axes[1,1].bar(phase_runs.index, phase_runs.values, color=['#185FA5', '#EF9F27', '#E24B4A'])
axes[1,1].set_title('Total Runs by Innings Phase')
axes[1,1].set_ylabel('Total Runs')
axes[1,1].tick_params(axis='x', rotation=15)

# Plot 6: Win by result type
result_counts = matches['result'].value_counts() if 'result' in matches.columns else pd.Series()
if not result_counts.empty:
    axes[1,2].bar(result_counts.index, result_counts.values, color='#7F77DD')
    axes[1,2].set_title('Match Results by Type')
    axes[1,2].set_ylabel('Count')
else:
    axes[1,2].text(0.5, 0.5, 'No result column', ha='center', va='center')

plt.tight_layout()
plt.savefig('eda_overview.png', dpi=150, bbox_inches='tight')
plt.show()
print("      EDA chart saved: eda_overview.png")

# ──────────────────────────────────────────────────────────────
# KEY AGGREGATIONS — Save for Power BI
# ──────────────────────────────────────────────────────────────
print("\n      Saving aggregated CSVs for Power BI import...")

# Batsman summary
batsman_summary = deliveries.groupby(['batsman', 'season']).agg(
    runs    = ('batsman_runs', 'sum'),
    balls   = ('ball', 'count'),
    fours   = ('is_four', 'sum'),
    sixes   = ('is_six', 'sum'),
    wickets = ('is_wicket', 'sum')
).reset_index()
batsman_summary['strike_rate'] = (batsman_summary['runs'] / batsman_summary['balls'] * 100).round(2)
batsman_summary.to_csv('batsman_summary.csv', index=False)

# Bowler summary
bowler_summary = deliveries.groupby(['bowler', 'season']).agg(
    wickets    = ('is_wicket', 'sum'),
    runs_given = ('total_runs', 'sum'),
    balls      = ('ball', 'count'),
    dot_balls  = ('is_dot_ball', 'sum')
).reset_index()
bowler_summary['economy'] = (bowler_summary['runs_given'] / (bowler_summary['balls'] / 6)).round(2)
bowler_summary.to_csv('bowler_summary.csv', index=False)

# Team summary
team_wins = matches.groupby(['winner', 'season']).size().reset_index(name='wins')
team_wins.to_csv('team_wins.csv', index=False)

print("      Saved: batsman_summary.csv, bowler_summary.csv, team_wins.csv")
print("\n✅ ETL Pipeline complete! Run sql_queries.sql for advanced analysis.")
print("   Import CSVs into Power BI for dashboard.\n")
