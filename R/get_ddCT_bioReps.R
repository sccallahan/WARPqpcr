#' @title get_ddCT_bioReps
#'
#' @description Calculates the ddCT values for all samples when biological replicates are present.
#'
#' @param sampleObj A qPCRBatch object generated from the \code{\link{readSampleSheet}} function.
#' @param case A character vector containing the group for the experimental condition (e.g. "treated").
#' @param control A character vector containing the group for control condition 1 (e.g. "untreated").
#' @param reps.case The number of biological replicates in condition 1.
#' @param reps.control The number of biological replicates in condition 2.
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
#' ddCTObj <- get_ddCT_bioReps(sampleObj, case = "treated",
#' control = "untreated", reps.case = 3, reps.control = 3,
#' hkg = "GAPDH", rel.exp = FALSE)
#' }
#'
get_ddCT_bioReps <- function(sampleObj, case, control,
                             reps.case, reps.control, hkg, rel.exp = FALSE){
  if(missing(hkg)){
    stop("Must provide a housekeeping gene (hkg)!")
  }
  batchTechReps <- combineTechRepsWithSD(sampleObj)
  if(sum(grepl(case, sampleNames(object = batchTechReps))) == 0 | sum(grepl(control, sampleNames(object = batchTechReps))) == 0){
    stop("case or control label is incorrect!")
  }
  case_string <- c(rep(1, times = reps.case), rep(0, times = reps.control))
  control_string <- c(rep(0, times = reps.case), rep(1, times = reps.control))
  contrastM <- cbind(case_string, control_string)
  # colnames(contrastM) <- c(case, control)
  colnames(contrastM) <- sort(c(case, control))
  rownames(contrastM) <- sampleNames(batchTechReps)
  if (rel.exp){
    ddCq <- deltaDeltaCq(qPCRBatch = batchTechReps, maxNACase=1, maxNAControl=1,
                         hkg=hkg, contrastM=contrastM, case=case, control=control,
                         statCalc="arith", hkgCalc="arith", paired = FALSE)
    return(ddCq)
  } else {
    ddCq <- deltaDeltaCq(qPCRBatch = batchTechReps, maxNACase=1, maxNAControl=1,
                         hkg=hkg, contrastM=contrastM, case=case, control=control,
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
