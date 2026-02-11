Getting Started with preText2
================

## Introduction

**preText2** is an updated fork of the original **preText** package,
compatible with **quanteda v4+**. It preprocesses text 64-128 different
ways and assesses how robust your findings are to preprocessing choices.

- Matthew J. Denny, and Arthur Spirling (2018). “Text Preprocessing For
  Unsupervised Learning: Why It Matters, When It Misleads, And What To
  Do About It”. *Political Analysis*, 26(2), 168-189.
  [doi:10.1017/pan.2017.44](https://doi.org/10.1017/pan.2017.44)

## Installation

``` r
devtools::install_github("ArthurSpirling/preText2")
```

## Example: Inaugural Speeches

`data_corpus_inaugural` ships with quanteda — no extra packages needed.

``` r
library(preText2)
library(quanteda)

corp <- data_corpus_inaugural
documents <- as.character(corpus_subset(corp, Year > 1980))

preprocessed_documents <- factorial_preprocessing(
    documents,
    use_ngrams = FALSE,
    infrequent_term_threshold = 0.02,
    verbose = TRUE)

preText_results <- preText(
    preprocessed_documents,
    dataset_name = "Inaugural Speeches",
    distance_method = "cosine",
    num_comparisons = 20,
    verbose = FALSE)

preText_score_plot(preText_results)
regression_coefficient_plot(preText_results, remove_intercept = TRUE)
```

## Example: UK Manifestos

The UK manifestos data is available from the `quanteda.corpora` package:

``` r
# install.packages("devtools")
# devtools::install_github("quanteda/quanteda.corpora")
library(quanteda.corpora)

docs <- as.character(data_corpus_ukmanifestos)

preprocessed_documents <- factorial_preprocessing(
    docs,
    use_ngrams = FALSE,
    infrequent_term_threshold = 0.02,
    verbose = TRUE)

preText_results <- preText(
    preprocessed_documents,
    dataset_name = "UK Manifestos",
    num_comparisons = 50)

preText_score_plot(preText_results)
regression_coefficient_plot(preText_results, remove_intercept = TRUE)
```

## Interpretation

The **preText score plot** shows each preprocessing specification
ordered from most to least “unusual”. Higher scores mean that
specification produces results that differ more from the consensus.

The **regression coefficient plot** shows which individual preprocessing
decisions have the largest effects. Steps with coefficients far from
zero are the ones that matter most for your corpus.

Our general advice: select a preprocessing specification motivated by
theory, then for steps with significant coefficients, replicate your
analysis across combinations of those steps.

## Changes from preText

- Uses the modern `tokens() |> dfm()` pipeline (quanteda v4+)
- Fixes the corpus subsetting bug and `is.character()` parenthesis bug
- Uses `dfm_trim()` for infrequent term removal
- `wordfish_comparison()` now requires `quanteda.textmodels`
- UK Manifestos data now accessed via `quanteda.corpora` instead of
  bundled
