#!/usr/bin/R

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# create 3D snapshot with rayshader
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

library("rayshader")
library("rgl")
library("stars")
library("dplyr")
library("biscale")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

m_brks <- c(0, 0.4481, 0.6096, 1)
s_brks <- c(0, 0.0297, 0.0416, Inf)
lbl <- 1:3 # c("low", "medium", "high")
pal <- bi_pal(pal = "DkViolet", dim = 3, preview = FALSE)

# DTM
dtm <- read_stars("dat/interim/dtm.tif") |>
  rename(elev = dtm.tif) |>
  pull(elev) |>
  units::drop_units()

# susceptibility
susc <- read_stars("dat/processed/susceptibility.tif") |>
  split() |>
  mutate(
    m_class = cut(mean, breaks = m_brks, labels = lbl, include.lowest = TRUE),
    s_class = cut(sd, breaks = s_brks, labels = lbl, include.lowest = TRUE)
  ) |>
  mutate(res = factor(
    x = paste(m_class, s_class, sep = "-"),
    levels = paste(rep(lbl, 3), rep(lbl, each = 3), sep = "-"),
    ordered = TRUE
  ))
# susceptibility overlay for rayshader
ovl <- susc |>
  pull(res) |>
  apply(c(1, 2), as.integer) |>
  height_shade(texture = pal)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

plot_3d(
  # feature
  hillshade = ovl,
  # elevation
  heightmap = dtm,
  # ratio between x/y and z
  zscale = 5,
  # shape of the base
  baseshape = "rectangle",
  # render only surface
  solid = FALSE,
  # render shadow
  shadow = FALSE,
  # render water
  water = FALSE,
  # rotation angle
  theta = 70,
  # azimuth angle
  phi = 40,
  # field of view (0 = isometric)
  fov = 0,
  # camera magnification
  zoom = 1,
  # window size
  windowsize = unname(dim(dtm)),
  # background
  background = "black"
)

# open interactive widget
rgl::rglwidget()

# export html
htmlwidgets::saveWidget(rgl::rglwidget(), "plt/rayshader.html")

# export static snapshot
render_snapshot(filename = "plt/rayshader.png", software_render = TRUE, width = 1920, height = 1080)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
