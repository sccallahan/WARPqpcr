#' @title get_chip_dCT
#'
#' @description Calculates dCT values for chip qpcr data and organizes it into a format
#' compatible with \code{\link{signifTest}}.
#'
#' @param sampleObj A qPCRBatch object generated from the \code{\link{readSampleSheet}} function.
#' @param inputName A character vector of the common name given to all input samples
#' @param mockName A character vector of the common name given to all mock (e.g. IgG control) samples
#' @param inputPercent The percent of starting chromatin used as input. Should be an integer in percent (e.g. 2\% input is 2).
#' @param method Indicates which calculation should be performed. Must be one of ("i", "input") for input,
#' or ("fe", "fold enrichment") for fold enrichment.
#'
#' @details This function only works with biological replicate data. Providing a `mockName` for percent
#' input calculations will remove the mock samples from the calculations. Likewise, providing an `inputName` for
#' fold enrichment calculations will remove the input samples from the calculations.
#'
#' @return A data.frame
#' @export
#'
#'
get_chip_dCT <- function(sampleObj, inputName = NULL, mockName = NULL, inputPercent = NULL, method){

  #### check method ####
  if (missing(method)){
    stop("method argument must be set!")
  }
  if (!method %in% c("i", "input", "fe", "fold enrichment")){
    stop("method must be one of: 'i', 'input', 'fe', or 'fold enrichment'!")
  }

  # adjust input and do dCT subtractions if needed
  batchTechReps <- combineTechRepsWithSD(sampleObj)
  cq_avg <- as.data.frame(exprs(batchTechReps))
  cq_sd <- as.data.frame(se.exprs(batchTechReps))
  if (method %in% c("i", "input")){
    if(is.null(inputPercent)){
      stop("inputPercent must be set for method = input!")
    }
    if(!is.null(inputName)){
      control <- inputName
      dilution_factor <- 100/inputPercent
      dilution_factor <- log2(dilution_factor)
      dilution_values <- cq_avg[grepl(control, rownames(cq_avg)), ] - dilution_factor
      if(!is.null(mockName)){
        mock <- mockName
        cq_avg <- cq_avg[!grepl(mock, rownames(cq_avg)), ]
        cq_sd <- cq_sd[!grepl(mock, rownames(cq_sd)), ]
      }
      input_corrected <- rbind(dilution_values, cq_avg[!grepl(control, rownames(cq_avg)), ])
    } else {
      stop("inputName must be set for method = input!")
    }
  }

  # for fold enrichment
  if (method %in% c("fe", "fold enrichment")){
    if(!is.null(mockName)){
      mock <- mockName
      if(!is.null(inputName)){
        control <- inputName
        rm_input_ct <- cq_avg[!grepl(control, rownames(cq_avg)), ]
        rm_input_sd <- cq_sd[!grepl(control, rownames(cq_sd)), ]
        new_cq <- rm_input_ct
        new_sd <- rm_input_sd
        input_corrected <- new_cq
        cq_sd <- new_sd
      } else {
        input_corrected <- cq_avg
      }
      control <- mock
    } else{
      stop("mockName must be set for method = fold enrichment!")
    }
  }

  # get unique regions
  ind <- which(grepl(control, rownames(input_corrected)))
  test <- rownames(input_corrected)[ind]
  x <- str_split(test, pattern = "[:punct:]", n = 2)
  uniq <- NULL
  for(i in 1:length(x)){
    tmp <- x[[i]][2]
    uniq <- c(uniq, tmp)
  }

  # merge bioreps and calculate SD
  # get unique sample identifiers
  sample_ID <- str_split(colnames(input_corrected), pattern = "[:punct:]", n = 2)
  sample_ID_uniq <- NULL
  for(i in 1:length(sample_ID)){
    tmp <- sample_ID[[i]][1]
    sample_ID_uniq <- c(sample_ID_uniq, tmp)
    rm(tmp)
  }
  sample_ID_uniq <- unique(sample_ID_uniq)

  # merge isolate biological replicates by ID
  biorep_merge <- list()
  i <- 1
  for(s in sample_ID_uniq){
    biorep_merge[[i]] <- input_corrected[, grepl(s, colnames(input_corrected))]
    i <- i + 1
  }

  #### get dCT values into format for `signifTest` ####
  region_stats <- list()
  i <- 1
  for (r in uniq){
    region_stats[[i]] <- input_corrected[grepl(r, rownames(input_corrected)), ]
    i <- i + 1
  }

  dct_stats <- list()
  i <- 1
  for (r in region_stats){
    tmp <- as.data.frame(r)
    new_control <- grepl(control, rownames(tmp))
    dct_stats[[i]] <- apply(tmp, 2, function(x) x - x[new_control])
    i <- i + 1
  }

  #### make dCT dataframe ####
  dct_values <- do.call("rbind", dct_stats)

  return(dct_values)
}
