# Package `coulteR` 

This package provides functions for importing data from the Z2 Coulter Counter into R. The aim is to make datasets generated with [AccuComp](https://www.beckman.de/flow-cytometry/software/383550) usable in R.
First, per-sample datasets are exported into a readable format (.xls) using `AccuComp`. Next, these untidy datasets are parsed for semantic table boundaries. Lastly,  individual tables are extracted into tidy dataframes.

# Installation

Install from the github-repository:

``` R
devtools::install_github("lmuenter/coulteR")
```

# Example Usage
In this demonstration, we will extract the `summary` module from our AccuComp-tables. Per sample, this module provides an overview over general statistics of the experiment.

1. Load the required libraries:

``` R
library(tidyverse) # used for naming of list objects
library(coulteR)
```

2. Bulk Read your datasets.

``` R
input = "data"                                  # Path to folder with AccuComp-datasets

files = list.files(input, full.names = TRUE)    # list filepaths
```

3. From each dataset, load the module `summary` into a list of dataframes

``` R
summaries.ls = lapply(files, read_accucomp, module = "summary")
```

4. Generate IDs from file names. These are later used to tidy the data

``` R
filenames = files %>% str_extract("[^/]+$") %>% # retain only filename
  gsub(".XLS", "", .) %>%                       # remove extension
  gsub("#", "", .)                              # delete special characters
```

5. Concatenate the dataframes. For this, we give each sample a unique ID (the sample name).
``` R
summaries.df = summaries.ls %>%
  setNames(filenames) %>%              # name each dataset after its sample
  listnames_to_column("sample") %>%    # introduce a new column `sample`
  do.call("rbind", .) %>% 
```

6. Extract Mean Particle Size. In this example, we only want to retain the mean particle size per sample.
``` R
means.df = summaries.df %>%
  filter(var == "Mean") %>%  # retain only mean particle size
  select(-var)               # optional: delete column `var`
```

# Options
When using `coulteR::read_accucomp()`, other modules can be imported by specifying the parameter `module`. These are:

|module |content |value
--- | --- | ---
|`all`|All modules|A `list` of `dataframes`
|`settings`|Experimental setup (device, duration, aperture etc.)|A two-column `dataframe`
|`summary`|Summary Statistics of the sample (e.g. Mean Particle Size)|A two-column `dataframe`
|`size_absolute`|Size Distribution|A two-column `dataframe`
|`size_summary`|Another Size Distribution|A two-column `dataframe`
|`volume` |Cell Volume (fL)|A two-column `dataframe`
|`measurements`|Measurement Distribution(binned)|A 7-column `dataframe`

