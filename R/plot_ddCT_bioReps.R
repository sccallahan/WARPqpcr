#' @title plot_ddCT_bioReps
#'
#' @description Generates a barplot of the ddCT values for each condition with error bars.
#'
#' @param ddCTobj A data.frame generated from the \code{\link{get_ddCT_bioReps}} function.
#' @param palette Any color palette from RColorBrewer.
#' @param xlab x axis label.
#' @param ylab y axis label.
#' @param title Main title for the plot.
#' @param legend.title Title for the plot legend.
#' @param theme_classic Boolean value. TRUE will yield a plot with the 'classic' background. FALSE will yield a plot
#' with the default ggplot2 theme.
#' @param rel.exp Boolean value indicating the data type contained in the ddCTobj.
#' TRUE indicates the data is on the relative expression scale and will generate
#' a plot of relative expression values.
#' FALSE indicates the data is on the log2 fold-change scale will generate
#' a plot of log2 fold-change values.
#'
#' @details This function requires the data contained in the ddCTobj to match the setting chosen
#' for the `rel.exp` argument. Mismatches (i.e. having a ddCTobj with relative expression
#' and requesting a plot of log2 fold-change) will result in errors.
#'
#' @return A ggplot2 barplot of ddCT values.
#'
#' @export
#'
#' @examples
#'
plot_ddCT_bioReps <- function(ddCTobj, palette = "Set1", xlab = "Gene", ylab = "", title = "",
                              legend.title = "", theme_classic = TRUE, rel.exp = FALSE){
  if (rel.exp){
    ggplot(data = ddCTobj, aes(x = ddCTobj[,1], y = as.numeric(as.character(ddCTobj$`2^-ddCt`)), fill = ddCTobj[,1],
                               ymin = as.numeric(as.character(ddCTobj$`2^-ddCt.min`)),
                               ymax = as.numeric(as.character(ddCTobj$`2^-ddCt.max`)))) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_errorbar(position = position_dodge(width = 0.9), width = 0.5) +
      scale_fill_brewer(palette = "Set1") +
      xlab(xlab) +
      ylab(ylab) +
      ggtitle(title) +
      labs(fill = legend.title) +
      scale_y_continuous(expand = c(0, 0), limits = c(0, max(as.numeric(as.character(ddCTobj$`2^-ddCt.max`))) + 0.1)) +
      # coord_cartesian(ylim = c(0.5, 1.0)) +
      # scale_y_continuous(limits = c(0, 2)) +
      if (theme_classic){
        theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
              panel.background = element_blank(), axis.line = element_line(color = "black", size = 2))
      } else {
        theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20))
      }
  } else {
    ggplot(data = ddCTobj, aes(x = rownames(ddCTobj), y = ddCTobj$ddCT, fill = rownames(ddCTobj),
                               ymin = ddCTobj$ddCT.min, ymax = ddCTobj$ddCT.max)) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_errorbar(position = position_dodge(width = 0.9), width = 0.5) +
      geom_hline(yintercept = 0.0, color = "black", linetype = "solid", size = 1) +
      scale_fill_brewer(palette = "Set1") +
      xlab(xlab) +
      ylab(ylab) +
      ggtitle(title) +
      labs(fill = legend.title) +
      scale_y_continuous(limits = c(min(ddCTobj$ddCT.min) - abs((0.25*min(ddCTobj$ddCT.min))),
                                    max(ddCTobj$ddCT.max) + (0.25*max(ddCTobj$ddCT.max))), expand = c(0, 0)) +
      if (theme_classic){
        theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
              panel.background = element_blank(), axis.line = element_line(color = "black", size = 2))
      } else {
        theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20))
      }
  }
}
