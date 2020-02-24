#' @title do_chip_qpcr
#'
#' @description Calcuates either percent input or fold enrichment for chip qpcr data
#'
#' @param sampleObj A qPCRBatch object generated from the \code{\link{readSampleSheet}} function.
#' @param inputName A character vector of the common name given to all input samples
#' @param mockName A character vector of the common name given to all mock (e.g. IgG control) samples
#' @param inputPercent The percent of starting chromatin used as input. Should be an integer in percent (e.g. 2\% input is 2).
#' @param method Indicates which calculation should be performed. Must be one of ("i", "input") for input,
#' or ("fe", "fold enrichment") for fold enrichment.
#' @param bioReps Boolean indicating whether or not there are biological replicates.
#'
#' @details This function will handle both single replicate or n > 1 replicate experiments. Providing a `mockName` for percent
#' input calculations will remove the mock samples from the calculations. Likewise, providing an `inputName` for fold enrichment
#' calculations will remove the input samples from the calculations.
#'
#' @return A data.frame with dCT values, percent input/fold enrichment, and max/min percent input/fold enrichment per sample.
#' @export
#'
#' @import stringr
#'
#'
do_chip_qpcr <- function(sampleObj, inputName = NULL, mockName = NULL, inputPercent = NULL, method, bioReps = FALSE){

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

  #### Check replicate status ####
  if(bioReps){

    # merge bioreps and calculate SD
    # get uniqe sample identifiers
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

    # calculate mean + SD
    merged_replicates <- list()
    merged_replicates_sd <- list()
    i <- 1
    for(r in biorep_merge){
      merged_replicates[[i]] <- apply(as.data.frame(r), 1, mean)
      merged_replicates_sd[[i]] <- apply(as.data.frame(r), 1, sd)
      i <- i + 1
    }
    merged_replicates[1]
    merged_replicates_df <- as.data.frame(merged_replicates)
    colnames(merged_replicates_df) <- sample_ID_uniq

    merged_replicates_sd[1]
    merged_replicates_sd_df <- as.data.frame(merged_replicates_sd)
    colnames(merged_replicates_sd_df) <- sample_ID_uniq

    # fix variable names to be compatible with single reps
    input_corrected <- merged_replicates_df
    cq_sd <- merged_replicates_sd_df
  }

  # get cq values as separate dataframes per region
  regions <- list()
  i = 1
  for (r in uniq){
    regions[[i]] <- input_corrected[grepl(r, rownames(input_corrected)), ]
    i <- i +1
  }

  # get sd values as separate dataframes per region
  sd_frames <- list()
  i = 1
  for (s in uniq){
    sd_frames[[i]] <- cq_sd[grepl(s, rownames(cq_sd)), ]
    i <- i + 1
  }

  # compute dcts

  # if percent input
  if(method %in% c("i", "input")){
    dct_calc_frame <- list()
    i = 1
    for (df in regions){
      new_control <- grepl(control, rownames(df))
      dct_calc_frame[[i]] <- apply(df, 2, function(x) x[new_control] - x)
      i <- i + 1
    }
  }

  # if fold enrichment
  if (method %in% c("fe", "fold enrichment")){
    dct_calc_frame <- list()
    i = 1
    for (df in regions){
      new_control <- grepl(control, rownames(df))
      dct_calc_frame[[i]] <- apply(df, 2, function(x) x - x[new_control])
      i <- i + 1
    }
  }


  # compute sd propagation
  sd_prop_frame <- list()
  i = 1
  for (sd in sd_frames){
    new_control <- grepl(control, rownames(sd))
    sd_prop_frame[[i]] <- apply(sd, 2, function(x) sqrt((x^2) + (x[new_control]^2)))
    i <- i + 1
  }

  # make combined dfs
  dct_mainframe <- do.call("rbind", dct_calc_frame)
  sd_prop_mainframe <- do.call("rbind", sd_prop_frame)

  # make expanded df
  dctMelt <- melt(as.matrix(dct_mainframe), id.vars = rownames(dct_mainframe))
  sdPropMelt <- melt(as.matrix(sd_prop_mainframe), id.vars = rownames(sd_prop_mainframe))
  colnames(sdPropMelt)[3] <- "ErrProp"
  dctErrPropDF <- merge(dctMelt, sdPropMelt)

  ## percent input
  if(method %in% c("i", "input")){
    dctErrPropDF$percent_input <- 100*2^(dctErrPropDF$value)
    dctErrPropDF$percent_min <- 100*2^(dctErrPropDF$value - dctErrPropDF$ErrProp)
    dctErrPropDF$percent_max <- 100*2^(dctErrPropDF$value + dctErrPropDF$ErrProp)
    colnames(dctErrPropDF)[3] <- "dCT"
  }

  ## fold enrichment
  if (method %in% c("fe", "fold enrichment")){
    dctErrPropDF$fold_enrichment <- 2^-(dctErrPropDF$value)
    dctErrPropDF$enrichment_min <- 2^-(dctErrPropDF$value + dctErrPropDF$ErrProp)
    dctErrPropDF$enrichment_max <- 2^-(dctErrPropDF$value - dctErrPropDF$ErrProp)
    colnames(dctErrPropDF)[3] <- "dCT"
  }


  # return the df
  return(dctErrPropDF)
}
