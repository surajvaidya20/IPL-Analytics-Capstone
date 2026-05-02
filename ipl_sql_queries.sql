-- ══════════════════════════════════════════════════════════════
-- IPL ANALYTICS CAPSTONE — SQL KPI & Advanced Queries
-- Author  : Suraj Vaidya | GitHub: surajvaidya20
-- Database: MySQL  |  Tables: ipl_matches, ipl_deliveries
-- Dataset : https://www.kaggle.com/datasets/chaitu20/ipl-dataset2008-2025
-- ══════════════════════════════════════════════════════════════


-- ──────────────────────────────────────────────────────────────
-- SECTION 1: MATCH-LEVEL KPIs
-- ──────────────────────────────────────────────────────────────

-- Q1. Overall tournament summary
SELECT
    COUNT(DISTINCT id)                        AS total_matches,
    COUNT(DISTINCT season)                    AS total_seasons,
    COUNT(DISTINCT team1)                     AS total_teams,
    MIN(season)                               AS first_season,
    MAX(season)                               AS last_season
FROM ipl_matches;


-- Q2. Most successful teams (all-time wins)
SELECT
    winner                          AS team,
    COUNT(*)                        AS total_wins,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM ipl_matches WHERE winner IS NOT NULL), 1) AS win_pct
FROM ipl_matches
WHERE winner IS NOT NULL
GROUP BY winner
ORDER BY total_wins DESC
LIMIT 10;


-- Q3. Season-wise champion (most wins per season)
WITH season_wins AS (
    SELECT
        season,
        winner,
        COUNT(*) AS wins,
        RANK() OVER (PARTITION BY season ORDER BY COUNT(*) DESC) AS rn
    FROM ipl_matches
    WHERE winner IS NOT NULL
    GROUP BY season, winner
)
SELECT season, winner AS most_wins_team, wins
FROM season_wins
WHERE rn = 1
ORDER BY season;


-- Q4. Toss advantage — does winning toss help win the match?
SELECT
    toss_decision,
    COUNT(*)                                     AS total_matches,
    SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS toss_winner_won,
    ROUND(
        SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1
    )                                            AS win_after_toss_pct
FROM ipl_matches
WHERE winner IS NOT NULL
GROUP BY toss_decision;


-- Q5. Venue-wise match count and avg margin
SELECT
    venue,
    COUNT(*)                          AS matches_played,
    ROUND(AVG(result_margin), 1)      AS avg_margin
FROM ipl_matches
GROUP BY venue
ORDER BY matches_played DESC
LIMIT 10;


-- ──────────────────────────────────────────────────────────────
-- SECTION 2: BATTING ANALYSIS
-- ──────────────────────────────────────────────────────────────

-- Q6. Top 10 all-time run scorers with strike rate
SELECT
    batsman,
    SUM(batsman_runs)                              AS total_runs,
    COUNT(ball)                                    AS balls_faced,
    ROUND(SUM(batsman_runs) * 100.0 / COUNT(ball), 2) AS strike_rate,
    SUM(is_four)                                   AS fours,
    SUM(is_six)                                    AS sixes,
    COUNT(DISTINCT match_id)                       AS matches_played
FROM ipl_deliveries
GROUP BY batsman
HAVING balls_faced >= 500
ORDER BY total_runs DESC
LIMIT 10;


-- Q7. Orange Cap contender per season (top run scorer each year)
WITH season_runs AS (
    SELECT
        d.season,
        d.batsman,
        SUM(d.batsman_runs) AS runs,
        RANK() OVER (PARTITION BY d.season ORDER BY SUM(d.batsman_runs) DESC) AS rn
    FROM ipl_deliveries d
    GROUP BY d.season, d.batsman
)
SELECT season, batsman AS orange_cap, runs
FROM season_runs
WHERE rn = 1
ORDER BY season;


-- Q8. Batting performance by innings phase (Powerplay / Middle / Death)
SELECT
    phase,
    ROUND(AVG(total_runs), 4)          AS avg_runs_per_ball,
    ROUND(SUM(batsman_runs) * 100.0 /
        COUNT(ball), 2)                AS overall_strike_rate,
    SUM(is_boundary)                   AS total_boundaries,
    SUM(is_wicket)                     AS total_wickets,
    COUNT(ball)                        AS total_balls
FROM ipl_deliveries
GROUP BY phase
ORDER BY FIELD(phase, 'Powerplay (1-6)', 'Middle (7-15)', 'Death (16-20)');


-- Q9. Most sixes hit in IPL history
SELECT
    batsman,
    SUM(is_six)   AS total_sixes,
    SUM(is_four)  AS total_fours,
    SUM(batsman_runs) AS total_runs
FROM ipl_deliveries
GROUP BY batsman
ORDER BY total_sixes DESC
LIMIT 10;


-- Q10. Best strike rate (min 1000 balls faced)
SELECT
    batsman,
    SUM(batsman_runs) AS total_runs,
    COUNT(ball)        AS balls_faced,
    ROUND(SUM(batsman_runs) * 100.0 / COUNT(ball), 2) AS strike_rate
FROM ipl_deliveries
GROUP BY batsman
HAVING balls_faced >= 1000
ORDER BY strike_rate DESC
LIMIT 10;


-- ──────────────────────────────────────────────────────────────
-- SECTION 3: BOWLING ANALYSIS
-- ──────────────────────────────────────────────────────────────

-- Q11. Top 10 all-time wicket takers with economy
SELECT
    bowler,
    SUM(is_wicket)                                AS total_wickets,
    ROUND(SUM(total_runs) / (COUNT(ball) / 6.0), 2) AS economy_rate,
    COUNT(DISTINCT match_id)                      AS matches,
    SUM(is_dot_ball)                              AS dot_balls,
    ROUND(SUM(is_dot_ball) * 100.0 / COUNT(ball), 1) AS dot_ball_pct
FROM ipl_deliveries
GROUP BY bowler
HAVING matches >= 20
ORDER BY total_wickets DESC
LIMIT 10;


-- Q12. Purple Cap per season (top wicket taker each year)
WITH season_wickets AS (
    SELECT
        season,
        bowler,
        SUM(is_wicket) AS wickets,
        RANK() OVER (PARTITION BY season ORDER BY SUM(is_wicket) DESC) AS rn
    FROM ipl_deliveries
    GROUP BY season, bowler
)
SELECT season, bowler AS purple_cap, wickets
FROM season_wickets
WHERE rn = 1
ORDER BY season;


-- Q13. Most economical bowlers in death overs (over 16–20, min 50 overs)
SELECT
    bowler,
    ROUND(SUM(total_runs) / (COUNT(ball) / 6.0), 2) AS death_economy,
    SUM(is_wicket)                                AS death_wickets,
    COUNT(ball) / 6                               AS overs_bowled
FROM ipl_deliveries
WHERE phase = 'Death (16-20)'
GROUP BY bowler
HAVING overs_bowled >= 50
ORDER BY death_economy
LIMIT 10;


-- ──────────────────────────────────────────────────────────────
-- SECTION 4: ADVANCED ANALYSIS (CTEs + Window Functions)
-- ──────────────────────────────────────────────────────────────

-- Q14. Head-to-head team records
SELECT
    team1,
    team2,
    COUNT(*)                                          AS total_matches,
    SUM(CASE WHEN winner = team1 THEN 1 ELSE 0 END)  AS team1_wins,
    SUM(CASE WHEN winner = team2 THEN 1 ELSE 0 END)  AS team2_wins
FROM ipl_matches
WHERE winner IS NOT NULL
GROUP BY LEAST(team1,team2), GREATEST(team1,team2), team1, team2
HAVING total_matches >= 5
ORDER BY total_matches DESC
LIMIT 15;


-- Q15. Win % trend season-over-season (top 4 teams)
WITH team_seasons AS (
    SELECT
        season,
        team1 AS team FROM ipl_matches
    UNION ALL
    SELECT season, team2 FROM ipl_matches
),
played AS (
    SELECT season, team, COUNT(*) AS played
    FROM team_seasons GROUP BY season, team
),
won AS (
    SELECT season, winner AS team, COUNT(*) AS wins
    FROM ipl_matches WHERE winner IS NOT NULL
    GROUP BY season, winner
)
SELECT
    p.season,
    p.team,
    p.played,
    COALESCE(w.wins, 0) AS wins,
    ROUND(COALESCE(w.wins, 0) * 100.0 / p.played, 1) AS win_pct,
    ROUND(COALESCE(w.wins, 0) * 100.0 / p.played, 1) -
        LAG(ROUND(COALESCE(w.wins,0)*100.0/p.played,1))
        OVER (PARTITION BY p.team ORDER BY p.season) AS win_pct_change
FROM played p
LEFT JOIN won w ON p.season = w.season AND p.team = w.team
WHERE p.team IN ('Mumbai Indians','Chennai Super Kings',
                 'Kolkata Knight Riders','Royal Challengers Bengaluru')
ORDER BY p.team, p.season;


-- Q16. Super Over & close match analysis (won by <=5 runs or <=1 wicket)
SELECT
    season,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN result_margin <= 5 AND result = 'runs' THEN 1 ELSE 0 END)   AS won_by_le5_runs,
    SUM(CASE WHEN result_margin <= 1 AND result = 'wickets' THEN 1 ELSE 0 END) AS won_by_le1_wicket
FROM ipl_matches
WHERE winner IS NOT NULL
GROUP BY season
ORDER BY season;


-- Q17. Player of the match leaders
SELECT
    player_of_match,
    COUNT(*) AS pom_awards,
    COUNT(DISTINCT season) AS seasons_active
FROM ipl_matches
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY pom_awards DESC
LIMIT 15;


-- Q18. Impact score — combined batting + bowling contribution
WITH batting AS (
    SELECT batsman AS player,
        SUM(batsman_runs)                              AS runs,
        ROUND(SUM(batsman_runs)*100.0/COUNT(ball), 2)  AS sr
    FROM ipl_deliveries GROUP BY batsman
    HAVING COUNT(ball) >= 500
),
bowling AS (
    SELECT bowler AS player,
        SUM(is_wicket)                                    AS wickets,
        ROUND(SUM(total_runs)/(COUNT(ball)/6.0), 2)       AS economy
    FROM ipl_deliveries GROUP BY bowler
    HAVING COUNT(ball) >= 300
)
SELECT
    b.player,
    b.runs,
    b.sr              AS batting_sr,
    bl.wickets,
    bl.economy,
    ROUND((b.runs / 100) + (bl.wickets * 20) + (b.sr / 10) - bl.economy, 2) AS impact_score
FROM batting b
JOIN bowling bl ON b.player = bl.player
ORDER BY impact_score DESC
LIMIT 15;
