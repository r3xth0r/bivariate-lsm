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
  library("tictoc")
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# helper functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

sfc_as_cols <- function(x, geometry, names = c("x", "y"), drop_geometry = FALSE) {
  #' Add geometry to dataframe as separate numeric columns.
  #'
  #' @description Extracts the geometry of an sf-object with geometry type POINT
  #' and adds it as dedicated columns. The geometry column can be dropped optionally.
  #'
  #' @param x sf-object to extract the geometry from.
  #' @param geometry character. Name of the geometry column. The geometry is
  #' guessed from the sf object using sf::st_geometry() if not provided.
  #' @param names character. Names of the coordinates, defaults to `c("x", "y")`.
  #' @param drop_geometry logical. Keep (default) or drop geometry column after extraction.
  #'
  #' @usage sfc_as_cols(x)
  #' @return Input object with coordinates added as numeric columns.
  if (missing(geometry)) {
    geometry <- sf::st_geometry(x)
  } else {
    geometry <- rlang::eval_tidy(enquo(geometry), x)
  }
  stopifnot(inherits(x, "sf") && inherits(geometry, "sfc_POINT"))
  ret <- sf::st_coordinates(geometry)
  ret <- tibble::as_tibble(ret)
  stopifnot(length(names) == ncol(ret))
  x <- x[, !names(x) %in% names]
  ret <- setNames(ret, names)
  out <- dplyr::bind_cols(x, ret)
  if (drop_geometry) {
    out <- st_drop_geometry(out)
  }
  out
}

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

# sf w/ point
res_point <- read_stars("dat/processed/susceptibility.tif") |>
  st_as_sf(as_points = TRUE) |>
  rename(susceptibility = mean, uncertainty = sd)

# TODO: different class thresholds [argument "style" in `biscale::bi_class()`]
susc_brks <- c(0, 0.4481, 0.6096, 1)
# This is handled by biscale:::bi_var_cut() which effectively uses
# classInt::classIntervals()$brks to derive the breaks which are passed on to
# base::cut().
bi_class_breaks(res_point, x = susceptibility, y = uncertainty, style = "quantile", dim = dims)
classInt::classIntervals(res_point$uncertainty, n = dims, style = "quantile")$brks

tst <- res_point |>
  st_drop_geometry() |>
  as_tibble() |>
  bi_class(x = susceptibility, y = uncertainty, style = "quantile", dim = dims) |>
  mutate(
    bc_s = cut(susceptibility, breaks = susc_brks, include.lowest = TRUE, dig.lab = 3),
    bc_u = cut(uncertainty, breaks = classInt::classIntervals(
      uncertainty,
      n = dims, style = "quantile"
    )$brks, include.lowest = TRUE, dig.lab = 3)
  ) |>
  mutate(across(starts_with("bc_"), as.integer)) |>
  unite("bi_cl", bc_s:bc_u, sep = "-")

# sf w/ poly
res_poly <- res_point |>
  st_rasterize() |>
  st_as_sf() |>
  bi_class(x = susceptibility, y = uncertainty, style = "quantile", dim = dims)

# simple tibble w/o geometry
res_point <- res_point |>
  bi_class(x = susceptibility, y = uncertainty, style = "quantile", dim = dims) |>
  sfc_as_cols(drop_geometry = TRUE) |>
  as_tibble()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# plotting
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Alternative 1: plot points with geom_raster
map_raster <- ggplot() +
  geom_raster(data = res_point, mapping = aes(x = x, y = y, fill = bi_class), show.legend = FALSE) +
  bi_scale_fill(pal = pal, dim = dims) +
  theme_linedraw() +
  coord_sf(crs = 3416, expand = 0) +
  xlab("") +
  ylab("")

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
)

p <- map_raster + legend + plot_layout(widths = c(7, 1))

ggsave(filename = "plt/bivariate_map_R.png", plot = p, width = 220, height = 100, units = "mm")
