#' @title preText specification plot
#' @description Generates a dot plot of preText scores for each preprocessing
#'   specification, ordered from most to least unusual.
#'
#' @param preText_results A list object returned by the \code{preText()} function.
#' @param remove_constant Logical; remove specifications with zero score.
#'   Defaults to TRUE.
#' @return A ggplot2 object.
#' @importFrom ggplot2 ggplot aes geom_point theme_bw xlab ylab ggtitle scale_y_discrete
#' @export
preText_score_plot <- function(preText_results, remove_constant = TRUE) {

    scores <- preText_results$preText_scores

    if (remove_constant) {
        scores <- scores[scores$preText_score != 0 & !is.na(scores$preText_score), ]
    }

    scores <- scores[order(scores$preText_score), ]
    scores$labels <- factor(scores$labels, levels = scores$labels)

    p <- ggplot2::ggplot(scores, ggplot2::aes(x = preText_score, y = labels)) +
        ggplot2::geom_point(size = 2) +
        ggplot2::theme_bw() +
        ggplot2::xlab("preText Score") +
        ggplot2::ylab("Preprocessing Specification") +
        ggplot2::ggtitle(paste0("preText Scores: ", preText_results$dataset_name))

    return(p)
}


#' @title Regression Coefficient Plot
#' @description Generates a coefficient plot showing the effect of each
#'   preprocessing step on the preText score.
#'
#' @param preText_results A list object returned by the \code{preText()} function.
#' @param remove_intercept Logical; whether to remove the intercept from the
#'   plot. Defaults to TRUE.
#' @return A ggplot2 object.
#' @importFrom ggplot2 ggplot aes geom_point geom_errorbarh geom_vline theme_bw xlab ylab ggtitle
#' @export
regression_coefficient_plot <- function(preText_results, remove_intercept = TRUE) {

    results <- preText_results$regression_results

    if (remove_intercept) {
        results <- results[results$Variable != "(Intercept)", ]
    }

    results$Variable <- gsub("TRUE$", "", results$Variable)
    results <- results[order(results$Coefficient), ]
    results$Variable <- factor(results$Variable, levels = results$Variable)

    p <- ggplot2::ggplot(results,
                         ggplot2::aes(x = Coefficient, y = Variable)) +
        ggplot2::geom_point(size = 2) +
        ggplot2::geom_errorbarh(ggplot2::aes(xmin = CI_lower, xmax = CI_upper),
                                height = 0.2) +
        ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
        ggplot2::theme_bw() +
        ggplot2::xlab("Regression Coefficient") +
        ggplot2::ylab("Preprocessing Step") +
        ggplot2::ggtitle(paste0("Effect of Preprocessing Choices: ",
                                preText_results$dataset_name))

    return(p)
}
