################################
#
# Utility Functions
#
################################

# purpose: Utility functions for data wrangling
# author: Lukas Muenter
# date: 17.02.2021

#' Bulk Read
#'
#' Load accucomp-files in Bulk.
#' @param path Full path to the directory containing accucomp-files
#' @param module Set if you want a specific module (A module). Options: one of `c("all", "settings", "summary", "size_absolute", "size_summary", "volume", "measurements")`. Default: `"all"`
#' @param dataframe Should Output be coerced to a dataframe? Default: `TRUE`. Note that this can only be done for modules which are not`"all"`
#' @importFrom stringr str_extract
#' @export
bulk_read = function(path, module, dataframe = TRUE){

  ## test input
  if(!module %in% c("all", "settings", "summary", "size_absolute", "size_summary", "volume", "measurements")){

    stop("Error: module not recognised. Please choose one of: `c('all', 'settings', 'summary', 'size_absolute', 'size_summary', 'volume', 'measurements'`")

  }

  ## list files
  files = list.files(path, full.names = TRUE, pattern = ".XLS")


  ## get selected module for each dataset
  module.ls = lapply(files, read_accucomp, module = module)

  ## generate IDs from filenames
  filenames = files %>% str_extract("[^/]+$") %>% # retain only filename
    gsub(".XLS", "", .) %>%                       # remove extension
    gsub("#", "", .)                              # delete special characters

  ## if module is not a list (i.e. in `module = "all"`), concatenate dataframes with an ID
  if(module != "all" & dataframe == TRUE){

    ### output as `dataframe`
    return(

      module.ls %>%
        setNames(filenames) %>%              # name each dataset after its sample
        listnames_to_column("sample") %>%    # introduce a new column `sample`
        do.call("rbind", .)

    )

  } else {

    ### output as `list`
    return(module.ls)

  }


}

#' Add ID column (list element names)
#'
#' In a list of dataframes, add an ID column with the list name. Neat, if you want a dataframe instead of list object.
#' @param ls A named list of dataframes
#' @param colname The name of the column to add IDs to
#' @export
listnames_to_column = function(ls, colname = "sample"){

  lapply(names(ls), function(x,y,z){

    x[[z]][[y]] = rep(z, nrow(x[[z]]))
    return(x[[z]])

  }, x = ls, y = colname)

}
