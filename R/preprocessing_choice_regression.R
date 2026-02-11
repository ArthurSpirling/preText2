#' @title Preprocessing Choice Regressions
#' @description Regresses preText scores on preprocessing choices to determine
#'   which preprocessing steps have the largest effect.
#'
#' @param preText_scores A data.frame with columns \code{labels} and
#'   \code{preText_score}, as returned by \code{preText_test()}.
#' @param choices A data.frame of preprocessing choices, as returned by
#'   \code{factorial_preprocessing()}.
#' @return A data.frame with columns \code{Variable}, \code{Coefficient},
#'   \code{SE}, \code{t_value}, \code{p_value}, \code{CI_lower}, and
#'   \code{CI_upper}.
#' @export
preprocessing_choice_regression <- function(preText_scores, choices) {

    # remove the baseline (score == 0 or NA)
    valid <- !is.na(preText_scores$preText_score) & preText_scores$preText_score != 0
    scores <- preText_scores$preText_score[valid]
    X <- choices[valid, ]

    # convert logical to numeric
    for (j in 1:ncol(X)) {
        X[, j] <- as.numeric(X[, j])
    }

    # run regression
    dat <- cbind(data.frame(score = scores), X)
    fit <- stats::lm(score ~ ., data = dat)
    s <- summary(fit)
    coefs <- s$coefficients

    results <- data.frame(
        Variable = rownames(coefs),
        Coefficient = coefs[, 1],
        SE = coefs[, 2],
        t_value = coefs[, 3],
        p_value = coefs[, 4],
        CI_lower = coefs[, 1] - 1.96 * coefs[, 2],
        CI_upper = coefs[, 1] + 1.96 * coefs[, 2],
        stringsAsFactors = FALSE
    )
    rownames(results) <- NULL

    return(results)
}
