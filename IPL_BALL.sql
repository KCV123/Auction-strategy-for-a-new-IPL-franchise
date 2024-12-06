CREATE TABLE ipl_matches (
    id SERIAL PRIMARY KEY,
    city TEXT,
    match_date DATE,
    player_of_match TEXT,
    venue TEXT,
    neutral_venue BOOLEAN,
    team1 TEXT,
    team2 TEXT,
    toss_winner TEXT,
    toss_decision TEXT,
    winner TEXT,
    result TEXT,
    result_margin INTEGER,
    eliminator TEXT,
    method TEXT,
    umpire1 TEXT,
    umpire2 TEXT
);

COPY ipl_matches from 'C:\Program Files\PostgreSQL\16\data\Data-Resource\Data\IPL Dataset\IPL Dataset\ipl_matches.csv' csv header;
select * from ipl_matches;

--ADDTIONAL TASK-1
SELECT COUNT(DISTINCT city) AS city_count
FROM ipl_matches;
