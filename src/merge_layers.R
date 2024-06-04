#!/usr/bin/R

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# merge mean and sd layers in one GeoTIFF
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

library("stars")

susc_m <- read_stars("dat/interim/susceptibility_mean.tif") |>
  setNames("mean")
susc_s <- read_stars("dat/interim/susceptibility_sd.tif") |>
  setNames("sd")

susc <- c(susc_m, susc_s) |>
  merge(name = "metric")
write_stars(obj = susc, dsn = "dat/processed/susceptibility.tif")
