
<!-- README.md is generated from README.Rmd. Please edit that file -->
WARPqpcr
========

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/sccallahan/WARPqpcr.svg?branch=master)](https://travis-ci.org/sccallahan/WARPqpcr) <!-- badges: end -->

**W**eb **A**pp and **R** **P**ackage for qPCR (WARPqpcr) provides functionality for analyzing qPCR data using the dCT and ddCT methods and generating plots of results. This package also contains functions for finding the most stable housekeeping gene from a group of possible genes.

The goal of this package is to allow rapid, reproducible analysis of qPCR data, particularly in the molecular biology setting, to provide easy functions for visualizing results, and to provide a tool for selecting the best housekeeping gene from a list of candidates. Many of the functions in this package rely on the ReadqPCR and NormqPCR packages for calculations, and the housekeeping gene stability is an implementation of an existing method (references for all of this are at the end of the README!)

Installation
------------

You can install the released version of WARPqpcr from [this repo](https://github.com/sccallahan/WARPqpcr) with:

``` r
# install devtools if needed -- must have for installing from github
install.packages("devtools")

# now install WARPqpcr
install_github("sccallahan/WARPqpcr")
```

Some notes about samplesheet format and methods
-----------------------------------------------

#### Samplesheet format and reading in data

The format for the samplesheet is described in the [ReadqPCR documentation.](https://www.bioconductor.org/packages/release/bioc/vignettes/ReadqPCR/inst/doc/ReadqPCR.pdf) In short, it requires 5 columns in a *tab-delimited* file:

-   Well. The well letter/number.
-   Plate. The plate number.
-   Sample. The name of the sample being analayzed. It is *critical* that biological replicates have unique identifiers (e.g. "WT\_1" and "WT\_2" instead of just "WT" for both). Samples with identical names will be treated as technical replicates.
-   Detector. The gene being measured.
-   Cq. The Ct/Cq value for the well. These values *must* be either numerics or NAs.

The `readSampleSheet` function assumes that the data is formatted as above and each sample is measuring the same genes with the same number of replicates per gene per sample (i.e. all genes measured must be in all samples, and each gene must have equal numbers of replicates). If you end up needing to discard replicates for certain genes/samples because they fail QC or the qPCR reaction failed, please leave the wells as just NAs instead of deleting the data. If your machine outputs non-NA values for wells where nothing was measured, please use the `readSampleSheet_NoCT` function to convert the data to NAs.

#### Methods

The methods for biological replicates can be found in the [NormqPCR documentation](https://www.bioconductor.org/packages/release/bioc/vignettes/NormqPCR/inst/doc/NormqPCR.pdf). In short:

-   The `singleRep` functions use the SD from the inital technical replicate merging to propagate error for downstream calculations.
-   The `bioRep` functions ignore technical replicate SD for error propagation - the `calcCV` function is provided to use the coefficient of variation as a filter for technical replication. The error propagation begins with calculating the mean and SD of biological replicates. The final ddCT subtraction is treated as subtraction from an arbitrary constant for error propagation.

Example for single (biological) replicate data
----------------------------------------------

This mode is only recommended for pilot data or cases where several constructs (shRNA, overexpression, etc.) are being screened for efficiency. *No statistics are calculated* because there are no biological replicates. While statistics could be computed on this data, I do not feel comfortable recommending that approach, as it is simply measuring the user's pipetting error.

``` r
suppressPackageStartupMessages(library(WARPqpcr))

# read in the qPCR data
sampleObj <- readSampleSheet(system.file("extdata", "samplesheet_singleRep.csv", package = "WARPqpcr"))

# take a look at raw values
rawct <- getRawCT(sampleObj = sampleObj)

# calculate average values and coefficient of variation (CV)
# This step is HIGHLY RECOMMENDED. The CV allows for a measure of technical replicate consistency 
avgCT <- getAvgCT(sampleObj = sampleObj)
avgCT <- calcCV(avgCtObj = avgCT)
#> All samples passed the CV threshold!

# if we want, we can make a plot of these avgCT values
plotAvgCT(avgCtObj = avgCT, theme_classic = TRUE, title = "Avg CT")
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

``` r

# calculate dCT values and plot them
# we can assign our HKG to a vector or pass it as an argument directly
hkg <- "HKG"
dct <- get_dCT_singleRep(sampleObj = sampleObj, hkg = hkg)
plot_dCT_singleRep(dct, theme_classic = TRUE, title = "dCT values")
```

<img src="man/figures/README-unnamed-chunk-3-2.png" width="100%" />

``` r

# Now we can calculate ddCT values and plot -- this is typically the end result desired
# We can technically skip straight to this step, but calculating the CV first is recommended
# we need to indicate which sample is the control
control <- "NT"
ddct <- get_ddCT_singleRep(sampleObj = sampleObj, rel.exp = TRUE, hkg = hkg, control = control) # same hkg as the dCT step above
plot_ddCT_singleRep(ddct, theme_classic = TRUE, rel.exp = TRUE, title = "Relative Expression (ddCT)")
```

<img src="man/figures/README-unnamed-chunk-3-3.png" width="100%" />

Example for biological replicate data
-------------------------------------

``` r
suppressPackageStartupMessages(library(WARPqpcr))

# read in the qPCR data
sampleObj <- readSampleSheet(system.file("extdata", "samplesheet_bioReps.csv", package = "WARPqpcr"))

# check raw values
rawct <- getRawCT(sampleObj = sampleObj)

# merge technical replicates and plot
avgct <- getAvgCT(sampleObj = sampleObj)
avgct <- calcCV(avgct)
#> 3 samples have CV over the threshold, there may be issues with technical replication
#> Check CV column for affected samples and raw data for outlying replicates
# samples have higher CVs; for the sake of example we will continue, but in real data this should be investigated
plotAvgCT(avgct, title = "Avg CT values")
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

``` r

# set our housekeeping gene and calculate dCT
hkg <- "HKG"
dct <- get_dCT_bioReps(sampleObj = sampleObj, hkg = hkg)

# since we have biological replicates, we can calculate significance
# stats should be performed on these dCT values
signifTest <- signifTest(dCTObj = dct, gene.name = "GeneA", var.equal = FALSE)
#> The p.value for GeneA is 0.0338599629076486
#> p.value is SIGNIFICANT with p < 0.05!

# now we can calculate the ddCT to get expression changes and make plots
# we will do both relative expression and log2 fold-change for the sake of demonstration

# RELATIVE EXPRESSION
relExp <- get_ddCT_bioReps(sampleObj = sampleObj, cond.1 = "KD", cond.2 = "LUC", reps.cond.1 = 3, reps.cond.2 = 3,
                 hkg = hkg, rel.exp = TRUE)
plot_ddCT_bioReps(ddCTobj = relExp, theme_classic = TRUE,
                  rel.exp = TRUE, title = "Relative Expression (ddCT)") #NB: rel.exp value must match data type
```

<img src="man/figures/README-unnamed-chunk-4-2.png" width="100%" />

``` r

# LOG2 FOLD-CHANGE
absExp <- get_ddCT_bioReps(sampleObj = sampleObj, cond.1 = "KD", cond.2 = "LUC", reps.cond.1 = 3, reps.cond.2 = 3,
                 hkg = hkg, rel.exp = FALSE)
plot_ddCT_bioReps(ddCTobj = absExp, theme_classic = TRUE,
                  rel.exp = FALSE, title = "log2 fold-change (ddCT)") #NB: rel.exp value must match data type
```

<img src="man/figures/README-unnamed-chunk-4-3.png" width="100%" />

Example for selecting most stable housekeeping gene
---------------------------------------------------

``` r
suppressPackageStartupMessages(library(WARPqpcr))

# read in the qPCR data
sampleObj <- readSampleSheet(system.file("extdata", "samplesheet_hkgStab.csv", package = "WARPqpcr"))

# get average CT values
avgCT <- getAvgCT(sampleObj = sampleObj)

# calculate stability values
hkgs <- c("gene1", "gene2", "gene3", "gene4")
hkgStab <- calcStab(avgCTobj = avgCT, hkgs = hkgs)
head(hkgStab)
#>              V1
#> gene4 0.4562171
#> gene3 0.4562171
#> gene2 0.5965916
#> gene1 0.9475278
```

References
----------

-   [ReadqPCR and NormqPCR](https://bmcgenomics.biomedcentral.com/articles/10.1186/1471-2164-13-296)
-   [Selection of housekeeping genes for gene expression studies in human reticulocytes using real-time PCR](https://www.ncbi.nlm.nih.gov/pubmed/17026756)

To do
-----

-   \[ \] Port to Shiny App
-   \[ \] ChIP-qPCR analysis module