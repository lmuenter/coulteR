% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{bulk_read}
\alias{bulk_read}
\title{Bulk Read}
\usage{
bulk_read(path, module, dataframe = TRUE)
}
\arguments{
\item{path}{Full path to the directory containing accucomp-files}

\item{module}{Set if you want a specific module (A module). Options: one of `c("all", "settings", "summary", "sizes_absolute", "sizes_summary", "volumes", "measurements")`. Default: `"all"`}

\item{dataframe}{Should Output be coerced to a dataframe? Default: `TRUE`. Note that this can only be done for modules which are not`"all"`}
}
\description{
Load accucomp-files in Bulk.
}
