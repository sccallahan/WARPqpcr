#' @title getAvgCT
#'
#' @description Calculates the average CT value and standard deviation from technical replicates.
#'
#' @param sampleObj A qPCRBatch object.
#'
#' @return A data.frame.
#'
#' @export
#'
#' @examples
#'
getAvgCT <- function(sampleObj){
  batchTechReps <- combineTechRepsWithSD(sampleObj)
  cq_avg <- as.data.frame(exprs(batchTechReps))
  cq_sd <- as.data.frame(se.exprs(batchTechReps))
  cq_graph <- melt(as.matrix(cq_avg), id.vars = rownames(cq_avg))
  cq_sd_graph <- melt(as.matrix(cq_sd), id.vars = rownames(cq_sd))
  colnames(cq_sd_graph)[3] <- "SD"
  cq_graph_merge <- merge(cq_graph, cq_sd_graph)
  return(cq_graph_merge)
}
