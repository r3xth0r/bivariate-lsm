#!/usr/bin/R

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# create bivariate map
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

suppressPackageStartupMessages({
  library("sf")
  library("stars")
  library("dplyr")
  library("tidyr")
  library("ggplot2")
  library("ggspatial")
  library("patchwork")
  library("biscale")
  library("showtext")
  library("tictoc")
})

font_add("Source Sans Pro", "~/.fonts/source-sans-pro/SourceSansPro-Regular.ttf")
showtext_auto()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# helper functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

source("R/sfc_as_cols.R")
source("R/custom_bi_class.R")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# explore color palettes
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

dims <- 3
pals <- c("Bluegill", "BlueGold", "BlueOr", "BlueYl", "Brown", "DkBlue", "DkCyan", "DkViolet", "GrPink", "PinkGrn", "PurpleGrn", "PurpleOr")
pal <- pals[8]
p_pals <- lapply(pals, bi_pal, dim = dims)
p_biscale <- wrap_plots(p_pals)
ggsave(filename = "plt/biscale_pals.png", plot = p_biscale, width = 133, height = 100, units = "mm")
# the most suitable palettes seem to be c("Brown", "PurpleOr", "GrPink", "DkViolet")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# data preparation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

aoi <- read_sf("dat/raw/aoi/aoi_small.geojson")
lake_mask <- read_sf("dat/interim/lakes_aoi_large.geojson") |>
  st_intersection(aoi)
elev_mask <- read_sf("dat/interim/high_elev_mask.geojson")

susc_brks <- c(0, 0.4481, 0.6096, 1)

# sf w/ point
res_point <- read_stars("dat/processed/susceptibility.tif") |>
  st_as_sf(as_points = TRUE) |>
  rename(susceptibility = mean, uncertainty = sd)

# sf w/ poly
res_poly <- res_point |>
  st_rasterize() |>
  st_as_sf() |>
  custom_bi_class(brks = susc_brks)

# simple tibble w/o geometry
res_point <- res_point |>
  custom_bi_class(brks = susc_brks) |>
  sfc_as_cols(drop_geometry = TRUE) |>
  as_tibble()

# full data
# tic()
# res_full <- qs::qread("dat/interim/mod_obs.qs", nthreads = 16L) |>
#   rename(susceptibility = mean_susc, uncertainty = sd_susc) |>
#   select(-slide) |>
#   custom_bi_class(brks = susc_brks)
# toc()
# 45 seconds elapsed

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# plotting
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Alternative 1: plot points with geom_raster
map_raster <- ggplot() +
  geom_raster(data = res_point, mapping = aes(x = x, y = y, fill = bi_class), show.legend = FALSE) +
  geom_sf(data = lake_mask, fill = "white", color = "white") +
  geom_sf(data = elev_mask, fill = "white", color = "white", alpha = 0.8) +
  bi_scale_fill(pal = pal, dim = dims) +
  theme_linedraw() +
  coord_sf(crs = 3416, expand = 0) +
  xlab("") +
  ylab("") +
  theme(text = element_text(family = "Source Sans Pro", size = 30))

# map_raster <- map_raster +
#   annotation_scale(
#     location = "bl",
#   ) +
#   annotation_north_arrow(
#     location = "tr",
#     pad_x = unit(0.1, "in"),
#     pad_y = unit(0.1, "in"),
#     style = north_arrow_fancy_orienteering
#   )

tic()
map_raster
toc()

# Alternative 2: plot polygons with geom_sf()
# CAVE: this is substantially slower
# map_sf <- ggplot() +
#   geom_sf(data = res_poly, mapping = aes(fill = bi_class), lwd = 0, show.legend = FALSE) +
#   bi_scale_fill(pal = pal, dim = dims) +
#   theme_linedraw()
# tic()
# map_sf
# toc()

legend <- bi_legend(
  pal = pal,
  dim = dims,
  xlab = "susceptibility",
  ylab = "uncertainty",
  size = 8
) +
  theme(text = element_text(family = "Source Sans Pro", size = 20))

p <- map_raster + legend + plot_layout(widths = c(7, 1))

ggsave(filename = "plt/bivariate_map_R.png", plot = p, width = 220, height = 100, units = "mm")
