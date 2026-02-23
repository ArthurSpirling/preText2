#' @title preText specification plot
#' @description Creates a dot plot of preText scores for each preprocessing
#' specification, ordered from most to least unusual.
#'
#' @param preText_results A results object from the \code{preText()} function.
#' @param remove_intercept Logical, not used for this plot but included for
#' API compatibility.
#' @return A ggplot object.
#' @examples
#' \dontrun{
#' preText_score_plot(preText_results)
#' }
#' @export
preText_score_plot <- function(preText_results,
                                remove_intercept = TRUE) {

    # Extract ranked scores from preText results
    ranked <- preText_results$ranked_preText_scores

    # Create data for plotting
    plot_data <- data.frame(
        preprocessing_steps = factor(ranked$preprocessing_steps,
                                      levels = rev(ranked$preprocessing_steps)),
        preText_score = ranked$preText_score,
        stringsAsFactors = FALSE
    )

    p <- ggplot2::ggplot(plot_data,
                          ggplot2::aes(x = preText_score,
                                       y = preprocessing_steps)) +
        ggplot2::geom_point() +
        ggplot2::theme_bw() +
        ggplot2::xlab("preText Score") +
        ggplot2::ylab("") +
        ggplot2::theme(axis.text.y = ggplot2::element_text(size = 6))

    return(p)
}


#' @title Regression Coefficient Plot
#' @description Creates a dot plot of regression coefficients showing the
#' effect of each preprocessing decision on preText scores.
#'
#' @param preText_results A results object from the \code{preText()} function.
#' @param remove_intercept Logical indicating whether to remove the intercept
#' from the plot. Defaults to TRUE.
#' @return A ggplot object.
#' @examples
#' \dontrun{
#' regression_coefficient_plot(preText_results, remove_intercept = TRUE)
#' }
#' @export
regression_coefficient_plot <- function(preText_results,
                                         remove_intercept = TRUE) {

    # Extract regression results
    reg_results <- preText_results$regression_results

    # Remove intercept if requested
    if (remove_intercept) {
        reg_results <- reg_results[reg_results$Variable != "Intercept", ]
    }

    # Create data for plotting
    plot_data <- data.frame(
        Variable = factor(reg_results$Variable,
                           levels = rev(reg_results$Variable)),
        Coefficient = reg_results$Coefficient,
        SE = reg_results$SE,
        lower = reg_results$Coefficient - 1.96 * reg_results$SE,
        upper = reg_results$Coefficient + 1.96 * reg_results$SE,
        stringsAsFactors = FALSE
    )

    p <- ggplot2::ggplot(plot_data,
                          ggplot2::aes(x = Coefficient,
                                       y = Variable)) +
        ggplot2::geom_point() +
        ggplot2::geom_errorbarh(ggplot2::aes(xmin = lower, xmax = upper),
                                 height = 0.2) +
        ggplot2::geom_vline(xintercept = 0, linetype = "dashed",
                             color = "gray50") +
        ggplot2::theme_bw() +
        ggplot2::xlab("Regression Coefficient") +
        ggplot2::ylab("")

    return(p)
}
