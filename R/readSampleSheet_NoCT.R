#' @title readSampleSheet.NoCT
#'
#' @description Functions as \code{\link{readSampleSheet}} when the Cq column contains non-numerics or non-NA values.
#' Will convert all non-numerics to NA. Saves a converted version of the file with an "_NAconverted.csv" suffix.
#'
#' @param file
#'
#' @details \code{\link{readSampleSheet}} will fail if any non-numeric values are in the Cq columns, or if every sample
#' does not have the same number of replicates for each gene. This function will convert all non-numerics to NA,
#' allowing the file to be read into R and further analysis to be performed.
#'
#' @details Biological replicates MUST be given unique identifiers, else they will be treated as technical replicates. For example,
#' if an experiment has 2 biological replicates for a wildtype sample, they should be entered as "WT_1" and "WT_2". Entering them
#' both as "WT" will result in them being treated as technical replicates of the same sample. Multiple technial replicates of biological
#' replicates should entered with the same names (e.g. "WT_1", "WT_1", "WT_2", "WT_2" would be 2 technical replicates of biological
#' replicate 1 and 2 technical replicates of biological replicate 2).
#'
#' @return A qPCRBatch object.
#'
#' @import tools
#'
#' @export
#'
#' @examples
#'
readSampleSheet.NoCT <- function(file){
  badFormat <- read.csv(file = file, header = TRUE, sep = "\t")
  suppressWarnings(badFormat$Cq <- as.numeric(as.character(badFormat$Cq)))
  write.table(x = badFormat, file = paste0(tools::file_path_sans_ext(file),"_NAconverted.csv"), sep = "\t",
              row.names = FALSE, quote = FALSE)
  tryCatch({
    suppressWarnings(read.qPCR(filename = paste0(tools::file_path_sans_ext(file),"_NAconverted.csv")))
  }, error = function(e){message("\nERROR: ", conditionMessage(e), "!")})
}
