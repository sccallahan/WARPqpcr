#' @title get_dCT_bioReps
#'
#' @description Calculates dCT values when biological replicates are present.
#'
#' @param sampleObj A qPCRBatch object generated from the \code{\link{readSampleSheet}} function.
#' @param hkg A character vector containing the housekeeping gene to use for dCT calculations.
#'
#' @details Biological replicates must have unique identifiers, else they will be considered technical replicates.
#' The simplest way to do this is to give samples names such as "treated_1", "treated_2", etc.
#'
#' @return A data.frame containing dCT values for each condition.
#'
#' @export
#'
#' @examples
#'
get_dCT_bioReps <- function(sampleObj, hkg){
  if(missing(hkg)){
    stop("Must provide a housekeeping gene (hkg)!")
  }
  batchTechReps <- combineTechRepsWithSD(sampleObj)
  batchTechRepsdCT <- deltaCq(batchTechReps, hkgs = hkg, calc = "arith")
  dCTs <- as.data.frame(head(exprs(batchTechRepsdCT)))
  return(dCTs)
}
