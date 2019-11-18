#' @title readSampleSheet
#'
#' @description Reads in a tab-delimited file of qPCR data using \code{\link{read.qPCR}}.
#' Requires 5 columns: Well, Plate, Sample, Detector, Cq.
#'
#' @param file Tab-delimted file containing qPCR data
#'
#' @details Biological replicates MUST be given unique identifiers, else they will be treated as technical replicates. For example,
#' if an experiment has 2 biological replicates for a wildtype sample, they should be entered as "WT_1" and "WT_2". Entering them
#' both as "WT" will result in them being treated as technical replicates of the same sample. Multiple technial replicates of biological
#' replicates should entered with the same names (e.g. "WT_1", "WT_1", "WT_2", "WT_2" would be 2 technical replicates of biological
#' replicate 1 and 2 technical replicates of biological replicate 2).
#'
#' @return A qPCRBatch object.
#'
#' @export
#'
#' @import ReadqPCR
#' @import NormqPCR
#'
#' @examples
#'
readSampleSheet <- function(file){
  tryCatch({
    suppressWarnings(read.qPCR(file))
  }, error = function(e){message("\nERROR: ", conditionMessage(e), "!",
                                 "\nNB: Values must be numeric or NA!",
                                 "\nConsider using 'readSampleSheet.NoCT' if Cq/Ct column contains character values")}
  )
}
