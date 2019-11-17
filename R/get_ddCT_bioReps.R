#' @title get_ddCT_bioReps
#'
#' @description Calculates the ddCT values for all samples when biological replicates are present.
#'
#' @param sampleObj A qPCRBatch object generated from the \code{\link{readSampleSheet}} function.
#' @param cond.1 A character vector containing the group for condition 1 (e.g. "untreated").
#' @param cond.2 A character vector containing the group for condition 1 (e.g. "treated").
#' @param reps.cond.1 The number of biological replicates in condition 1.
#' @param reps.cond.2 The number of biological replicates in condition 2.
#' @param hkg A character vector containing the housekeeping gene to use for ddCT calculations.
#' @param rel.exp Boolean value indicating whether or not relative expression values should be calculated.
#' TRUE will ONLY compute expression relative to the control sample,
#' FALSE will ONLY compute log2 fold-change values.
#'
#' @return  A data.frame containing ddCT values in log2 fold-change or relative expression format.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' sampleObj <- readSampleSheet(file)
#' ddCTObj <- get_ddCT_bioReps(sampleObj, cond.1 = "untreated",
#' cond.2 = "treated", reps.cond.1 = 3, reps.cond.2 = 3,
#' hkg = "GAPDH", rel.exp = FALSE)
#' }
#'
get_ddCT_bioReps <- function(sampleObj, cond.1, cond.2,
                             reps.cond.1, reps.cond.2, hkg, rel.exp = FALSE){
  if(missing(hkg)){
    stop("Must provide a housekeeping gene (hkg)!")
  }
  batchTechReps <- combineTechRepsWithSD(sampleObj)
  cond.1_string <- c(rep(1, times = reps.cond.1), rep(0, times = reps.cond.2))
  cond.2_string <- c(rep(0, times = reps.cond.1), rep(1, times = reps.cond.2))
  contrastM <- cbind(cond.1_string, cond.2_string)
  # colnames(contrastM) <- c(cond.1, cond.2)
  colnames(contrastM) <- sort(c(cond.1, cond.2))
  rownames(contrastM) <- sampleNames(batchTechReps)
  if (rel.exp){
    ddCq <- deltaDeltaCq(qPCRBatch = batchTechReps, maxNACase=1, maxNAControl=1,
                         hkg=hkg, contrastM=contrastM, case="KD", control="LUC",
                         statCalc="arith", hkgCalc="arith", paired = FALSE)
    return(ddCq)
  } else {
    ddCq <- deltaDeltaCq(qPCRBatch = batchTechReps, maxNACase=1, maxNAControl=1,
                         hkg=hkg, contrastM=contrastM, case="KD", control="LUC",
                         statCalc="arith", hkgCalc="arith", paired = FALSE)
    ddCqLog2 <- ddCq[, grepl("ddCt", names(ddCq))]
    ddCqLog2 <- apply(ddCqLog2, 2, function(x) as.numeric(x))
    ddCqLog2 <- apply(ddCqLog2, 2, function(x) log2(x))
    colnames(ddCqLog2) <- c("ddCT", "ddCT.min", "ddCT.max")
    ddCqLog2 <- as.data.frame(ddCqLog2)
    rownames(ddCqLog2) <- ddCq$ID
    return(ddCqLog2)
  }
}
