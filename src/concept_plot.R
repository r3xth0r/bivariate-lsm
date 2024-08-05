library("ggplot2")
library("tibble")
library("dplyr")
library("tidyr")
library("biscale")
library("showtext")
library("patchwork")

font_add("Source Sans Pro", "~/.fonts/source-sans-pro/SourceSansPro-Regular.otf")
showtext_auto()

select_colors <- function(colors, keep = NULL, substitute = "transparent") {
  colors[-keep] <- substitute
  colors
}

mapping <- bi_pal(pal = "DkViolet", dim = 3, preview = FALSE) |>
  enframe(name = "class", value = "hex") |>
  separate(col = class, into = c("susceptibility", "uncertainty")) |>
  mutate(across(susceptibility:uncertainty, as.integer))

p_base <- ggplot(mapping, aes(x = susceptibility, y = uncertainty, fill = hex)) +
  geom_tile(color = "white", width = 0.95, height = 0.95, show.legend = FALSE) +
  coord_equal() +
  scale_x_continuous(labels = c("low", "medium", "high"), breaks = 1:3) +
  scale_y_continuous(labels = c("low", "medium", "high"), breaks = 1:3) +
  theme_linedraw() +
  theme(panel.grid = element_blank()) +
  theme(text = element_text(family = "Source Sans Pro", size = 30))

gungnir <- arrow(type = "closed", length = unit(1, "mm"))

p1 <- p_base +
  scale_fill_manual(values = select_colors(colors = rev(mapping$hex), keep = c(3, 6, 9))) +
  annotate("segment", x = 1, y = 1, xend = 1, yend = 3, arrow = gungnir) +
  xlab("")
p2 <- p_base +
  scale_fill_manual(values = select_colors(colors = rev(mapping$hex), keep = 7:9)) +
  annotate("segment", x = 1, y = 1, xend = 3, yend = 1, arrow = gungnir) +
  ylab("")
p3 <- p_base +
  scale_fill_manual(values = select_colors(colors = rev(mapping$hex), keep = c(1, 5, 9))) +
  annotate("segment", x = 1, y = 1, xend = 3, yend = 3, arrow = gungnir) +
  xlab("") + ylab("")

p <- p1 + p2 + p3 +
  plot_layout(axis_titles = "collect") +
  plot_annotation(tag_levels = "A", tag_prefix = "(", tag_suffix = ")")
ggsave("plt/concept.png", plot = p, width = 150, height = 50, unit = "mm", dpi = 300)
