#' @title getRawCT
#'
#' @description Generates a data.frame of raw CT values.
#'
#' @param sampleObj A qPCRBatch object.
#'
#' @return A data.frame.
#'
#' @export
#'
#' @examples
#'
getRawCT <- function(sampleObj){
  as.data.frame(exprs(sampleObj))
}
