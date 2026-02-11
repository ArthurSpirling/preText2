#' @title Remove infrequently occurring terms from quanteda dfm.
#' @description Removes terms appearing in less than a specific proportion of
#' documents in a corpus from a dfm.
#'
#' @param dfm_object A quanteda dfm object.
#' @param proportion_threshold The proportion of documents a term must appear
#' in to be retained. Defaults to 0.01.
#' @param verbose Logical indicating whether to print information. Defaults to
#' TRUE.
#' @return A reduced dfm.
#' @examples
#' \dontrun{
#' library(preText2)
#' data("UK_Manifestos")
#' corp <- quanteda::corpus(UK_Manifestos)
#' toks <- quanteda::tokens(corp, remove_punct = TRUE)
#' my_dfm <- quanteda::dfm(toks)
#' reduced_dfm <- remove_infrequent_terms(my_dfm, 0.05)
#' }
#' @export
remove_infrequent_terms <- function(dfm_object,
                                     proportion_threshold = 0.01,
                                     verbose = TRUE) {

    ndocs <- quanteda::ndoc(dfm_object)
    min_docfreq <- ceiling(proportion_threshold * ndocs)

    if (verbose) {
        cat("Removing terms appearing in fewer than",
            min_docfreq, "of", ndocs, "documents...\n")
    }

    # Use quanteda::dfm_trim which is the modern API
    reduced_dfm <- quanteda::dfm_trim(dfm_object,
                                       min_docfreq = min_docfreq,
                                       docfreq_type = "count")

    if (verbose) {
        cat("Reduced from", quanteda::nfeat(dfm_object), "to",
            quanteda::nfeat(reduced_dfm), "features.\n")
    }

    return(reduced_dfm)
}
