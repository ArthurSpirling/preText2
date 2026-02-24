#' @title A function to perform factorial preprocessing of a corpus of texts
#' into quanteda document-frequency matrices.
#' @description Preprocesses a corpus of texts into a document-frequency matrix
#' in 64 or 128 different ways (depending on whether n-grams are included),
#' using the modern quanteda (v4+) tokens-based pipeline.
#'
#' @param text A vector of strings (one per document) or quanteda
#'     corpus object from which we wish to form a document-term matrix.
#' @param use_ngrams Option to include 1,2, and 3-grams as another potential
#'     preprocessing step. Defaults to TRUE (128 combinations). Set to FALSE
#'     for 64 combinations.
#' @param infrequent_term_threshold A proportion threshold at which
#'     infrequent terms are to be filtered. Defaults to 0.01 (terms
#'     that appear in less than 1 percent of documents).
#' @param language Language passed to quanteda for stopword removal and stemming.
#'     Defaults to \"english\" to mirror the original preText behavior.
#' @param parallel Logical indicating whether factorial preprocessing
#'     should be performed in parallel. Defaults to FALSE.
#' @param cores Defaults to 1, can be set to any number less than or
#'     equal to the number of cores on one's computer.
#' @param intermediate_directory Optional path to a directory where
#'     each dfm will be saved as an intermediate step.
#' @param parameterization_range Defaults to NULL, but can be set to a
#'     numeric vector of indexes relating to preprocessing
#'     decisions. This can be used to restart large analyses after
#'     power failure.
#' @param return_results Defaults to TRUE, can be set to FALSE to
#'     prevent an overly large dfm list from being created.
#' @param verbose Logical indicating whether more information should
#'     be printed to the screen to let the user know about progress in
#'     preprocessing. Defaults to TRUE.
#' @return A list object with three elements:
#' \itemize{
#'   \item \code{choices}: a data.frame of preprocessing specifications
#'   \item \code{dfm_list}: a list of quanteda dfm objects
#'   \item \code{labels}: character vector of labels for each specification
#' }
#' @examples
#' \dontrun{
#' library(preText2)
#' library(quanteda)
#' docs <- as.character(head(data_corpus_inaugural, 20))
#' preprocessed_documents <- factorial_preprocessing(
#'     docs,
#'     use_ngrams = FALSE,
#'     infrequent_term_threshold = 0.02,
#'     verbose = TRUE)
#' }
#' @export
factorial_preprocessing <- function(text,
                                    use_ngrams = TRUE,
                                    infrequent_term_threshold = 0.01,
                                    language = "english",
                                    parallel = FALSE,
                                    cores = 1,
                                    intermediate_directory = NULL,
                                    parameterization_range = NULL,
                                    return_results = TRUE,
                                    verbose = TRUE) {

    # set some intermediate variables
    cur_directory <- getwd()

    # set working directory if given
    if (!is.null(intermediate_directory)) {
        setwd(intermediate_directory)
    } else {
        intermediate_directory <- cur_directory
    }

    # Ensure on.exit restores directory even if function errors
    on.exit(setwd(cur_directory), add = TRUE)

    # Check input: accept character vector or quanteda corpus
    if (is.character(text) && !quanteda::is.corpus(text)) {
        text <- quanteda::corpus(text)
    }
    if (!quanteda::is.corpus(text)) {
  stop("You must provide either a character vector of strings (one per document) or a quanteda corpus object.")
}

    ndocs <- quanteda::ndoc(text)

    # Create a data.frame with factorial combinations of all choices.
    if (use_ngrams) {
        cat("Preprocessing", ndocs, "documents 128 different ways...\n")
        choices <- data.frame(expand.grid(list(
            removePunctuation = c(TRUE, FALSE),
            removeNumbers = c(TRUE, FALSE),
            lowercase = c(TRUE, FALSE),
            stem = c(TRUE, FALSE),
            removeStopwords = c(TRUE, FALSE),
            infrequent_terms = c(TRUE, FALSE),
            use_ngrams = c(TRUE, FALSE))))
    } else {
        cat("Preprocessing", ndocs, "documents 64 different ways...\n")
        choices <- data.frame(expand.grid(list(
            removePunctuation = c(TRUE, FALSE),
            removeNumbers = c(TRUE, FALSE),
            lowercase = c(TRUE, FALSE),
            stem = c(TRUE, FALSE),
            removeStopwords = c(TRUE, FALSE),
            infrequent_terms = c(TRUE, FALSE),
            use_ngrams = c(FALSE))))
    }

    # Generate labels
    labs <- c("P", "N", "L", "S", "W", "I", "3")
    labels <- rep("", nrow(choices))
    for (i in seq_len(nrow(choices))) {
        str <- ""
        for (j in 1:7) {
            if (choices[i, j]) {
                if (str == "") {
                    str <- labs[j]
                } else {
                    str <- paste(str, labs[j], sep = "-")
                }
            }
        }
        labels[i] <- str
    }

    # Create a list to store dfm's
    dfm_list <- vector(mode = "list", length = nrow(choices))

    # Determine which rows to process
    rows_to_preprocess <- seq_len(nrow(choices))
    if (!is.null(parameterization_range)) {
        rows_to_preprocess <- parameterization_range
    }

    if (parallel) {
        cat("Preprocessing documents", length(rows_to_preprocess),
            "different ways on", cores, "cores. This may take a while...\n")
        cl <- parallel::makeCluster(getOption("cl.cores", cores))

        dfm_list <- parallel::clusterApplyLB(
            cl = cl,
            x = rows_to_preprocess,
            fun = function(i, choices, text, infrequent_term_threshold,
                           language,
                           intermediate_directory) {
                current_dfm <- preText2:::build_dfm(
                    text = text,
                    choices = choices[i, ],
                    infrequent_term_threshold = infrequent_term_threshold,
                    language = language,
                    verbose = FALSE)
                if (!is.null(intermediate_directory)) {
                    save(current_dfm,
                         file = paste0(intermediate_directory,
                                       "/intermediate_dfm_", i, ".Rdata"))
                }
                return(current_dfm)
            },
            choices = choices,
            text = text,
            infrequent_term_threshold = infrequent_term_threshold,
            language = language,
            intermediate_directory = intermediate_directory)

        parallel::stopCluster(cl)
    } else {
        for (i in rows_to_preprocess) {
            if (verbose) {
                cat("Currently working on combination", i, "of",
                    nrow(choices), "\n")
            }

            current_dfm <- build_dfm(
                text = text,
                choices = choices[i, ],
                infrequent_term_threshold = infrequent_term_threshold,
                language = language,
                verbose = verbose)

            if (!is.null(intermediate_directory)) {
                save(current_dfm,
                     file = paste0(intermediate_directory,
                                   "/intermediate_dfm_", i, ".Rdata"))
            }

            dfm_list[[i]] <- current_dfm
        }
    }

    # If returning results from parallel, read in intermediate dfms
    if (return_results && parallel && !is.null(intermediate_directory)) {
        cat("Preprocessing complete, loading in intermediate DFMs...\n")
        dfm_list <- vector(mode = "list", length = nrow(choices))
        for (i in seq_along(dfm_list)) {
            load(paste0(intermediate_directory,
                        "/intermediate_dfm_", i, ".Rdata"))
            dfm_list[[i]] <- current_dfm
        }
    }

    names(dfm_list) <- labels
    rownames(choices) <- labels

    return(list(choices = choices,
                dfm_list = dfm_list,
                labels = labels))
}


#' Build a single DFM from a corpus using the modern quanteda pipeline
#'
#' Internal function that constructs a single document-feature matrix
#' from a quanteda corpus given a row of preprocessing choices. Uses
#' the quanteda v4+ tokens-first workflow.
#'
#' @param text A quanteda corpus object.
#' @param choices A single-row data.frame of preprocessing choices.
#' @param infrequent_term_threshold Proportion threshold for filtering
#'     infrequent terms.
#' @param verbose Logical for printing progress.
#' @return A quanteda dfm object.
#' @keywords internal
build_dfm <- function(text,
                      choices,
                      infrequent_term_threshold,
                      language = "english",
                      verbose = FALSE) {

    padding <- isTRUE(choices$use_ngrams)

    # Step 1: Tokenize
    toks <- quanteda::tokens(
        text,
        remove_punct   = choices$removePunctuation,
        remove_numbers = choices$removeNumbers,
        padding        = padding
    )

    # Step 2: Lowercase BEFORE stemming (important!)
    if (choices$lowercase) {
        toks <- quanteda::tokens_tolower(toks, keep_acronyms = FALSE)
    }

    # Step 3: Stem
    if (choices$stem) {
        toks <- quanteda::tokens_wordstem(toks, language = language)
    }

    # Step 4: N-grams
    if (choices$use_ngrams) {
        toks <- quanteda::tokens_ngrams(toks, n = 1:3)
    }

    # Step 5: Build DFM
    current_dfm <- quanteda::dfm(toks)

    # Step 6: Remove stopwords at the DFM stage (keep this)
    if (choices$removeStopwords) {
        current_dfm <- quanteda::dfm_remove(
            current_dfm,
            pattern = quanteda::stopwords(language = language)
        )
    }

    # Step 7: Remove infrequent terms
    if (choices$infrequent_terms) {
        current_dfm <- remove_infrequent_terms(
            dfm_object = current_dfm,
            proportion_threshold = infrequent_term_threshold,
            verbose = verbose
        )
    }

    return(current_dfm)
}