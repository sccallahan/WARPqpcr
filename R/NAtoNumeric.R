#' @title NAtoNumeric
#'
#' @description Takes a qPCRBatch object as input and converts all Cq/Ct NAs to desired values.
#'
#' @param sampleObj The qPCRBatch object from \code{\link{readSampleSheet}} to be converted.
#' @param value Value to replace NA with. Default 35.
#'
#' @return A qPCRBatch object with NAs replaced with \code{value}.
#'
#' @export
#'
#' @examples
#'
NAtoNumeric <- function(sampleObj, value = 35){
  replaced <- replaceNAs(qPCRBatch = sampleObj, newNA = value)
}
