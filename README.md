# preText2

An updated R package to assess the consequences of text preprocessing decisions, compatible with **quanteda v4+**.

This is a (semi) maintained fork of the original [preText](https://github.com/matthewjdenny/preText) package by Matthew J. Denny and Arthur Spirling. The original was archived from CRAN in 2020 due to breaking changes in quanteda v2+.

(note from **Arthur Spirling**: I vibe-coded everything here, as a proof of concept in ~15 minutes in Feb 2026 use Claude Opus. It worked better than expected. I am unrepetant.)

## Paper

Matthew J. Denny, and Arthur Spirling (2018). "Text Preprocessing For Unsupervised Learning: Why It Matters, When It Misleads, And What To Do About It". *Political Analysis*, 26(2), 168-189. [[doi:10.1017/pan.2017.44]](https://doi.org/10.1017/pan.2017.44)

## Installation

```r
# install.packages("devtools")
devtools::install_github("ArthurSpirling/preText2")
```

## Quick Start

```r
library(preText2)
library(quanteda)

# Load example data
corp <- data_corpus_inaugural
documents <- as.character(corpus_subset(corp, Year > 1980))

# Preprocess 64 different ways
preprocessed <- factorial_preprocessing(
    documents,
    use_ngrams = FALSE,
    infrequent_term_threshold = 0.02,
    verbose = TRUE)

# Run preText
results <- preText(preprocessed,
                   dataset_name = "Inaugural Speeches",
                   num_comparisons = 20)

# Visualize
preText_score_plot(results)
regression_coefficient_plot(results, remove_intercept = TRUE)
```

## What changed from the original preText?

- Rewrote `factorial_preprocessing()` to use the modern quanteda `tokens() |> dfm()` pipeline (the old `dfm(corpus, stem=TRUE, ...)` API was removed in quanteda v4).
- Fixed the corpus subsetting bug (`corp[1:10,]` → `head(corp, 10)`).
- Fixed the `is.character()` parenthesis bug.
- Replaced deprecated quanteda internals (`text$documents$texts`, `nfeature()`, etc.).
- `wordfish_comparison()` now requires the separate `quanteda.textmodels` package.
- Uses `dfm_trim()` for infrequent term removal.

## Bug Reporting

Please report bugs via [GitHub Issues](https://github.com/ArthurSpirling/preText2/issues).
