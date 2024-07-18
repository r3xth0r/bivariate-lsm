#!/usr/bin/R

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# mean vs sd
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

suppressPackageStartupMessages({
  library("MASS")
  library("ggplot2")
  library("hexbin")
  library("scattermore")
  library("glue")
  library("showtext")
})

font_add("Source Sans Pro", "~/.fonts/source-sans-pro/SourceSansPro-Regular.ttf")
showtext_auto()

ncores <- 16L
w <- 140
h <- 100

print(glue("{format(Sys.time())} -- loading data"))
res <- qs::qread("dat/interim/mod_obs_masked.qs", nthreads = ncores)

# quadratic regression ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

tmp <- res |>
  dplyr::select(s = uncertainty, m = susceptibility) |>
  dplyr::mutate(m2 = m^2)

fit_quadratic_regression <- function(tbl, robust = FALSE, intercept = FALSE) {
  print(glue("{format(Sys.time())} » Fitting quadratic regression"))
  mat <- as.matrix(tbl)
  y <- mat[, "s"]
  X <- mat[, c("m", "m2")]
  if (intercept) {
    X <- cbind(1, X)
  }
  if (robust) {
    print(glue("{format(Sys.time())} » Computing robust regression model. This may take some time."))
    mod <- rlm(x = X, y = y, psi = psi.bisquare)
  } else {
    mod <- lm.fit(x = X, y = y)
  }
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
    mod = mod,
    coefficients = coefs,
    xyline = tibble::tibble(x, y),
    R2 = R2,
    rho = rho
  )
  print(glue("{format(Sys.time())} » Done"))
  return(out)
}

regr <- fit_quadratic_regression(tmp, robust = TRUE, intercept = FALSE)

# scatterplot (slow despite using scattermore) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
print(glue("{format(Sys.time())} -- creating scatterplot"))
p <- ggplot(res, aes(x = susceptibility, y = uncertainty)) +
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
p <- ggplot(res, aes(x = susceptibility, y = uncertainty)) +
  geom_hex() +
  geom_line(data = regr$xyline, aes(x = x, y = y), linetype = "dashed") +
  xlab("mean") +
  ylab("standard deviation") +
  scale_fill_viridis_c(name = "counts (log)", option = "magma", breaks = brks, trans = "log") +
  theme_linedraw() +
  theme(
    text = element_text(
      family = "Source Sans Pro",
      colour = "black",
      size = 30
    )
  )
ggsave(glue("plt/mean-vs-sd_hex.png"), p, width = w, height = h, units = "mm", dpi = 300)

# 2d bins ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
print(glue("{format(Sys.time())} -- creating 2d bin plot"))
p <- ggplot(res, aes(x = susceptibility, y = uncertainty)) +
  geom_bin2d(bins = 50) +
  geom_line(data = regr$xyline, aes(x = x, y = y), linetype = "dashed") +
  xlab("mean") +
  ylab("standard deviation") +
  scale_fill_viridis_c(name = "counts (log)", option = "magma", breaks = brks, trans = "log") +
  theme_linedraw() +
  theme(
    text = element_text(
      family = "Source Sans Pro",
      colour = "black",
      size = 30
    )
  )
ggsave(glue("plt/mean-vs-sd_2d-bin.png"), p, width = w, height = h, units = "mm", dpi = 300)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

print(glue("{format(Sys.time())} -- Done \\o/"))
