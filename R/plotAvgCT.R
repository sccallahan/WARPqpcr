#' @title plotAvgCT
#'
#' @description Generates a barplot of the average CT values for each sample with error bars.
#'
#' @param avgCtObj A data.frame generated from the \code{\link{getAvgCT}} function.
#' @param palette Any color palette from RColorBrewer.
#' @param xlab x axis label.
#' @param ylab y axis label.
#' @param title Main title for the plot.
#' @param legend.title Title for the plot legend.
#' @param theme_classic Boolean value. TRUE will yield a plot with the 'classic' background. FALSE will yield a plot
#' with the default ggplot2 theme.
#'
#' @return A ggplot2 barplot of average CT values.
#'
#' @export
#'
#' @import RColorBrewer
#' @import ggplot2
#'
#' @examples
#'
plotAvgCT <- function(avgCtObj, palette = "Set1", xlab = "", ylab = "", title = "",
                      legend.title = "", theme_classic = TRUE){
  ggplot(data = avgCtObj, aes(x = avgCtObj[,1], y = avgCtObj$value, fill = avgCtObj[,2],
                              ymin = avgCtObj$value - avgCtObj$SD, ymax = avgCtObj$value + avgCtObj$SD)) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_errorbar(position = position_dodge(width = 0.9), width = 0.5) +
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
