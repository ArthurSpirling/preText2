# preText2

An updated R package to assess the consequences of text preprocessing decisions, compatible with **quanteda v4+**.

This is a (semi) maintained fork of the original [preText](https://github.com/matthewjdenny/preText) package by Matthew J. Denny and Arthur Spirling. The original was archived from CRAN in 2020 due to breaking changes in quanteda v2+.

### Notes 

From **Arthur Spirling**: I vibe-coded everything here, as a proof of concept in ~15 minutes in mid-Feb 2026 using Claude Opus. It worked better than expected. I am unrepetant.

**Feb 23, 2026**: started checking the functions more carefully, by comparing with past results.  There was an error, where Claude has mistranslated an earlier function.  That's fixed now and the results from the main "Inaugural Addresses" example should be very similar to the ones from the original `preText`, differing (I think!) only due to some updates in `quanteda` in terms of the exact way it preprocesses. 


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

## Vignette

There is a vignette for getting started [here](vignettes/getting_started_with_preText2.md)


## What changed from the original preText?

- Rewrote `factorial_preprocessing()` to use the modern quanteda `tokens() |> dfm()` pipeline (the old `dfm(corpus, stem=TRUE, ...)` API was removed in quanteda v4).
- Fixed the corpus subsetting bug (`corp[1:10,]` → `head(corp, 10)`).
- Fixed the `is.character()` parenthesis bug.
- Replaced deprecated quanteda internals (`text$documents$texts`, `nfeature()`, etc.).
- `wordfish_comparison()` now requires the separate `quanteda.textmodels` package.
- Uses `dfm_trim()` for infrequent term removal.

### Comparing the versions (examples)

I was able to get very similar results (i.e. replication) to the original vignette example of the Inaugural Speeches.  The relevant code is

```
# load in U.S. presidential inaugural speeches from Quanteda example data.
corp <- data_corpus_inaugural
# use first 10 documents for example
documents <- corp[1:10,]
# take a look at the document names
print(names(documents))

preprocessed_documents <- factorial_preprocessing(
    documents,
    use_ngrams = TRUE,
    infrequent_term_threshold = 0.2,
    verbose = FALSE)

preText_results <- preText(
    preprocessed_documents,
    dataset_name = "Inaugural Speeches",
    distance_method = "cosine",
    num_comparisons = 20,
    verbose = FALSE)
```

In the original `preText` this yielded: 

```
## Generating document distances...
## Generating preText Scores...
## Generating regression results..
## Regression results (negative coefficients imply less risk):
##                  Variable Coefficient    SE
## 1               Intercept       0.117 0.004
## 2      Remove Punctuation       0.020 0.003
## 3          Remove Numbers       0.001 0.003
## 4               Lowercase      -0.010 0.003
## 5                Stemming      -0.004 0.003
## 6        Remove Stopwords      -0.022 0.003
## 7 Remove Infrequent Terms       0.000 0.003
## 8              Use NGrams      -0.028 0.003
## Complete in: 12.859 seconds...
```
In `pretext2` this yields

```
Generating document distances...
Generating preText Scores...
Generating regression results..
Regression results (negative coefficients imply less risk):
                 Variable Coefficient    SE
1               Intercept       0.112 0.006
2      Remove Punctuation       0.020 0.004
3          Remove Numbers       0.002 0.004
4               Lowercase       0.000 0.004
5                Stemming      -0.002 0.004
6        Remove Stopwords      -0.033 0.004
7 Remove Infrequent Terms      -0.010 0.004
8              Use NGrams      -0.025 0.004
Complete in: 11.2 seconds...
```
This seems close enough to me. 


## Bug Reporting

Please report bugs via [GitHub Issues](https://github.com/ArthurSpirling/preText2/issues).
