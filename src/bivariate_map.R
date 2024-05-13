# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# create bivariate map
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

suppressPackageStartupMessages({
  library("sf")
  library("stars")
  library("dplyr")
  library("ggplot2")
  library("ggspatial")
  library("patchwork")
  library("biscale")
  library("tictoc")
})

sfc_as_cols <- function(x, geometry, names = c("x", "y"), drop_geometry = FALSE) {
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

xmin <- 430000
xmax <- 440000
ymin <- 318000
ymax <- 323000

# width:height
(xmax - xmin) / (ymax - ymin)

tic()
aoi <- st_sfc(st_polygon(list(cbind(c(xmin, xmax, xmax, xmin, xmin), c(ymin, ymin, ymax, ymax, ymin)))), crs = 3416)
res <- qs::qread("dat/random_forest_prediction_mean_sd_sf.qs", nthreads = 16L) |>
  st_intersection(aoi)
saveRDS(res, "dat/biscale_test_aoi.rds")
toc()

# the most suitable palettes seem to be c("Brown", "PurpleOr", "GrPink", "DkViolet")
dims <- 3
pals <- c("Bluegill", "BlueGold", "BlueOr", "BlueYl", "Brown", "DkBlue", "DkCyan", "DkViolet", "GrPink", "PinkGrn", "PurpleGrn", "PurpleOr")
pal <- pals[8]
p_pals <- lapply(pals, bi_pal, dim = dims)
p_biscale <- wrap_plots(p_pals)
# ggsave(filename = "plt/biscale_pals.png", plot = p_biscale, width = 133, height = 100, units = "mm")

# TODO: different class thresholds
res_point <- readRDS("dat/biscale_test_aoi.rds") |>
  rename(susceptibility = mean_susc, uncertainty = sd_susc)
res_poly <- res_point |>
  st_rasterize() |>
  st_as_sf() |>
  bi_class(x = susceptibility, y = uncertainty, style = "quantile", dim = dims)
res_point <- res_point |>
  bi_class(x = susceptibility, y = uncertainty, style = "quantile", dim = dims) |>
  sfc_as_cols(drop_geometry = TRUE)

# point
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

# polygon
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

ggsave(filename = "plt/test_map.png", plot = p, width = 220, height = 100, units = "mm")
