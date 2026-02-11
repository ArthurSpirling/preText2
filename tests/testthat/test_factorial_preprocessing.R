library(testthat)
library(preText2)

test_that("Small example works", {
    # Load inaugural speeches from quanteda
    corp <- quanteda::data_corpus_inaugural

    # Use head() — NOT corp[1:10,] which broke with quanteda v2+
    documents <- head(corp, 10)

    # Extract text as character vector
    doc_texts <- as.character(documents)

    # Run factorial preprocessing with no ngrams (64 combos, faster)
    preprocessed_documents <- factorial_preprocessing(
        doc_texts,
        use_ngrams = FALSE,
        infrequent_term_threshold = 0.01,
        verbose = FALSE)

    # Check output structure
    expect_true(is.list(preprocessed_documents))
    expect_true("choices" %in% names(preprocessed_documents))
    expect_true("dfm_list" %in% names(preprocessed_documents))
    expect_true("labels" %in% names(preprocessed_documents))

    # Should have 64 combinations
    expect_equal(nrow(preprocessed_documents$choices), 64)
    expect_equal(length(preprocessed_documents$dfm_list), 64)
    expect_equal(length(preprocessed_documents$labels), 64)

    # Each element should be a dfm
    expect_true(quanteda::is.dfm(preprocessed_documents$dfm_list[[1]]))

    # Each dfm should have 10 documents
    expect_equal(quanteda::ndoc(preprocessed_documents$dfm_list[[1]]), 10)
})

test_that("Corpus input works", {
    corp <- quanteda::data_corpus_inaugural
    documents <- head(corp, 5)

    preprocessed_documents <- factorial_preprocessing(
        documents,
        use_ngrams = FALSE,
        infrequent_term_threshold = 0.01,
        verbose = FALSE)

    expect_equal(nrow(preprocessed_documents$choices), 64)
    expect_true(quanteda::is.dfm(preprocessed_documents$dfm_list[[1]]))
})

test_that("remove_infrequent_terms works", {
    corp <- quanteda::data_corpus_inaugural
    toks <- quanteda::tokens(head(corp, 10))
    my_dfm <- quanteda::dfm(toks)

    original_features <- quanteda::nfeat(my_dfm)
    reduced <- remove_infrequent_terms(my_dfm, 0.5, verbose = FALSE)

    expect_true(quanteda::is.dfm(reduced))
    expect_true(quanteda::nfeat(reduced) <= original_features)
})
