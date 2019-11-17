#' @title calcCV
#'
#' @description Calculates the coefficient of variation for each gene for each sample and triggers a message if any samples
#' are above the desired threshold.
#'
#' @param avgCtObj A data.frame generated from the \code{\link{getAvgCT}} function.
#' @param cutoff The cutoff value for the coefficient of variation for triggering a warning message. Default 1.0, or 1\%.
#'
#' @details Technical replicate error is not carried forward when calculating error for biological replicates. The coefficient of variation
#' is intended to be used a filter for checking the quality of technical replication before proceeding.
#'
#' @return A data.frame.
#'
#' @export
#'
#' @examples
#'
calcCV <- function(avgCtObj, cutoff = 1.0){
  avgCtObj$CV <- apply(avgCtObj[, c("value", "SD")], 1, function(x)(x[2]/x[1])*100)
  if (length(which(avgCtObj$CV >= cutoff)) > 0){
    message(length(which(avgCtObj$CV >= cutoff)), " samples have CV over the threshold, there may be issues with technical replication")
    message("Check CV column for affected samples and raw data for outlying replicates")
  } else{
    message("All samples passed the CV threshold!")
  }
  return(avgCtObj)
}
