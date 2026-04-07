# Billboard Audience Intelligence
### Measuring the gap between chart performance and streaming behavior (2000–2021)

---

## Project brief

Billboard's Hot 100 has defined what a "hit" means in American music for over 60 years.
But as streaming fragmented music consumption across platforms, a question emerged:
does Billboard still reflect how people actually listen?

This project segments modern music audiences by audio feature behavior, then maps
those segments against Billboard chart performance and Spotify popularity data to
identify where mainstream measurement diverges from lived listening behavior —
and what that gap means for artists, labels, and media brands.

**Primary research question:**
Which audience segments are overrepresented on Billboard relative to their
streaming footprint — and which are being systematically undercounted?

---

## Data sources

| Dataset | Source | Records | Coverage |
|---|---|---|---|
| Billboard Hot 100 | Kaggle (dhruvildave) | 330,087 chart entries | 1958–2021 |
| Spotify Audio Features | Kaggle (maharshipandya) | 113,999 tracks | Multi-era |
| Joined analysis dataset | Inner join on song + artist | 24,676 entries | 2000–2021 |

**Match rate:** 12.89% of Billboard entries matched to Spotify audio features.
Unmatched entries are concentrated in pre-2000 decades where Spotify catalog
coverage is limited. The analysis is intentionally scoped to 2000–2021, where
platform behavior data is most relevant to the research question.

**Data availability:** Raw and processed data files are not included in this
repository due to file size constraints. Source datasets are available at:
- Billboard Hot 100: https://www.kaggle.com/datasets/dhruvildave/billboard-the-hot-100-songs
- Spotify Audio Features: https://www.kaggle.com/datasets/maharshipandya/-spotify-tracks-dataset

---

## Methodology

### Audience segmentation
Seven audience archetypes were defined using explicit audio feature thresholds
and genre classifications applied to Spotify's track-level data. Manual threshold
segmentation was chosen over unsupervised clustering to produce interpretable,
business-explainable segments. A productionized version would validate these
thresholds using k-means clustering.

| Segment | Definition | Share |
|---|---|---|
| Arena Pop | energy > 0.75, danceability > 0.60 | 21.2% |
| Groove & Flow | danceability > 0.70, energy ≤ 0.75 | 19.0% |
| Rock & Alternative | rock genre family, energy > 0.60 | 14.2% |
| Viral & Streaming Native | popularity > 70, weeks on board > 15 | 12.6% |
| Melancholic Indie | acousticness > 0.30, valence < 0.45 | 8.7% |
| Electronic & Dance | EDM genre family, danceability > 0.55 | 4.0% |
| Uptempo Country | genre = country, tempo > 115 BPM | 3.1% |
| Unclassified | No dominant signal | 17.2% |

17.2% of entries remained unclassified, reflecting tracks with undifferentiated
sonic profiles. These were excluded from divergence analysis to preserve
segment integrity.

### Platform divergence scoring
A divergence score was calculated per segment as:

```
divergence_score = chart_share (%) − popularity_share (%)
```

A positive score indicates overrepresentation on Billboard relative to streaming.
A negative score indicates underrepresentation.

---

## Key findings

### Finding 1 — Uptempo Country is Billboard's most overrepresented segment
Country holds 3.75% of chart entries but only 2.37% of Spotify popularity share,
producing a divergence score of +1.38. With an average Spotify popularity of 41.23
— the lowest of any segment — country consistently occupies more chart real estate
than its streaming audience justifies. This reflects Billboard's historical weighting
toward radio airplay, where country remains dominant.

### Finding 2 — Streaming-native tracks are systematically undercounted
The Viral & Streaming Native segment carries the highest average Spotify popularity
(78.68) and the longest average chart tenure (28.62 weeks), yet produces a divergence
score of -3.11 — the most underrepresented segment in the analysis. Tracks that build
momentum through streaming and playlisting are not receiving proportional chart
recognition under current methodology.

### Finding 3 — Rock effectively exited the charts across three decades
Rock & Alternative produced 2,760 chart entries in the 2000s, 705 in the 2010s,
and just 36 in the 2020s. Its average chart rank in the 2020s is 72.89 — barely
charting. This is not a streaming underrepresentation story; rock's Spotify popularity
also declined. It represents a genuine audience shift away from the genre entirely.

### Finding 4 — Groove & Flow is the only segment where Billboard and streaming aligned
Across all three decades, Groove & Flow (trap, R&B, groove-driven hip-hop) grew in
both chart presence and Spotify popularity simultaneously. It is the only segment
where the measurement infrastructure kept pace with audience behavior — likely
because this genre drove the streaming era's growth from its origin.

### Finding 5 — Melancholic Indie is an emerging underrepresentation story
Melancholic Indie's average Spotify popularity surged from 64.51 in the 2010s to
76.49 in the 2020s — an 18.5% increase — while chart entries fell from 1,386 to 334.
Bedroom pop and singer-songwriter acts are building genuine streaming audiences that
Billboard's current methodology is not capturing.

---

## Strategic recommendations

### For Billboard
**Recommendation: Introduce a streaming-weight adjustment to the Hot 100 formula**

The current divergence between chart share and popularity share is measurable and
consistent across multiple segments. A transparency-first approach would publish
a supplemental "streaming parity index" alongside weekly chart rankings — showing
readers where the Hot 100 diverges from platform behavior. This positions Billboard
as analytically credible rather than methodologically static, and creates a new
editorial product with monetization potential for data licensing partnerships.

### For Spotify / DSPs
**Recommendation: Build segment-aware playlist sequencing for underrepresented genres**

Melancholic Indie and Viral & Streaming Native both show strong and growing
streaming popularity with weak chart correlation. This signals an audience that
is being served by streaming but not validated by mainstream media. A dedicated
editorial surface — "Charting Soon" or "Streaming Before Billboard" — that
surfaces high-popularity, low-chart-rank tracks would serve this audience
directly and generate a defensible first-mover position in trend discovery.

### For Labels and A&R teams
**Recommendation: Use divergence scores as a leading indicator for artist investment**

Segments with negative divergence scores — where streaming popularity outpaces
chart recognition — represent artists whose commercial potential is being
undervalued by traditional metrics. A&R teams should incorporate platform
divergence analysis into artist evaluation frameworks, particularly for
Melancholic Indie and streaming-native acts, where audience momentum is
demonstrably ahead of mainstream measurement.

---

## Limitations and next steps

**Limitations**
- 12.89% match rate limits generalizability; findings are most reliable for
  the post-2010 streaming era where Spotify catalog coverage is strongest
- Manual segmentation thresholds reflect analytical judgment, not empirical
  optimization; k-means validation is recommended before operationalizing
- Spotify popularity scores are not timestamped — current scores may not
  reflect popularity at time of charting, particularly for older tracks
- Genre taxonomy in the Spotify dataset reflects platform classification,
  not audience self-identification, and contains known inconsistencies
  (e.g. grunge tags on post-2000 artists)

**Next steps**
- Validate segment thresholds using k-means clustering (Python / scikit-learn)
- Incorporate Apple Music and YouTube data to build a true cross-platform
  divergence model
- Extend analysis to include TikTok virality signals as a leading indicator
- Build a real-time version using the Spotify and Billboard APIs

---

## Technical stack

| Layer | Tool |
|---|---|
| Data acquisition | Kaggle |
| Cleaning and analysis | Python (pandas) |
| Visualization | Tableau Public |
| Version control | GitHub |

**Dashboard:** https://public.tableau.com/views/BillboardAudienceIntelligenceChartvsStreaming20002021/Dashboard1

**Repository:** https://github.com/llyles97-cmyk/billboard-audience-intelligence

## Repository structure

```
billboard-audience-intelligence/
├── data/
│   ├── billboard_clean.csv
│   ├── spotify_clean.csv
│   ├── billboard_segmented.csv
│   ├── divergence_scores.csv
│   └── decade_divergence.csv
├── notebooks/
│   └── analysis.ipynb
├── viz/
│   └── [Tableau workbook]
└── README.md
```

---

*Analysis by Lyles Mom | Audience Intelligence & Personalization Strategist*  
*Data: Kaggle (dhruvildave, maharshipandya) | Tools: Python, Tableau*
