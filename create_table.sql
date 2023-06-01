USE sp500;

CREATE TABLE IF NOT EXISTS sp500_sector_count(
    Sector VARCHAR(30), 
    Count INTEGER,
    Date DATE
);