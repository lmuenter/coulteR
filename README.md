# coulteR <img src="man/figs/logo.png" align="right" width="120" />

This package interfaces R with data from the Z2 Coulter Counter. The aim is to make [AccuComp](https://www.beckman.de/flow-cytometry/software/383550)-datasets usable in R.
First, per-sample datasets are exported into a readable format (.xls) using `AccuComp`. Next, these datasets are parsed for semantic table boundaries. Lastly, individual tables are extracted into tidy dataframes. For binned measurements of these datasets, `{coulteR}` enables peak detection with an *a priori* particle diameter. Weighted mean and standard deviation of target distributions can be used for further analyses.

## Installation

Install from GitHub:

``` R
devtools::install_github("lmuenter/coulteR")
```

## Basic Usage
In this demonstration, we will extract the `summary` module from our AccuComp-tables. Per sample, this module provides an overview over general statistics of the experiment.

``` R
# load package
library(coulteR)

# set the path to your files
exp_dir = "data/z2/"

# load all summarise
summaries.df = bulk_read(exp_dir, module = "summary")
```

We can then extract e.g. the mean particle size for our datasets.
``` R
means.df = summaries.df %>%
  filter(var == "Mean") %>%  # retain only mean particle size
  select(-var)               # optional: delete column `var`
```

## Peak detection and selection
In addition to overall sample statistics, `AccuComp`-datasets contain binned measurements of particle size. If a non-uniform distribution of particle sizes is present, e.g. with axenic cultures or coagulated cells, peak detection can be used to compute parameters of a specific distribution.

![Figure 1: Peak detection of number of cells and binned diameter. First, the binned measurement track is extracted. Next, a target peak using an *a priori* diameter is detected. Lastly, distribution parameters are computed by weighting with the number of cells.](man/figs/peak_detection.png)

### 1. Extract `measurements`
We start by extracting the `measurements`-module. This module contains binned measurements of diameter, number of cells and a few other parameters of our sample.
``` R

# extract the module `measurements` for each dataset
measurements.df = bulk_read(exp_dir, module = "measurements")

# show measurements
measurements.df[c(7:13),]
```

``` R
   bin diameter.bin.um number.diff number.diff.ml volume.diff.perc sample
10   7         3.05711           0              0         0.000000      A
11   8         3.21810           0              0         0.000000      A
12   9         3.36441           2            200         0.016526      A
13  10         3.49952          71           7100         0.655752      A
14  11         3.62444          37           3700         0.377656      A
15  12         3.74130           9            900         0.100618      A
16  13         3.85172           9            900         0.109375      A

```
Where `bin` denotes the bin number, `diameter.bin.um` the diameter of the bin, `number.diff` the number of particles, `number.diff.ml` the number of cells per ml. Please note the peak in the number of cells at about 3 um.

### 2. Extract the target peak
Now we will extract and compute distribution parameters of our target peak. In this example, we observed a pronounced peak at around 3 um. To properly characterise the parameters of this tarket distribution of cell sizes, we however need to counteract binning effects. For this, we compute the weighted mean and standard deviation of the particle diameter:

```R

# Approximate diameter of target organisms (here in um)
diameter = 3

# Detect all peaks close to target size
measurements.peaks = bulk_peak_detect(measurements.df, diameter = diameter)

# display result
measurements.peaks
```

``` R
  sample  d.peak d.range.start d.range.end n.cells d.wtdmean    d.wtdsd
1      A 3.49952       3.21810     3.74130     119  3.554376 0.08140310
2      B 3.62444       3.21810     4.14914     697  3.678880 0.18246395
3      C 3.49952       3.21810     3.85172      86  3.563902 0.11228003
4      D 3.11919       2.72458     3.61375     605  3.217490 0.14579105
5      E 3.11919       2.72458     3.52583     107  3.119194 0.12749893
6      F 3.62444       3.36441     3.85172      78  3.598619 0.09493823
7      G 3.23034       2.86862     3.85557     635  3.309034 0.16519370
8      H 3.49952       3.21810     3.85172      56  3.577974 0.10170359
``` 
For the target peak of each sample, this `dataframe` contains:

* `d.peak` peak of the target distribution, binned diameter
* `d.range.start` start of target distribution, binned diameter
* `d.range.end` end of target distribution, binned diameter
* `n.cells` number of cells in target distribution
* `d.wtdmean` weighted mean of particle diameter of the target distribution. *Use this for further analysis!*
* `d.wtdsd` weighted standard deviaton of particle diameter of the target distribution. *Use this for further analysis!*


### 3. Plot tracks with highlighted Target Peak

Now we can visualise some tracks with highlighted target peaks. These plots may be useful to determine the success of our extraction method:

``` R
ggtrack(measurements.df, measurements.peaks, N = 4, show.legend = FALSE)

```
![](man/figs/Rplot.png)

## Options
When using `coulteR::read_accucomp()`, other modules can be imported by specifying the parameter `module`. These are:

|module |content |value
--- | --- | ---
|`all`|All modules|A `list` of `dataframes`
|`settings`|Experimental setup (device, duration, aperture etc.)|A two-column `dataframe`
|`summary`|Summary Statistics of the sample (e.g. Mean Particle Size)|A two-column `dataframe`
|`sizes_absolute`|Size Distribution|A two-column `dataframe`
|`sizes_summary`|Another Size Distribution|A two-column `dataframe`
|`volumes` |Cell Volume (fL)|A two-column `dataframe`
|`measurements`|Measurement Distribution(binned)|A 7-column `dataframe`

## Imports

  `dplyr`, `ggplot2`, `Hmisc`, `magrittr`, `pracma`, `stringr`
