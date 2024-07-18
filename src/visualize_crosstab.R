#!/usr/bin/R

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# visualize crosstable of bivariate classes
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

suppressPackageStartupMessages({
  library("dplyr")
  library("ggplot2")
  library("biscale")
  library("showtext")
})

font_add("Source Sans Pro", "~/.fonts/source-sans-pro/SourceSansPro-Regular.ttf")
showtext_auto()

ncores <- 16L
w <- 150
h <- 120

susc_brks <- c(0, 0.4481, 0.6096, 1)

bicols <- biscale:::bi_pal_pull("DkViolet", dim = 3, flip_axes = FALSE, rotate_pal = FALSE) |>
  tibble::enframe(name = "class", value = "hex")

res <- qs::qread("dat/interim/mod_obs_masked.qs", nthreads = 16L) |>
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
  summarise(cnt = n()) |>
  mutate(
    bc_u = forcats::fct_rev(bc_u),
    cnt_f = format(cnt, big.mark = ",", scientific = F),
    bc_s_count = sum(cnt),
    prop_x = cnt / sum(cnt)
  ) |>
  ungroup() |>
  mutate(prop_tot = cnt / sum(cnt)) |>
  bind_cols(bicols)

yticks <- res_agg |>
  filter(bc_s == "low") |>
  mutate(cs = cumsum(prop_x)) |>
  mutate(yt = tidyr::replace_na(lag(cs), 0) + prop_x / 2) |>
  pull(yt)

# heatmap
p <- ggplot(res_agg, aes(x = bc_s, y = bc_u, fill = cnt)) +
  geom_tile(color = "white", linewidth = 2) +
  geom_label(aes(label = cnt_f), family = "Source Sans Pro", fill = "white", size = 10) +
  xlab("susceptibility (class)") +
  ylab("uncertainty (class)") +
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
ggsave("plt/class_counts_heatmap.png", p, width = w, height = h, units = "mm", dpi = 300)

# mosaic plot
p <- ggplot(res_agg, aes(x = bc_s, y = prop_x, width = bc_s_count, group = bc_u, fill = class)) +
  geom_bar(stat = "identity", position = "stack", colour = "white", linewidth = 2, show.legend = FALSE) +
  geom_label(aes(label = scales::percent(prop_tot)), position = position_stack(vjust = 0.5), fill = "white", size = 7) +
  facet_grid(~bc_s, scales = "free_x", space = "free_x") +
  xlab("susceptibility (class)") +
  scale_y_continuous(name = "uncertainty (class)", breaks = yticks, labels = c("low", "medium", "high")) +
  scale_fill_manual(values = bicols$hex) +
  theme_linedraw() +
  theme(
    panel.border = element_blank(),
    panel.grid = element_blank(),
    strip.background = element_blank(),
    strip.text = element_blank(),
    text = element_text(
      family = "Source Sans Pro",
      colour = "black",
      size = 40
    )
  )
ggsave("plt/class_counts_mosaic.png", p, width = w, height = h + 20, units = "mm", dpi = 300)

# alternatives w/ ggplot2:
# - autoplot(yardstick::conf_mat, type = "mosaic")
# - productplots::prodplot()
# - ggmosaic::geom_mosaic()
