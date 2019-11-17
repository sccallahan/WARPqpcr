#' @title get_dCT_singlerep
#'
#' @description Calculates the dCT values for all samples in situations where
#' there is only a single biological replicate per condition.
#'
#' @param sampleObj A qPCRBatch object generated from the \code{\link{readSampleSheet}} function.
#' @param hkg A character vector containing the housekeeping gene to use for dCT calculations.
#'
#' @details This function is primarily intended for pilot/preliminary data in which biological replicates have not
#' yet been produced or cases in which multiple vectors are being evaluated for efficiency (e.g. shRNA knockdowns, overexpression
#' constructs, etc.)
#'
#' @details The error for these calculations is propagated from the technical replicate standard deviation.
#'
#' @return A data.frame containing dCT values for each condition.
#'
#' @export
#'
#' @examples
#'
get_dCT_singleRep <- function(sampleObj, hkg){
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
  dctErrPropDF <- merge(dctMelt, sdPropMelt)
  return(dctErrPropDF)
}
