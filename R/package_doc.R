#' preText2: Diagnostics to Assess the Effects of Text Preprocessing Decisions
#'
#' An updated fork of the preText package, compatible with quanteda v4+.
#' Functions to assess the effects of different text preprocessing decisions
#' on the inferences drawn from the resulting document-term matrices.
#'
#' The main functions are:
#' \itemize{
#'   \item \code{\link{factorial_preprocessing}}: Preprocess text 64 or 128 ways
#'   \item \code{\link{preText}}: Run the full preText procedure
#'   \item \code{\link{preText_score_plot}}: Plot preText scores
#'   \item \code{\link{regression_coefficient_plot}}: Plot regression coefficients
#' }
#'
#' @references
#' Matthew J. Denny, and Arthur Spirling (2018). "Text Preprocessing For
#' Unsupervised Learning: Why It Matters, When It Misleads, And What To Do
#' About It". Political Analysis, 26(2), 168-189.
#' \doi{10.1017/pan.2017.44}
#'
#' @docType package
#' @name preText2-package
#' @aliases preText2
"_PACKAGE"


#' Full text of 69 UK party manifestos from 1918-2001.
#'
#' A character vector containing 69 entries, one per document, for all
#' major party manifestos in the UK from 1918 to 2001.
#'
#' @docType data
#' @keywords datasets
#' @name UK_Manifestos
#' @usage data(UK_Manifestos)
#' @format A character vector of length 69.
NULL
