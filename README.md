# Billboard Audience Intelligence

**Measuring the gap between chart performance and streaming behavior (2000–2021)**

---

For over sixty years, Billboard's chart methodology has functioned as the music industry's shared definition of cultural relevance. That methodology was built for radio — a distribution system defined by scarcity, geography, and gatekeeping. Streaming eliminated all three.

This project asks a direct question: in a world where a track can accumulate 50 million plays without a single radio spin, does Billboard still measure what the industry thinks it measures?

The answer, supported by 24,676 matched chart and streaming records, is that it partially does — and where it doesn't, the gap is not random. It's structural, genre-specific, and directionally predictable. That predictability is what makes it useful.

---

## Live Dashboard

**👉 [Explore the interactive Tableau dashboard](https://public.tableau.com/views/BillboardAudienceIntelligenceChartvsStreaming20002021/Dashboard1)**

The dashboard shows divergence scores by segment, year-over-year trend lines, the artist-level undervalued tracks table, and the proposed Streaming Parity Index simulation.

---

## Project Structure

```
billboard-audience-intelligence/
├── notebooks/
│   └── billboard_analysis.py     # Full annotated analysis pipeline
├── sql/
│   └── analysis_queries.sql      # 10 documented SQL queries
├── data/
│   ├── raw/                      # Source CSVs (see Data Sources)
│   └── processed/                # Outputs: merged_analysis.csv, divergence_scores.csv
│                                   #          yearly_trends.csv, undervalued_tracks.csv
└── README.md
```

---

## Research Question

**Which audience segments are overrepresented on Billboard relative to their streaming footprint — and which are being systematically undercounted?**

Secondary questions:
- Does streaming popularity precede chart recognition — and by how much?
- Which specific tracks does the divergence score surface as undervalued by the industry?
- What would Billboard look like with a streaming parity weighting?

---

## Data Sources

| Dataset | Source | Records | Coverage |
|---|---|---|---|
| Billboard Hot 100 | Kaggle (dhruvildave) | 330,087 chart entries | 1958–2021 |
| Spotify Audio Features | Kaggle (maharshipandya) | 113,999 tracks | Multi-era |
| Joined dataset | Inner join on cleaned song + artist | 24,676 entries | 2000–2021 |

### Match Rate & Sample Validation

The inner join on song + artist title produced a **12.89% match rate**. Before drawing conclusions from this sample, three bias checks were run:

**1. Era distribution drift**
Decade-level distributions of the matched sample vs. the full Billboard dataset were compared. Drift values near zero indicate the sample is era-representative. Significant drift in any decade would invalidate temporal trend claims.

**2. Chart performance comparison**
Average peak position of matched vs. unmatched tracks was compared. If matched tracks systematically peak higher, the sample overrepresents commercial hits and underweights catalog/deep cuts — which would inflate the divergence scores of mainstream segments.

**3. Low match rate causes**
The primary driver of the low match rate is Spotify's featured artist naming convention (`Artist A; Artist B`) conflicting with Billboard's `Artist A feat. Artist B` format. Cleaning applied regex normalization for `(feat.)`, `(ft.)`, and `(with ...)` patterns before the join. Residual mismatches are most likely format-level, not content-level.

**Scope statement:** Findings are directional. The divergence scores identify structural patterns in the matched sample. They are not precise market share calculations and should be treated as leading indicators, not definitive measurements.

---

## Methodology

### Audience Segmentation

Seven audience archetypes were defined using Spotify audio feature thresholds and genre classification. Manual rule-based segmentation was chosen over K-Means clustering for two reasons: interpretability (business stakeholders need to act on segments, not explain them) and stability (clustering output shifts with random seed; rules are reproducible).

**Threshold rationale:**

| Segment | Key Rules | Threshold Rationale |
|---|---|---|
| Arena Pop | energy > 0.75, danceability > 0.60 | Validated against known top-40 commercial pop; Katy Perry, Bruno Mars cluster here |
| Groove & Flow | danceability > 0.70, energy ≤ 0.75 | Energy cap separates from Arena Pop; Drake, Post Malone cluster here |
| Rock & Alternative | rock genre family, energy > 0.60 | Genre tag + energy filter removes acoustic rock outliers |
| Viral & Streaming Native | popularity > 70, weeks > 15 | Popularity threshold set at top quartile; weeks filter removes one-week charts |
| Melancholic Indie | acousticness > 0.30, valence < 0.45 | Validated against Phoebe Bridgers, Sufjan Stevens, Bon Iver |
| Electronic & Dance | EDM family, danceability > 0.55 | Genre-led with danceability floor |
| Uptempo Country | genre = country, tempo > 115 BPM | BPM filter excludes ballads from the radio-heavy finding |

**Sensitivity check:** Arena Pop energy threshold was tested at 0.70 vs. 0.75. Segment share shifted from 21.2% to ~24.1% — a modest change that does not alter the directional divergence findings.

**17.2% unclassified:** Tracks not meeting any segment threshold were retained in the dataset but excluded from divergence score calculations to avoid diluting segment-level signals. This is disclosed rather than hidden.

---

### Platform Divergence Score

```
divergence_score = chart_share (%) − popularity_share (%)
```

- **Positive** → Genre overrepresented on Billboard relative to streaming demand
- **Negative** → Genre undervalued by Billboard relative to streaming behavior
- **Near zero** → Aligned — chart presence reflects streaming footprint

Note: Spotify's `popularity` score is a relative, recency-weighted metric — not raw stream counts. It decays for older tracks. This means divergence scores for pre-2015 content may understate actual streaming demand for catalog material. All divergence comparisons are confined to the same time window to minimize this distortion.

---

## What the Data Reveals

### 1. Streaming-Native Music Is Systematically Undercounted

The Viral & Streaming Native segment carries the highest average Spotify popularity (78.68) and the longest average chart tenure (28.62 weeks) of any segment — and yet it shows the strongest negative divergence score.

That is not a measurement quirk. It is evidence that the tracks with the largest sustained audiences are being discounted by a chart system still weighted toward how music gets *distributed*, not how it gets *consumed*. For a label, this is signal: the artists most likely to build durable fanbases are the ones current charts are least likely to surface first.

The practical implication: divergence score functions as a leading indicator. A track with high streaming popularity and low chart rank is not underperforming — it is outpacing the measurement system. See the A&R case study (Section 7) for specific examples.

### 2. Country Is Overrepresented Structurally, Not by Demand

Uptempo Country holds 3.75% of chart entries but only 2.37% of Spotify popularity share — and the lowest average popularity of any segment (41.23). The gap is not closing over time. It reflects radio infrastructure that persists long after the underlying audience demand has been redistributed.

This matters for a media brand like Billboard because it creates a credibility gap: the chart increasingly reflects who has radio access, not who has audience.

### 3. Melancholic Indie Is the Most Underreported Finding in the Industry

This segment's average Spotify popularity rose from 64.51 (2010s) to 76.49 (early 2020s) — a 18.6% increase — while its chart presence dropped significantly over the same period. The audience is there. The measurement system is not looking in the right place.

Artists who fit this profile: Phoebe Bridgers, Olivia Rodrigo pre-breakthrough, Noah Kahan before radio adoption. Each built substantial streaming audiences before chart systems caught up.

This is the segment most likely to produce the next major breakout artist — and the one most likely to be missed by A&R teams relying on charts alone.

### 4. Groove & Flow Shaped the Measurement System

Hip-hop, trap, and R&B is the only segment where chart presence and streaming popularity grew together across every decade window. This segment did not adapt to the streaming era — it *defined* it. The chart system reflects Groove & Flow well not because the methodology is neutral, but because this genre's rise coincided with streaming's rise and forced methodology changes (the 2012 Hot 100 streaming integration, the 2020 on-demand streaming weight increase).

### 5. Rock's Decline Is Audience-Driven, Not Measurement-Driven

Rock & Alternative dropped from 2,760 chart entries in the 2000s to 36 in the early 2020s. Critically, its divergence score is near zero — chart presence and streaming popularity are declining in parallel. This is not a measurement gap story. It is a structural audience shift. Including it in a divergence analysis risks conflating two different phenomena.

---

## Artist-Level Case Study: The Divergence Score as A&R Tool

The divergence score becomes actionable when applied at the track level. The following tracks were flagged by the model as undervalued: Spotify popularity above 70, Billboard peak position above 40, and fewer than 20 weeks on chart.

These are the artists a data-informed A&R team would have identified before the industry consensus caught up.

*[See `data/processed/undervalued_tracks.csv` for the full table and `notebooks/billboard_analysis.py` Section 7 for methodology.]*

**What this means for labels:** A track appearing in this list is not an album cut — it is an audience that already exists and has not been monetized at scale. The divergence score is a prioritization filter, not a guarantee. But in a market where A&R decisions are increasingly made on chart data, this filter surfaces what charts miss.

---

## Time-Lag Analysis: Does Streaming Lead Charts?

Streaming-Native tracks show an average of 28.62 weeks on chart, with the slow-builder subset (peak position > 20, weeks > 20) averaging significantly longer timelines before reaching peak. This suggests a multi-week lag between streaming audience formation and chart recognition.

The approximate lead time — the window during which streaming data signals what charts will eventually reflect — is estimated at **4–8 weeks** for Viral & Streaming Native tracks. This is the actionable window for editorial placement, label investment, and tour routing decisions.

*Note: This is a proxy estimate. A precise lag calculation would require track-level streaming history data, which is not publicly available at the time of this analysis.*

---

## Strategic Implications

### Charts Reward Infrastructure, Not Just Demand

Radio-weighted methodology systematically advantages artists with label infrastructure and radio promotion budgets. This is a business decision embedded in methodology — not a neutral technical choice. For a media brand, it creates exposure to the credibility risk that comes when audiences notice the chart doesn't reflect what they're actually listening to.

### The Divergence Score Is a Product, Not Just a Metric

Billboard's most direct opportunity is not to replace the Hot 100 — it is to publish the divergence score alongside it. A "Streaming Parity Index" column creates a second data product from existing infrastructure, surfaces undercovered artists, and gives DSP editorial teams a tool they would reference weekly. The data to build it already exists.

### Sustained Presence Is the Strongest Signal of Real Audience Connection

Across every segment, tracks with 20+ weeks on chart and popularity above 70 show the most consistent audience retention behavior. Virality (high single-week popularity) does not predict longevity. Longevity predicts catalog value, touring demand, and long-term artist investment returns. This has direct implications for how labels weight short-term chart performance against sustained streaming signals in A&R decisions.

---

## Recommendations

### For Billboard
Publish a **Streaming Parity Index** as a companion metric to the Hot 100. The index (chart_share weighted 50% + streaming_popularity weighted 50%) surfaces tracks where measurement diverges from demand. This is a low-development, high-credibility product that increases data relevance without disrupting the flagship chart. See SQL Query 10 for a prototype implementation.

### For Spotify and DSPs
Build an editorial surface called **"Streaming Before Billboard"** — a curated rail of high-popularity tracks not yet reflected on mainstream charts. The divergence score provides an automated filter. This converts undervalued tracks into editorial moments and gives listeners discovery that is ahead of, not behind, the cultural curve.

### For Labels and A&R Teams
Replace or supplement chart rank as a primary A&R filter with a divergence-weighted score. Specifically: any track where `popularity > 70` and `peak_position > 40` is a candidate for accelerated investment — tour support, sync licensing push, or additional marketing spend. The audience is already there. The chart hasn't caught up yet.

---

## Technical Stack

| Tool | Use |
|---|---|
| Python (pandas) | Data cleaning, join, segmentation, divergence calculation, case study |
| SQL (PostgreSQL) | Aggregation queries, divergence scoring, parity index prototype |
| Tableau Public | Interactive dashboard — segment distribution, divergence trends, undervalued tracks |
| GitHub | Version control, documentation |

**Key files:**
- `notebooks/billboard_analysis.py` — full pipeline with inline comments on every methodological decision
- `sql/analysis_queries.sql` — 10 documented queries including the Streaming Parity Index prototype

---

## What This Analysis Does Not Claim

- The 12.89% match rate makes this a directional study, not a market share calculation
- Spotify popularity is not raw streams — it is a recency-weighted relative score
- Manual segmentation thresholds are defensible but not the only valid choices — sensitivity tests are included
- The time-lag estimate is a proxy; precise lag calculation requires proprietary streaming history data

---

*Analysis by Lyles Mom | Cultural Intelligence & Audience Strategy*
*Portfolio: [lylesmomportfolio.my.canva.site](https://lylesmomportfolio.my.canva.site)*
