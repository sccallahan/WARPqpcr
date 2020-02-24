#' @title plot_ddCT_singlerep
#'
#' @description Generates a barplot of the ddCT values for each sample with error bars.
#'
#' @param ddCTobj A data.frame generated from the \code{\link{get_ddCT_singleRep}} function.
#' @param palette Any color palette from RColorBrewer.
#' @param xlab x axis label.
#' @param ylab y axis label.
#' @param title Main title for the plot.
#' @param legend.title Title for the plot legend.
#' @param hideHKG Boolean value indicating whether or not the housekeeping gene should be removed from the plot
#' @param HKGname A character vector of the housekeeping gene name. Required if `hideHKG` is TRUE.
#' @param theme_classic Boolean value. TRUE will yield a plot with the 'classic' background. FALSE will yield a plot
#' with the default ggplot2 theme.
#' @param rel.exp Boolean value indicating whether or not relative expression values should be used for plot. TRUE will generate
#' a plot of relative expression values, FALSE will generate a plot of log2 fold-change values.
#'
#' @return A ggplot2 barplot of ddCT values.
#'
#' @export
#'
#' @examples
#'
plot_ddCT_singleRep <- function(ddCTobj, palette = "Set1", xlab = "", ylab = "", title = "",
                                legend.title = "", hideHKG = FALSE, HKGname,
                                theme_classic = TRUE, rel.exp = FALSE){
  if (hideHKG){
    if(missing(HKGname)){
      stop("Must provide HKGname to remove it from the plot!")
    }
    ddCTobj <- ddCTobj[!grepl(HKGname, ddCTobj$Var1), ]
  }
  if (rel.exp){
    ggplot(data = ddCTobj, aes(x = ddCTobj[,1], y = ddCTobj$relExp, fill = ddCTobj[,2],
                               ymin = ddCTobj$relExpMin, ymax = ddCTobj$relExpMax)) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_errorbar(position = position_dodge(width = 0.9), width = 0.5) +
      scale_fill_brewer(palette = "Set1") +
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
  } else {
    ggplot(data = ddCTobj, aes(x = ddCTobj[,1], y = ddCTobj$value, fill = ddCTobj[,2],
                               ymin = ddCTobj$value - ddCTobj$ErrProp, ymax = ddCTobj$value + ddCTobj$ErrProp)) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_errorbar(position = position_dodge(width = 0.9), width = 0.5) +
      geom_hline(yintercept = 0.0, color = "black", linetype = "solid", size = 1) +
      scale_fill_brewer(palette = "Set1") +
      xlab(xlab) +
      ylab(ylab) +
      ggtitle(title) +
      labs(fill = legend.title) +
      # scale_y_continuous(limits = c(min(ddCTobj$value) - (0.5*max(ddCTobj$value)),
      #                               max(ddCTobj$value) + (0.5*max(ddCTobj$value))), expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      if (theme_classic){
        theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
              panel.background = element_blank(), axis.line = element_line(color = "black", size = 2))
      } else {
        theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20))
      }
  }
}
