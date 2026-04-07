# Billboard Audience Intelligence
### Measuring the gap between chart performance and streaming behavior (2000–2021)

---

## Overview

Billboard has defined what a “hit” means for decades.

But in the streaming era, attention doesn’t move the same way—and charts don’t always capture it.

This project analyzes Billboard chart performance against Spotify listening behavior to identify where **measurement diverges from reality**.

The goal isn’t to rank songs.

It’s to understand:
> what actually drives attention,  
> what sustains it,  
> and where the industry is misreading it.

This is not a chart analysis.

It’s an audience intelligence system.

---

## Project Brief

Billboard's Hot 100 has defined what a "hit" means in American music for over 60 years.  
But as streaming fragmented music consumption across platforms, a key question emerged:

**Does Billboard still reflect how people actually listen?**

This project segments modern music audiences by audio feature behavior, then maps
those segments against Billboard chart performance and Spotify popularity data to
identify where mainstream measurement diverges from lived listening behavior —
and what that gap means for artists, labels, and media brands.

**Primary research question:**
Which audience segments are overrepresented on Billboard relative to their
streaming footprint — and which are being systematically undercounted?

---

## Data Sources

| Dataset | Source | Records | Coverage |
|---|---|---|---|
| Billboard Hot 100 | Kaggle (dhruvildave) | 330,087 chart entries | 1958–2021 |
| Spotify Audio Features | Kaggle (maharshipandya) | 113,999 tracks | Multi-era |
| Joined dataset | Inner join on song + artist | 24,676 entries | 2000–2021 |

**Match rate:** 12.89% of Billboard entries matched to Spotify audio features.  
Analysis is scoped to 2000–2021 where streaming data is most relevant.

---

## Methodology

### Audience Segmentation

Seven audience archetypes were defined using audio feature thresholds and genre classification.

Manual segmentation was chosen over clustering to ensure interpretability and business usability.

| Segment | Definition | Share |
|---|---|---|
| Arena Pop | energy > 0.75, danceability > 0.60 | 21.2% |
| Groove & Flow | danceability > 0.70, energy ≤ 0.75 | 19.0% |
| Rock & Alternative | rock genre family, energy > 0.60 | 14.2% |
| Viral & Streaming Native | popularity > 70, weeks > 15 | 12.6% |
| Melancholic Indie | acousticness > 0.30, valence < 0.45 | 8.7% |
| Electronic & Dance | EDM family, danceability > 0.55 | 4.0% |
| Uptempo Country | genre = country, tempo > 115 BPM | 3.1% |
| Unclassified | No dominant signal | 17.2% |

---

### Platform Divergence Score
divergence_score = chart_share (%) − popularity_share (%)

- Positive → Overrepresented on Billboard  
- Negative → Undervalued relative to streaming behavior  

---

## What the Data Reveals

### 1. Billboard Overweights Country Relative to Actual Demand

Uptempo Country holds 3.75% of chart entries but only 2.37% of Spotify popularity share.

Despite having the lowest average popularity (41.23), it consistently occupies more chart space than audience demand justifies.

This reflects a structural bias toward radio airplay rather than listener-driven consumption.

---

### 2. Streaming-Native Music is Systematically Undercounted

The Viral & Streaming Native segment has the highest average popularity (78.68) and longest chart tenure (28.62 weeks), yet shows the strongest underrepresentation.

Tracks built through streaming ecosystems are not receiving proportional chart recognition.

---

### 3. Rock Has Structurally Declined

Rock & Alternative dropped from:
- 2,760 entries (2000s)  
- 705 entries (2010s)  
- 36 entries (2020s)  

This reflects a real audience shift—not just measurement bias.

---

### 4. Groove & Flow is Perfectly Aligned with the System

This segment (trap, R&B, hip-hop) is the only one where chart presence and streaming popularity grow together.

It represents the genre that shaped—and benefits from—the streaming era.

---

### 5. Melancholic Indie is an Emerging Blind Spot

Streaming popularity surged from 64.51 → 76.49, while chart presence dropped significantly.

This indicates a growing audience that is not being captured by traditional chart systems.

---

## So What? (Strategic Implications)

This analysis reveals a gap between **how attention is measured** and **how it actually behaves**.

### Charts reward infrastructure, not just demand
Radio-heavy genres continue to outperform due to legacy systems.

### Streaming is leading culture
High-popularity, low-chart segments signal where culture is moving first.

### Longevity > virality
Sustained presence is the strongest indicator of real audience connection.

---

## Strategic Recommendations

### For Billboard
Introduce a **streaming parity index** alongside chart rankings.

This would:
- expose measurement gaps
- increase credibility
- create a monetizable data product

---

### For Spotify / DSPs
Build editorial surfaces for:
> “Streaming Before Billboard”

Highlight high-performing tracks not yet reflected on charts.

---

### For Labels & A&R
Use divergence scores as a **leading indicator of undervalued talent**.

Focus investment on segments where:
- streaming demand is strong
- chart recognition lags

---

## Dashboard

**Tableau Dashboard:**  
https://public.tableau.com/views/BillboardAudienceIntelligenceChartvsStreaming20002021/Dashboard1

---

## Technical Stack

- Python (pandas)
- SQL
- Tableau
- GitHub

---

## Why This Matters

Charts are often treated as outcomes.

But they are actually **signals shaped by systems**.

Understanding those systems allows brands to move from:
> reacting to culture → shaping it

---

*Analysis by Lyles Mom | Cultural Intelligence & Audience Strategy*
