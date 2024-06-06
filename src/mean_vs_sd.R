#!/usr/bin/R

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# mean vs sd
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

suppressPackageStartupMessages({
  library("ggplot2")
  library("hexbin")
  library("scattermore")
  library("glue")
  library("showtext")
})

font_add("Source Sans Pro", "~/.fonts/source-sans-pro/SourceSansPro-Regular.ttf")
showtext_auto()

ncores <- 16L
w <- 150
h <- 120

print(glue("{format(Sys.time())} -- loading data"))
res <- qs::qread("dat/interim/mod_obs.qs", nthreads = ncores)

# > head(res)
# # A tibble: 6 × 5
#   slide      x      y mean_susc sd_susc
#   <lgl>  <int>  <int>     <dbl>   <dbl>
# 1 FALSE 352810 358480     0.425  0.0453
# 2 FALSE 352620 358470     0.281  0.0181
# 3 FALSE 352630 358470     0.357  0.0400
# 4 FALSE 352640 358470     0.335  0.0408
# 5 FALSE 352650 358470     0.340  0.0399
# 6 FALSE 352660 358470     0.343  0.0446

# quadratic regression ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

tmp <- res |>
  dplyr::select(s = sd_susc, m = mean_susc) |>
  dplyr::mutate(m2 = m^2)

fit_quadratic_regression <- function(tbl, intercept = FALSE) {
  mat <- as.matrix(tbl)
  y <- mat[, "s"]
  X <- mat[, c("m", "m2")]
  if (intercept) {
    X <- cbind(1, X)
  }
  mod <- lm.fit(x = X, y = y)
  yhat <- mod$fitted.values
  ybar <- mean(y)
  MSS <- sum(yhat^2)
  SSE <- sum((yhat - ybar)^2)
  SST <- sum((y - ybar)^2)
  SSR <- sum(mod$residuals^2)
  if (intercept) {
    R2 <- 1 - (SSR / SST)
  } else {
    # cave
    R2 <- MSS / (MSS + SSR)
  }
  rho <- cor(yhat, y)
  coefs <- coef(mod)
  x <- seq(0, 1, length = 1000)
  y <- coefs["m"] * x + coefs["m2"] * x^2
  out <- list(
    coefficients = coefs,
    xyline = tibble::tibble(x, y),
    R2 = R2,
    rho = rho
  )
  return(out)
}

regr <- fit_quadratic_regression(tmp, intercept = FALSE)

# scatterplot (slow despite using scattermore) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
print(glue("{format(Sys.time())} -- creating scatterplot"))
p <- ggplot(res, aes(x = mean_susc, y = sd_susc)) +
  geom_scattermore(alpha = 0.1) +
  geom_line(data = regr$xyline, aes(x = x, y = y), color = "white") +
  xlab("mean") +
  ylab("standard deviation") +
  theme_linedraw() +
  theme(
    text = element_text(
      family = "Source Sans Pro",
      colour = "black",
      size = 20
    )
  )
ggsave("plt/mean-vs-sd_scatter.png", p, width = w, height = h, units = "mm")

# hexbin ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
print(glue("{format(Sys.time())} -- creating hexbin plot"))
brks <- 20^(0:4)
p <- ggplot(res, aes(x = mean_susc, y = sd_susc)) +
  geom_hex() +
  geom_line(data = regr$xyline, aes(x = x, y = y)) +
  xlab("mean") +
  ylab("standard deviation") +
  scale_fill_viridis_c(name = "counts (log)", option = "inferno", breaks = brks, trans = "log") +
  theme_linedraw() +
  theme(
    text = element_text(
      family = "Source Sans Pro",
      colour = "black",
      size = 20
    )
  )
ggsave(glue("plt/mean-vs-sd_hex.png"), p, width = w, height = h, units = "mm", dpi = 300)

# 2d bins ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
print(glue("{format(Sys.time())} -- creating 2d bin plot"))
p <- ggplot(res, aes(x = mean_susc, y = sd_susc)) +
  geom_bin2d(bins = 50) +
  geom_line(data = regr$xyline, aes(x = x, y = y)) +
  xlab("mean") +
  ylab("standard deviation") +
  scale_fill_viridis_c(name = "counts (log)", option = "inferno", breaks = brks, trans = "log") +
  theme_linedraw() +
  theme(
    text = element_text(
      family = "Source Sans Pro",
      colour = "black",
      size = 20
    )
  )
ggsave(glue("plt/mean-vs-sd_2d-bin.png"), p, width = w, height = h, units = "mm", dpi = 300)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

print(glue("{format(Sys.time())} -- Done \\o/"))
