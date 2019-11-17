#' @title calcStab
#'
#' @description Finds the most stable housekeeping gene across conditions using the DeltaCt approach from Silver et al. (2006).
#'
#' @param avgCTobj A data.frame generated from the \code{\link{getAvgCT}} function.
#' @param hkgs A character vector containing the potential housekeeping genes.
#'
#' @return A data.frame containing the tested housekeeping genes and their scores,
#' sorted from lowest to highest (i.e. most stable to least stable).
#'
#' @references \href{https://www.ncbi.nlm.nih.gov/pubmed/17026756}{Silver et al. 2006. Selection of housekeeping genes for gene expression studies in human reticulocytes using real-time PCR. BMC Mol Biol}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' geneRank <- calcStab(avgCTobj, c("ACTB", "GAPDH"))
#' }
#'
calcStab <- function(avgCTobj, hkgs){
  if(missing(hkgs)){
    stop("Must provide a vector of possible housekeeping genes (hkgs)!")
  }
  avgCTobj <- avgCTobj[avgCTobj[,1] %in% hkgs, ]
  wideData <- dcast(avgCTobj, avgCTobj[,2] ~ avgCTobj[,1])
  compareGenes <- expand.grid(rep(list(colnames(wideData[-1])), 2))
  compareGenes <- as.matrix(compareGenes[, c(2,1)])
  dCTs <- apply(compareGenes, 1, function(q) wideData[[q[1]]] - wideData[[q[2]]])
  colnames(dCTs) <- apply(compareGenes, 1, paste, collapse = "_")
  rownames(dCTs) <- wideData[,1]
  dCTs <- t(dCTs)
  dCTs <- dCTs[!rowSums(dCTs) == 0, ]
  dCTs <- as.data.frame(dCTs)
  dCTs$avgCT <- rowMeans(dCTs)
  dCTs$sdCT <- apply(dCTs[, -ncol(dCTs)], 1, sd)
  sampleString <- str_split(rownames(dCTs), pattern = "_", simplify = TRUE)
  sampleString <- unique(sampleString[,1])
  stdevs <- NULL
  for (i in 1:length(sampleString)){
    tmp <- dCTs[grep(paste0(sampleString[i], "_"), rownames(dCTs)), ]
    tmp <- mean(tmp[,ncol(tmp)])
    stdevs <- rbind(stdevs, tmp)
  }
  rownames(stdevs) <- sampleString
  stdevs <- as.data.frame(stdevs)
  stdevs <- stdevs[order(stdevs), , drop = FALSE]
  return(stdevs)
}
