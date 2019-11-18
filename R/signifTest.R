#' @title signifTest
#'
#' @description Computes a p.value using a two-sample t-test with H0 = "two.sided" for the indicated gene.
#' See \code{\link{t.test}} for more information.
#'
#' @param dCTObj A data.frame generated from the \code{\link{get_dCT_singleRep}}
#' or \code{\link{get_dCT_bioReps}} function.
#' @param gene.name Name of the gene for which to compute the t-test.
#' @param var.equal Boolean indicating whether or not to treat the variance as equal.
#'
#' @return A list containing the components indicated in \code{\link{t.test}}. Also prints a message
#' reporting the calculated p.value.
#'
#' @export
#'
#' @import stringr
#'
#' @examples
#'
signifTest <- function(dCTObj, gene.name, var.equal = FALSE){
  n <- str_split(colnames(dct), pattern = "[:punct:]", simplify = TRUE)
  n <- unique(n[,1])
  x <- t.test(dCTObj[rownames(dCTObj) == gene.name, grepl(n[1], colnames(dCTObj))],
              dCTObj[rownames(dCTObj) == gene.name, grepl(n[2], colnames(dCTObj))],
              var.equal = var.equal)
  message(paste0("The p.value for ", gene.name, " is ", x$p.value))
  if (x$p.value < 0.05){
    message("p.value is SIGNIFICANT with p < 0.05!")
  } else {
    message("p.value is NOT significant with p > 0.05!")
  }
}
