###############################
#
# AccuComp Parser
#
###############################

# purpose: A parser for Coulter's dirty AccuComp format
# date: 17.02.2021
# author: Lukas Muenter


#' Read Coulter Results
#'
#' This function reads AccuComp-tables of Coulter Counter
#' @import dplyr
#' @param x Path to Accucomp .XLS file
#' @param module Set if you want a specific module (A module). Options: all, settings, summary, size_absolute, size_summary, volume, measurements. Default: all
#' @return A list of tibbles (each module is a tibble) or a single dataframe (if you specified a specific module)
#' @export
read_accucomp2 = function(x, module = "all"){

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

  if(module != "all" & module != "measurements"){

    out = get_module2(x,
                     start   = modules.dict[[module]]$start,
                     end     = modules.dict[[module]]$end,
                     varname = modules.dict[[module]]$vars,
                     clean   = TRUE,
                     tidy    = modules.dict[[module]]$tidy,
                     trim    = modules.dict[[module]]$trim,
                     values_numeric = modules.dict[[module]]$values_numeric)

  } else if(module == "measurements"){

    out = get_measurements2(x) %>%
      mutate_if(is.character, as.numeric)

  } else {

    out = lapply(modules, function(a,y,z){

      get_module2(z,
                 start   = y[[a]]$start,
                 end     = y[[a]]$end,
                 varname = y[[a]]$vars,
                 clean   = TRUE,
                 tidy    = y[[a]]$tidy,
                 trim    = y[[a]]$trim,
                 values_numeric = y[[a]]$values_numeric)

    }, y = modules.dict, z = x) %>%
      setNames(modules)

    out$measurements = get_measurements2(x) %>%
      mutate_if(is.character, as.numeric)

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
#' @param trim Should output table be trimmed? Default NULL, else two-element numeric vector (specifying head and tail cutoff)
#' @param values_numeric Should values (second column) be transformed to numeric values?
get_module2 = function(x, start, end, varnames, clean = FALSE, tidy = TRUE, trim = NULL, values_numeric = FALSE){

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

  if (!is.null(trim)){

    file.filt.clean = file.filt.clean %>%
      head(., trim[1]) %>%
      tail(., trim[2])

  }

  if (values_numeric){

    file.filt.clean[[varnames[2]]] = as.numeric(file.filt.clean[[varnames[2]]])


  }

  ## spuck aus
  return(file.filt.clean)

}

#' Get Measurements from AccuComp-table
#'
#' Load Measurements from AccuComp-table (last element in file).
#' @importFrom stringr str_split
#' @param x filepath to AccuComp-table
get_measurements2 = function(x){

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
