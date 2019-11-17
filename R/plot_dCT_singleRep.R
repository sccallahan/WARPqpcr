#' @title plot_dCT_singleRep
#'
#' @description Generates a barplot of the dCT values for each sample with error bars.
#'
#' @param dCTobj A data.frame generated from the \code{\link{get_dCT_singleRep}} function.
#' @param palette Any color palette from RColorBrewer.
#' @param xlab x axis label.
#' @param ylab y axis label.
#' @param title Main title for the plot.
#' @param legend.title Title for the plot legend.
#' @param theme_classic Boolean value. TRUE will yield a plot with the 'classic' background. FALSE will yield a plot
#' with the default ggplot2 theme.
#'
#' @return A ggplot2 barplot of dCT values.
#'
#' @export
#'
#' @examples
#'
plot_dCT_singleRep <- function(dCTobj, palette = "Set1", xlab = "", ylab = "", title = "",
                               legend.title = "", theme_classic = TRUE){
  ggplot(data = dCTobj, aes(x = dCTobj[,1], y = dCTobj$value, fill = dCTobj[,2],
                            ymin = dCTobj$value - dCTobj$ErrProp, ymax = dCTobj$value + dCTobj$ErrProp)) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_errorbar(position = position_dodge(width = 0.9), width = 0.5) +
    geom_hline(yintercept = 0.0, color = "black", linetype = "solid", size = 1) +
    scale_fill_brewer(palette = palette) +
    xlab(xlab) +
    ylab(ylab) +
    ggtitle(title) +
    labs(fill = legend.title) +
    scale_y_continuous(expand = c(0, 0)) +
    if (theme_classic){
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            panel.background = element_blank(), axis.line = element_line(color = "black", size = 2))
    } else {
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20))
    }
}
