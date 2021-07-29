################################
#
# Anticoagulate
#
################################

# purpose: Cleaning coagulated cells using a known diameter and peak finder
# author: Lukas Muenter
# date: 29.07.2021


## analyses ===================

#' Get target peaks per group
#'
#' A wrapper around `coulteR::detect_peaks`. Per group in a dataframe with identifiers, peaks are reported.
#' @param df `dataframe` of coerced measurements-`modules` as produced by `coulteR::bulk_read`.
#' @param diameter The expected diameter of particles
#' @param full_df Should all peaks be reported? default = `FALSE`
#' @importFrom dplyr group_by
#' @importFrom dplyr group_split
#' @return A `dataframe`.
#' @export
bulk_peak_detect = function(df, diameter, full_df = FALSE){

  if(!is.data.frame(df)){

    stop("Error: argument `df` is no dataframe. Did you coerce your modules when using `coulter::bulk_read`?")

  }

  df %>%
    group_by(sample) %>%
    group_split() %>%
    lapply(peak_detect, diameter = diameter, full_df = full_df) %>%
    do.call("rbind", .)

}

#' Detect target peaks
#'
#' This function detects a specific target peak. Optionally, all peaks are reported.
#' @param df A measurements-`module` as produced by `coulteR::read_accucomp`
#' @param diameter The expected diameter of particles
#' @param full_df Should all peaks be reported? default = `FALSE`
#' @return A `dataframe` with the diameter of the peak, the diameter range, and the total number of cells in the range.
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @importFrom dplyr filter
#' @importFrom dplyr pull
#' @importFrom dplyr rename
#' @importFrom pracma findpeaks
#' @export
peak_detect = function(df, diameter, full_df = FALSE){

  peaks = df %>%
    na.omit() %>%
    pull(number.diff) %>%
    findpeaks() %>%
    as.data.frame() %>%
    setNames(c("number.diff", "bin", "bin.start", "bin.end")) %>%
    left_join(df)

  ## identify Target peak
  peaks$target = FALSE
  peaks$target[get_nearest_peak(peaks$diameter.bin.um, diameter)] = TRUE

  ## get size ranges of peaks
  peaks$range.start = df$diameter.bin.um[peaks$bin.start]
  peaks$range.end = df$diameter.bin.um[peaks$bin.end]

  ## get number of cells in distribution
  peaks$n.cells = get_number_cells(df, starts = peaks$bin.start, ends = peaks$bin.end)

  if(full_df == FALSE){

    return(

      peaks %>%
        filter(target == TRUE) %>%
        select(sample, "peak" = diameter.bin.um, range.start, range.end, n.cells)

    )

  } else {

    return(

      peaks %>% rename("peak" = diameter.bin.um)

    )

  }

}

#' Obtain peak nearest to target
#'
#' @param x A numeric vector
#' @param y The target number
#' @return A `number`
get_nearest_peak = function(x, y){

  which(abs(x - y) == min(abs(x - y)))

}

#' Get number of cells in range
#' @param df A `measurements`-module
#' @param starts Indices of start bins
#' @param ends Indices of end bins
#' @return A `vector` of summed cells
get_number_cells = function(df, starts,ends){

  Map(":", starts, ends) %>%
    lapply(function(x,y) sum(df$number.diff[x]),y = df) %>%
    do.call("c", .)

}
