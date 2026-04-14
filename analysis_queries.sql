-- ============================================================
-- Billboard Audience Intelligence — SQL Query Library
-- Author: Lyles Mom | Cultural Intelligence & Audience Strategy
-- Database: PostgreSQL (compatible with SQLite with minor adjustments)
-- Tables:
--   billboard_hot100  (song, artist, date, peak_position, weeks_on_board, chart_position)
--   spotify_tracks    (song, artist, popularity, energy, danceability, acousticness,
--                      valence, tempo, track_genre)
--   merged_analysis   (joined table — output of Python pipeline)
-- ============================================================


-- ────────────────────────────────────────────
-- Q1: MATCH RATE VALIDATION
-- What percentage of Billboard entries matched to Spotify features?
-- Used to document data scope and flag bias risk.
-- ────────────────────────────────────────────

WITH billboard_2000s AS (
    SELECT COUNT(*) AS total_entries
    FROM billboard_hot100
    WHERE EXTRACT(YEAR FROM date) BETWEEN 2000 AND 2021
),
matched AS (
    SELECT COUNT(*) AS matched_entries
    FROM merged_analysis
    WHERE year BETWEEN 2000 AND 2021
)
SELECT
    b.total_entries,
    m.matched_entries,
    ROUND(m.matched_entries * 100.0 / b.total_entries, 2) AS match_rate_pct
FROM billboard_2000s b, matched m;


-- ────────────────────────────────────────────
-- Q2: SAMPLE BIAS AUDIT — DECADE DRIFT
-- Does the matched sample over/under-represent certain eras?
-- Drift near 0 = low bias. High drift = sample skewed toward that decade.
-- ────────────────────────────────────────────

WITH full_dist AS (
    SELECT
        (EXTRACT(YEAR FROM date) / 10 * 10)::INT AS decade,
        COUNT(*) AS full_count,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS full_pct
    FROM billboard_hot100
    WHERE EXTRACT(YEAR FROM date) BETWEEN 2000 AND 2021
    GROUP BY 1
),
matched_dist AS (
    SELECT
        (year / 10 * 10)::INT AS decade,
        COUNT(*) AS matched_count,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS matched_pct
    FROM merged_analysis
    WHERE year BETWEEN 2000 AND 2021
    GROUP BY 1
)
SELECT
    f.decade,
    ROUND(f.full_pct, 1) AS full_billboard_pct,
    ROUND(m.matched_pct, 1) AS matched_sample_pct,
    ROUND(m.matched_pct - f.full_pct, 1) AS drift
FROM full_dist f
JOIN matched_dist m ON f.decade = m.decade
ORDER BY f.decade;


-- ────────────────────────────────────────────
-- Q3: PLATFORM DIVERGENCE SCORES BY SEGMENT
-- Core metric: chart_share% minus popularity_share%
-- Positive = overrepresented on Billboard
-- Negative = undervalued by Billboard relative to streaming
-- ────────────────────────────────────────────

WITH chart_shares AS (
    SELECT
        segment,
        COUNT(*) AS chart_entries,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS chart_share_pct
    FROM merged_analysis
    WHERE year BETWEEN 2000 AND 2021
    GROUP BY segment
),
pop_shares AS (
    SELECT
        segment,
        SUM(popularity) AS total_pop,
        SUM(popularity) * 100.0 / SUM(SUM(popularity)) OVER () AS pop_share_pct
    FROM merged_analysis
    WHERE year BETWEEN 2000 AND 2021
    GROUP BY segment
)
SELECT
    c.segment,
    c.chart_entries,
    ROUND(c.chart_share_pct, 2) AS chart_share_pct,
    ROUND(p.pop_share_pct, 2)   AS pop_share_pct,
    ROUND(c.chart_share_pct - p.pop_share_pct, 2) AS divergence_score,
    CASE
        WHEN c.chart_share_pct - p.pop_share_pct > 0.5  THEN 'Overrepresented on Billboard'
        WHEN c.chart_share_pct - p.pop_share_pct < -0.5 THEN 'Undervalued by Billboard'
        ELSE 'Aligned'
    END AS chart_status
FROM chart_shares c
JOIN pop_shares p ON c.segment = p.segment
ORDER BY divergence_score DESC;


-- ────────────────────────────────────────────
-- Q4: SEGMENT PERFORMANCE SUMMARY
-- Avg popularity, avg chart weeks, peak position by segment
-- Reveals which audiences have sustained attention vs. flash virality
-- ────────────────────────────────────────────

SELECT
    segment,
    COUNT(DISTINCT song || artist) AS unique_tracks,
    ROUND(AVG(popularity), 2)      AS avg_popularity,
    ROUND(AVG(weeks_on_board), 2)  AS avg_weeks_on_chart,
    ROUND(AVG(peak_position), 1)   AS avg_peak_position,
    MIN(peak_position)             AS best_peak,
    ROUND(STDDEV(popularity), 2)   AS popularity_variance
FROM merged_analysis
WHERE year BETWEEN 2000 AND 2021
GROUP BY segment
ORDER BY avg_popularity DESC;


-- ────────────────────────────────────────────
-- Q5: YEAR-OVER-YEAR DIVERGENCE TREND
-- Track whether the gap between chart and streaming is growing or closing
-- Used to support "streaming is leading culture" thesis
-- ────────────────────────────────────────────

WITH yearly_chart AS (
    SELECT
        year,
        segment,
        COUNT(*) AS chart_entries,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY year) AS chart_share_pct
    FROM merged_analysis
    WHERE year BETWEEN 2000 AND 2021
    GROUP BY year, segment
),
yearly_pop AS (
    SELECT
        year,
        segment,
        AVG(popularity) AS avg_popularity,
        SUM(popularity) * 100.0 / SUM(SUM(popularity)) OVER (PARTITION BY year) AS pop_share_pct
    FROM merged_analysis
    WHERE year BETWEEN 2000 AND 2021
    GROUP BY year, segment
)
SELECT
    c.year,
    c.segment,
    c.chart_entries,
    ROUND(c.chart_share_pct, 2)  AS chart_share_pct,
    ROUND(p.pop_share_pct, 2)    AS pop_share_pct,
    ROUND(p.avg_popularity, 2)   AS avg_popularity,
    ROUND(c.chart_share_pct - p.pop_share_pct, 2) AS annual_divergence
FROM yearly_chart c
JOIN yearly_pop p ON c.year = p.year AND c.segment = p.segment
ORDER BY c.segment, c.year;


-- ────────────────────────────────────────────
-- Q6: ARTIST-LEVEL CASE STUDY
-- Tracks with high streaming demand but low/delayed chart recognition
-- This is the "divergence score as A&R tool" proof of concept
-- Criteria:
--   popularity > 70  (strong streaming audience)
--   peak_position > 40  (chart system underranked it)
--   weeks_on_board < 20  (limited chart longevity despite strong streaming)
-- ────────────────────────────────────────────

SELECT
    song,
    artist,
    year,
    popularity,
    peak_position,
    weeks_on_board,
    segment,
    energy,
    danceability,
    valence,
    -- Estimated divergence at the track level
    popularity - (100.0 / NULLIF(peak_position, 0)) AS track_level_gap
FROM merged_analysis
WHERE
    popularity    > 70
    AND peak_position > 40
    AND weeks_on_board < 20
    AND year BETWEEN 2000 AND 2021
ORDER BY popularity DESC
LIMIT 25;


-- ────────────────────────────────────────────
-- Q7: LONGEVITY VS. VIRALITY ANALYSIS
-- Does sustained chart presence or spike popularity predict real audience connection?
-- Segments with high weeks_on_board AND high popularity = durable audiences
-- ────────────────────────────────────────────

SELECT
    segment,
    -- Longevity: tracks with 20+ weeks on chart
    COUNT(CASE WHEN weeks_on_board >= 20 THEN 1 END) AS long_tail_tracks,
    -- Virality: tracks with popularity > 75
    COUNT(CASE WHEN popularity > 75 THEN 1 END)      AS viral_tracks,
    -- Both: durable AND popular
    COUNT(CASE WHEN weeks_on_board >= 20 AND popularity > 75 THEN 1 END) AS durable_viral,
    ROUND(AVG(weeks_on_board), 1)                    AS avg_weeks,
    ROUND(AVG(popularity), 1)                        AS avg_popularity,
    -- Longevity ratio: what % of each segment's tracks are long-tail?
    ROUND(
        COUNT(CASE WHEN weeks_on_board >= 20 THEN 1 END) * 100.0 / COUNT(*), 1
    ) AS longevity_rate_pct
FROM merged_analysis
WHERE year BETWEEN 2000 AND 2021
GROUP BY segment
ORDER BY longevity_rate_pct DESC;


-- ────────────────────────────────────────────
-- Q8: ROCK STRUCTURAL DECLINE — DECADE BREAKDOWN
-- Validates the "real audience shift vs. measurement bias" claim
-- ────────────────────────────────────────────

SELECT
    (year / 10 * 10)::INT AS decade,
    segment,
    COUNT(*) AS chart_entries,
    ROUND(AVG(popularity), 2) AS avg_popularity,
    ROUND(AVG(peak_position), 1) AS avg_peak
FROM merged_analysis
WHERE segment IN ('Rock & Alternative', 'Arena Pop', 'Groove & Flow')
  AND year BETWEEN 2000 AND 2021
GROUP BY 1, 2
ORDER BY segment, decade;


-- ────────────────────────────────────────────
-- Q9: MELANCHOLIC INDIE — STREAMING SURGE TRACKER
-- The "emerging blind spot" finding
-- Chart presence declining while streaming popularity surges = uncaptured audience
-- ────────────────────────────────────────────

SELECT
    year,
    COUNT(*) AS chart_appearances,
    ROUND(AVG(popularity), 2) AS avg_streaming_popularity,
    ROUND(AVG(acousticness), 2) AS avg_acousticness,
    ROUND(AVG(valence), 2) AS avg_valence,
    -- Divergence: how much is streaming outpacing chart presence YOY?
    ROUND(AVG(popularity) - (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 2) AS approx_divergence
FROM merged_analysis
WHERE segment = 'Melancholic Indie'
  AND year BETWEEN 2010 AND 2021
GROUP BY year
ORDER BY year;


-- ────────────────────────────────────────────
-- Q10: STREAMING PARITY INDEX (BILLBOARD RECOMMENDATION)
-- Proposed metric: what would chart rankings look like if weighted by streaming?
-- This is the "product pitch" for Billboard
-- ────────────────────────────────────────────

WITH current_chart AS (
    SELECT
        song,
        artist,
        year,
        chart_position,
        popularity,
        weeks_on_board,
        segment
    FROM merged_analysis
    WHERE year = 2021  -- most recent full year
),
parity_weighted AS (
    SELECT
        song,
        artist,
        year,
        chart_position AS billboard_rank,
        popularity,
        -- Parity-adjusted score: average of chart position (inverted) and popularity
        ROUND(
            (popularity * 0.5) + ((100 - chart_position) * 0.5), 2
        ) AS parity_score,
        -- Simple rank based on parity score
        ROW_NUMBER() OVER (
            PARTITION BY year ORDER BY
            (popularity * 0.5) + ((100 - chart_position) * 0.5) DESC
        ) AS parity_rank,
        segment
    FROM current_chart
)
SELECT
    song,
    artist,
    billboard_rank,
    parity_rank,
    parity_rank - billboard_rank AS rank_shift,
    popularity,
    parity_score,
    segment
FROM parity_weighted
WHERE ABS(parity_rank - billboard_rank) > 5  -- Only show significant shifts
ORDER BY ABS(rank_shift) DESC
LIMIT 20;
-- Tracks with large negative rank_shift = undervalued by current Billboard
-- Tracks with large positive rank_shift = overvalued by current Billboard
