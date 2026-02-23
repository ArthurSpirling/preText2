#' @title Preprocessing Choice Regressions
#' @description Regresses preText scores on preprocessing choices to
#' determine which preprocessing decisions have the largest effects.
#'
#' @param Y A numeric vector of preText scores.
#' @param choices A data.frame of preprocessing choices from
#' \code{factorial_preprocessing()}.
#' @param dataset A string name for the dataset. Defaults to "Documents".
#' @param base_case_index The index of the base case (no preprocessing) to
#' exclude from the regression. Defaults to NULL.
#' @return A data.frame with columns Coefficient, SE, and Variable.
#' @examples
#' \dontrun{
#' # This function is typically called inside preText().
#' }
#' @export
preprocessing_choice_regression <- function(Y,
                                             choices,
                                             dataset = "Documents",
                                             base_case_index = NULL) {

    # Remove base case if specified
    if (!is.null(base_case_index)) {
        choices <- choices[-base_case_index, ]
    }

    # Convert logical columns to numeric (0/1)
    for (j in 1:ncol(choices)) {
        choices[, j] <- as.numeric(choices[, j])
    }

    # Build nice variable names
    variable_names <- c("Intercept",
                        "Remove Punctuation",
                        "Remove Numbers",
                        "Lowercase",
                        "Stemming",
                        "Remove Stopwords",
                        "Remove Infrequent Terms",
                        "Use NGrams")

    # Only include variables that are actually in the choices
    col_names <- colnames(choices)
    included_vars <- c("Intercept")
    formula_terms <- c()

    var_map <- list(
        removePunctuation = "Remove Punctuation",
        removeNumbers = "Remove Numbers",
        lowercase = "Lowercase",
        stem = "Stemming",
        removeStopwords = "Remove Stopwords",
        infrequent_terms = "Remove Infrequent Terms",
        use_ngrams = "Use NGrams"
    )

    for (cn in col_names) {
        if (cn %in% names(var_map)) {
            # Only include if there is variation
            if (length(unique(choices[, cn])) > 1) {
                formula_terms <- c(formula_terms, cn)
                included_vars <- c(included_vars, var_map[[cn]])
            }
        }
    }

    # Build regression data
    reg_data <- data.frame(Y = Y)
    for (ft in formula_terms) {
        reg_data[[ft]] <- choices[, ft]
    }

    # Run regression
    formula_str <- paste("Y ~", paste(formula_terms, collapse = " + "))
    model <- stats::lm(stats::as.formula(formula_str), data = reg_data)

    # Extract coefficients and standard errors
    summ <- summary(model)
    coefs <- summ$coefficients[, 1]
    ses <- summ$coefficients[, 2]

    # Build result data.frame matching original format
    result <- data.frame(
        Coefficient = coefs,
        SE = ses,
        Variable = included_vars,
        stringsAsFactors = FALSE
    )
    rownames(result) <- NULL

    return(result)
}
