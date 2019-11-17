#' @title get_ddCT_singleRep
#'
#' @description Calculates the ddCT values for all samples in situations where
#' there is only a single biological replicate per condition.
#'
#' @param sampleObj A qPCRBatch object generated from the \code{\link{readSampleSheet}} function.
#' @param hkg A character vector containing the housekeeping gene to use for ddCT calculations.
#' @param control A character vector containing the name of the control condition.
#' @param rel.exp Boolean value indicating whether or not relative expression values should be calculated.
#' TRUE will compute both log2 fold-change and expression relative to the control sample,
#' FALSE will only compute log2 fold-change values.
#'
#' @details This function is primarily intended for pilot/preliminary data in which biological replicates have not
#' yet been produced or cases in which multiple vectors are being evaluated for efficiency (e.g. shRNA knockdowns, overexpression
#' constructs, etc.)
#'
#' @return A data.frame containing ddCT values in log2 fold-change or relative expression format.
#'
#' @export
#'
#' @import reshape2
#'
#' @examples
#' \dontrun{
#' sampleObj <- readSampleSheet(file)
#' ddCTObj <- get_ddCT_singleRep(sampleObj, "GAPDH", "untreated",
#' rel.exp = FALSE)
#' }
#'
get_ddCT_singleRep <- function(sampleObj, hkg, control, rel.exp = FALSE){
  if(missing(hkg)){
    stop("Must provide a housekeeping gene (hkg)!")
  }
  batchTechReps <- combineTechRepsWithSD(sampleObj)
  cq_avg <- as.data.frame(exprs(batchTechReps))
  cq_sd <- as.data.frame(se.exprs(batchTechReps))
  dct_test <- apply(cq_avg, 2, function(x) x - x[hkg])
  sd_prop_test <- apply(cq_sd, 2, function(x) sqrt((x^2) + (x[hkg]^2)))
  dctMelt <- melt(as.matrix(dct_test), id.vars = rownames(dct_test))
  sdPropMelt <- melt(as.matrix(sd_prop_test), id.vars = rownames(sd_prop_test))
  colnames(sdPropMelt)[3] <- "ErrProp"
  ddct <- as.data.frame(apply(dct_test, 1, function(x) x - x[control]))
  ddct_signFix <- as.data.frame(apply(ddct, 1, function(x) -x))
  ddctMelt <- melt(as.matrix(ddct_signFix), id.vars = rownames(ddct_signFix))
  ddctFinalDF <- merge(ddctMelt, sdPropMelt)
  if (rel.exp){
    ddctFinalDF$relExp <- 2^(ddctFinalDF$value)
    ddctFinalDF$relExpMin <- 2^(ddctFinalDF$value - ddctFinalDF$ErrProp)
    ddctFinalDF$relExpMax <- 2^(ddctFinalDF$value + ddctFinalDF$ErrProp)
  }
  return(ddctFinalDF)
}
