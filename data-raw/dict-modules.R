#######################
#
# Settings dictionary
#
#######################

# purpose: generates a dictionary with settings for specific modules. Speeds up things considerably
# date: 17.02.2021
# author: Lukas Muenter

#' Module Names
modules = c("settings", "summary", "sizes_absolute", "sizes_summary", "volumes")

#' Module Dictionary
#'
#' A dictionary with settings for loading subtables. Should speed up things a bit
modules.dict = list(

  list(

    "start" = "File name:",
    "end"   = "Raw count:",
    "tidy"  = FALSE,
    "vars"  = c("option", "value"),
    "trim"  = NULL,
    "values_numeric" = FALSE

  ),

  list(

    "start" = "From",
    "end"   = "Specific Surf. Area:",
    "tidy"  = FALSE,
    "vars"  = c("var", "value"),
    "trim"  = NULL,
    "values_numeric" = TRUE

  ),

  list(

    "start" = c("% >", "Size"),
    "end"   = c("Size", "% >"),
    "tidy"  = TRUE,
    "vars"  = c("bin", "size"),
    "trim"  = c(-1, -1),
    "values_numeric" = TRUE

  ),

  list(

    "start" = c("Size", "% >"),
    "end"   = c("Number", "Cell Volume"),
    "tidy"  = TRUE,
    "vars"  = c("size", "p.size"),
    "trim"  = c(-1, -1),
    "values_numeric" = TRUE

  ),

  list(

    "start" = c("Number", "Cell Volume"),
    "end"   = c("Bin Number", "Bin Diameter"),
    "tidy"  = TRUE,
    "vars"  = c("number", "volume"),
    "trim"  = c(-1, -2),
    "values_numeric" = TRUE

  )

)

modules.dict = setNames(object = modules.dict, modules)

## make available
usethis::use_data(modules, modules.dict, internal = TRUE)
