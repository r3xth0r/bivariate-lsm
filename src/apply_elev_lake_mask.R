#!/usr/bin/R

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# apply elevation and lake mask to full data set
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

suppressPackageStartupMessages({
  library("dplyr")
  library("sf")
  library("stars")
  library("qs")
})

source("R/sfc_as_cols.R")

lakes <- read_sf("dat/interim/lakes_aoi_large.geojson")

elev <- read_stars("dat/raw/dtm/dtm_carinthia.tif") |>
  st_as_sf(as_points = TRUE) |>
  rename(elev = dtm_carinthia.tif) |>
  sfc_as_cols(drop_geometry = TRUE) |>
  as_tibble() |>
  mutate(elev = if_else(elev >= 1900, TRUE, FALSE)) |>
  mutate(across(x:y, as.integer))

qread("dat/interim/mod_obs.qs", nthreads = 16L) |>
  rename(susceptibility = mean_susc, uncertainty = sd_susc) |>
  left_join(elev, by = c("x", "y")) |>
  filter(!elev) |>
  select(-elev) |>
  st_as_sf(coords = c("x", "y"), crs = st_crs(3416)) |>
  st_filter(lakes, .predicate = st_disjoint) |>
  sfc_as_cols(drop_geometry = TRUE) |>
  qsave("dat/interim/mod_obs_masked.qs", nthreads = 16L)

# before masking:       n = 57,519,784 | 100.00 %
# after masking:        n = 46,803,092 |  81.37 %
