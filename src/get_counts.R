#!/usr/bin/R

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# counts per class
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

suppressPackageStartupMessages({
  library("dplyr")
  library("ggplot2")
  library("ggmosaic")
  library("biscale")
  library("showtext")
})

font_add("Source Sans Pro", "~/.fonts/source-sans-pro/SourceSansPro-Regular.ttf")
showtext_auto()

ncores <- 16L
w <- 150
h <- 120

susc_brks <- c(0, 0.4481, 0.6096, 1)

res <- qs::qread("dat/interim/mod_obs.qs", nthreads = 16L) |>
  rename(susceptibility = mean_susc, uncertainty = sd_susc) |>
  mutate(
    bc_s = cut(susceptibility, breaks = susc_brks, include.lowest = TRUE, dig.lab = 3),
    bc_u = cut(uncertainty, breaks = classInt::classIntervals(
      uncertainty,
      n = 3, style = "quantile"
    )$brks, include.lowest = TRUE, dig.lab = 3)
  ) |>
  mutate(across(starts_with("bc_"), \(x) ordered(as.integer(x), levels = 1:3, labels = c("low", "medium", "high"))))

res_agg <- res |>
  group_by(bc_s, bc_u) |>
  summarise(cnt = n(), .groups = "drop") |>
  mutate(cnt_f = format(cnt, big.mark = ",", scientific = F))

# heatmap
p <- ggplot(res_agg, aes(x = bc_s, y = bc_u, fill = cnt)) +
  geom_tile(color = "white", linewidth = 2) +
  geom_label(aes(label = cnt_f), family = "Source Sans Pro", fill = "white", size = 10) +
  xlab("mean (class)") +
  ylab("standard deviation (class)") +
  scale_fill_viridis_c(name = "count", option = "magma", breaks = seq(1.0e+06, 1.7e+07, 4e+06), limits = c(1.0e+06, 1.7e+07)) +
  theme_linedraw() +
  theme(panel.grid = element_blank()) +
  coord_equal() +
  theme(
    text = element_text(
      family = "Source Sans Pro",
      colour = "black",
      size = 40
    )
  )
ggsave("plt/class_counts.png", p, width = w, height = h, units = "mm", dpi = 300)

# mosaic plot w/ ggmosaic
p <- ggplot(data = res) +
  geom_mosaic(aes(x = product(bc_u, bc_s))) +
  geom_mosaic_text(aes(x = product(bc_u, bc_s), label = after_stat(.wt)), as.label = TRUE, size = 10) +
  xlab("mean (class)") +
  ylab("standard deviation (class)") +
  theme_linedraw() +
  theme(panel.grid = element_blank()) +
  coord_equal() +
  theme(
    text = element_text(
      family = "Source Sans Pro",
      colour = "black",
      size = 40
    )
  )
ggsave("plt/class_counts_mosaic.png", p, width = w, height = h, units = "mm", dpi = 300)

# alternatives w/ ggplot2:
# - autoplot(yardstick::conf_mat, type = "mosaic")
# - productplots::prodplot()
