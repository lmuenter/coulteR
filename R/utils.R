################################
#
# Utility Functions
#
################################

# purpose: Utility functions for data wrangling
# author: Lukas Muenter
# date: 17.02.2021

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
