###############################
#
# Coulter Reader
#
###############################

# purpose: A parser for Coulter's dirty AccuComp format
# date: 16.02.2021
# author: Lukas Muenter

#' Read Coulter Results
#'
#' This function reads AccuComp-tables of Coulter Counter
#' @import stringr
#' @param x Path to Accucomp .XLS file
#' @param module Set if you want a specific module (A module). Options: all, settings, summary, size_absolute, size_summary, volume, measurements. Default: all
#' @return A list of tibbles (each module is a tibble) or a single dataframe (if you specified a specific module)
#' @export
read_accucomp = function(x, module = "all"){

  ## check input
  if(length(x) > 1){
    stop(paste("Error: More than one input file provided. Please give ONE filepath (chr)"))
  }

  if(!is.character(x)){
    stop(paste("Error: Input must be filepath (chr)"))
  }

  if(length(module) > 1){
    stop(paste("Error: Option 'module' - More than one input given. Option 'module' should be one of c('all', ''settings', 'summary', 'sizes_absolute', 'sizes_summary', 'volumes')"))
  }

  ## start- and endpoints for overview tables (HARDCODED)
  settings.start = "File name:"
  settings.end = "Raw count:"
  summary.start = "From"
  summary.end = "Specific Surf. Area:"
  sizes_absolute.start = c("% >", "Size")
  sizes_absolute.end = c("Size", "% >")
  sizes_summary.start = c("Size", "% >")
  sizes_summary.end = c("Number", "Cell Volume")
  volumes.start = c("Number", "Cell Volume")
  volumes.end = c("Bin Number", "Bin Diameter")

  ## load modules (= Subtables of AccuComp file)
  settings = get_module(x, settings.start, settings.end, c("option", "value"), clean = TRUE, tidy = FALSE)
  summary = get_module(x, summary.start, summary.end, c("var", "value"), clean = TRUE, tidy = FALSE)
  sizes_absolute = get_module(x, sizes_absolute.start, sizes_absolute.end, c("bin", "size"), clean = TRUE) %>% head(., -1) %>% tail(., -1)
  sizes_summary = get_module(x, sizes_summary.start, sizes_summary.end, c("size", "p.size"), clean = TRUE) %>% head(., -1) %>% tail(., -1)
  volumes = get_module(x, volumes.start, volumes.end, c("number", "volume"), clean = TRUE) %>% head(., -1) %>% tail(., -2)
  measurements = get_measurements(x)

  if(module == "all"){

    out = list(
      "settings" = settings,
      "summary" = summary,
      "sizes_absolute" = sizes_absolute,
      "sizes_summary" = sizes_summary,
      "volumes" = volumes,
      "measurements" = measurements
    )

  } else {

    out = eval(as.name(module)) ## only output module name

  }

  return(out)

}

#' Extract Summary Tables
#'
#' Extracts Summary tables from AccuComp-table
#' @param x Filepath to AccuComp-table (.XLS)
#' @param start Start-term to look for. Character vector one or two elements.
#' @param end end-term to look for. Character vector one or two elements.
#' @param varnames Desired column names of output.
#' @param clean Should output be cleaned from trailing ":"?
#' @param tidy Is input tidy (i.e. two variable names are present?)
get_module = function(x, start, end, varnames, clean = FALSE, tidy = TRUE){

  ## extract
  file = read.delim(x, sep = "\t", stringsAsFactors = FALSE, na.strings = "")
  file[[1]] = gsub("[ ]+$", "", file[[1]])
  file[[2]] = gsub("[ ]+$", "", file[[2]])

  ## check, if we have proper variable names (two named columns)
  ## if not, search only first column for regexs
  ## if yes, search also second column

  if(!tidy){
    idx = c(grep(x = file[[1]], pattern = start),
            grep(x = file[[1]], pattern = end)[1])
  } else{
    idx = c(which(file[[1]] == start[1] & file[[2]] == start[2]),
            which(file[[1]] == end[1] & file[[2]] == end[2]))
  }

  ### filter table
  file.filt = file[c(idx[1]:idx[2]),]
  file.filt.clean = file.filt %>%
    setNames(varnames)

  ### clean table
  if (clean){

    file.filt.clean[[varnames[1]]] = gsub("[:]+$", "", file.filt.clean[[varnames[1]]])

  }

  ## spuck aus
  return(file.filt.clean)

}

#' Get Measurements from AccuComp-table
#'
#' Load Measurements from AccuComp-table (last element in file).
#' @importFrom stringr str_split
#' @param x filepath to AccuComp-table
get_measurements = function(x){

  start = "Bin Number"
  varnames = c("bin", "diameter.bin.um", "number.diff", "number.diff.ml", "volume.diff.perc")

  ## extract dataframe
  file = readLines(x)
  idx = grep(start, file)
  file.df = file[idx:length(file)] %>%
    str_split("\t", simplify = TRUE) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    tail(-3) %>%
    head(-1) %>%
    setNames(varnames)
  file.df[file.df == ""] = NA

  ## spuck aus
  return(file.df)
}
