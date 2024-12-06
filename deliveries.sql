CREATE TABLE deliveries (
    id INT,
    inning INT,
    over INT,
    ball INT,
    batsman TEXT,
    non_striker TEXT,
    bowler TEXT,
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    is_wicket INT,
    dismissal_kind TEXT,
    player_dismissed TEXT,
    fielder TEXT,
    extras_type TEXT,
    batting_team TEXT,
    bowling_team TEXT
);
COPY deliveries from 'C:\Program Files\PostgreSQL\16\data\Data-Resource\Data\IPL Dataset\IPL Dataset\ipl_ball.csv' csv header;
select * from deliveries;

--TASK-1
SELECT batsman,
       SUM(batsman_runs) AS total_runs,
       COUNT(*) AS balls_faced,
       (SUM(batsman_runs) * 1.0 / COUNT(*)) * 100 AS strk_rate
FROM deliveries
GROUP BY batsman
HAVING COUNT(*) > 500
ORDER BY strk_rate DESC
limit 10;

--TASK-2
SELECT batsman,
       SUM(batsman_runs) AS total_runs,
       COUNT(*) AS times_dismissed,
       (SUM(batsman_runs) * 1.0 / COUNT(*)) AS batting_average,
       COUNT(DISTINCT id) AS num_matches_played
FROM deliveries
WHERE is_wicket = 1 
GROUP BY batsman
HAVING COUNT(DISTINCT id) > 28 
   AND COUNT(*) > 0 
ORDER BY batting_average DESC
LIMIT 10;

--TASK-3
WITH BoundaryStats AS (
    SELECT
        batsman,
        SUM(CASE WHEN batsman_runs = 4 OR batsman_runs = 6 THEN 1 ELSE 0 END) AS boundary_count,
        SUM(batsman_runs) AS total_runs
    FROM
        deliveries
    GROUP BY
        batsman
),
PlayerSeasons AS (
    SELECT
        batsman,
        COUNT(DISTINCT id) AS seasons_played
    FROM
        deliveries
    GROUP BY
        batsman
)
SELECT
    bs.batsman,
    bs.total_runs,
    bs.boundary_count,
    (bs.boundary_count * 100.0 / NULLIF(bs.total_runs, 0)) AS boundary_percentage,
    ps.seasons_played
FROM
    BoundaryStats bs
JOIN
    PlayerSeasons ps ON bs.batsman = ps.batsman
WHERE
    ps.seasons_played > 2
ORDER BY
    boundary_percentage DESC,
    bs.total_runs DESC
LIMIT 10;

--TASK-4
SELECT 
    bowler,
    SUM(total_runs) AS total_runs_conceded,
    SUM(over) / 6 AS total_overs_bowled,
    SUM(total_runs) / (SUM(over) / 6) AS economy_rate
FROM 
    deliveries
GROUP BY 
    bowler
HAVING 
    COUNT(*) >= 500
ORDER BY 
    economy_rate
LIMIT 10;

--TASK-5
SELECT 
    bowler,
    COUNT(ball) AS total_balls,
    ROUND((COUNT(ball) / 6.0), 2) AS total_overs_bowled,
    SUM(total_runs - batsman_runs) AS total_runs_conceded,
    ROUND((SUM(total_runs - batsman_runs)) / (COUNT(ball) / 6.0), 2) AS economy
FROM 
    deliveries
GROUP BY 
    bowler
HAVING 
    COUNT(ball) >= 500
ORDER BY 
    economy ASC
LIMIT 10;

--TASK-6
WITH BattingStats AS (
    SELECT
        batsman,
        COUNT(*) AS balls_faced,
        SUM(CASE WHEN batsman_runs IN (4, 6) THEN 1 ELSE 0 END) AS boundary_count,
        SUM(batsman_runs) AS total_runs
    FROM
        deliveries
    GROUP BY
        batsman
),
BowlingStats AS (
    SELECT
        bowler,
        COUNT(*) AS balls_bowled,
        SUM(CASE WHEN is_wicket = 1 THEN 1 ELSE 0 END) AS wickets_taken
    FROM
       deliveries
    GROUP BY
        bowler
)
SELECT
    bs.batsman,
    bs.balls_faced,
    bs.boundary_count,
    bs.total_runs,
    ROUND((bs.total_runs / bs.balls_faced) * 100, 2) AS batting_strike_rate,
    bt.balls_bowled,
    bt.wickets_taken,
    ROUND((bt.wickets_taken / bt.balls_bowled) * 100, 2) AS bowling_strike_rate
FROM
    BattingStats bs
JOIN
    BowlingStats bt ON bs.batsman = bt.bowler
WHERE
    bs.balls_faced >= 500
    AND bt.balls_bowled >= 300
ORDER BY
    batting_strike_rate DESC,
    bowling_strike_rate ASC
LIMIT 10;

--task-7--
SELECT wicketkeeper_name
FROM wicketkeepers
ORDER BY 
    batting_average DESC,
    batting_strike_rate DESC
LIMIT 2;

--additional task-2
CREATE TABLE deliveries_v02 AS
SELECT *,
       CASE
           WHEN total_runs >= 4 THEN 'boundary'
           WHEN total_runs = 0 THEN 'dot'
           ELSE 'other'
       END AS ball_result
FROM deliveries;

--additional task-3
SELECT ball_result, COUNT(*) AS count
FROM deliveries_v02
WHERE ball_result IN ('boundary', 'dot')
GROUP BY ball_result;

--additional task-4
SELECT batting_team, COUNT(*) AS total_boundaries
FROM deliveries_v02
WHERE ball_result = 'boundary'
GROUP BY batting_team
ORDER BY total_boundaries DESC;

--additional task-5
SELECT bowling_team, COUNT(*) AS total_dot_balls
FROM deliveries_v02
WHERE ball_result = 'dot'
GROUP BY bowling_team
ORDER BY total_dot_balls DESC;

--additional task-6
SELECT dismissal_kind, COUNT(*) AS total_dismissals
FROM deliveries_v02
WHERE dismissal_kind IS NOT NULL AND dismissal_kind != 'NA'
GROUP BY dismissal_kind;

--additional task-7
SELECT bowler, SUM(extra_runs) AS total_extra_runs
FROM deliveries
GROUP BY bowler
ORDER BY total_extra_runs DESC
LIMIT 5;



