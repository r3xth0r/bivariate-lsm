custom_bi_class <- function(dat, brks = NULL, style = "quantile", dim = 3) {
  #' Create custom classes for bivariate maps
  #'
  #' @description Computes custom classes for bivariate maps based using
  #' user-defined breaks for the susceptibility and styles supported by biscale
  #' for the uncertainty.
  #'
  # This is handled by biscale:::bi_var_cut() which effectively uses
  # classInt::classIntervals()$brks to derive the breaks which are passed on to
  # base::cut().
  #'
  #' @param dat data.frame-like object to add a new column `bi_class` to.
  #' @param brks numeric vector specifying class splits for the mean.
  #' Defaults to breaks for the defined `style` if not supplied.
  #' @param style A string identifying the style used to calculate breaks.
  #' See `bi_class()` for details.
  #' @param dim integer denoting the dimensions of the palette.
  #' See `bi_class()` for details.
  #'
  #' @return Input object with new column `bi_class`.
  if (is.null(brks)) {
    cat(paste0("Using breaks of type `", style, "`\n"))
    dat |>
      bi_class(x = susceptibility, y = uncertainty, style = style, dim = dim)
  } else {
    cat(paste0("Using custom breaks for mean and breaks of type `", style, "` for sd\n"))
    dat |>
      mutate(
        bc_s = cut(susceptibility, breaks = brks, include.lowest = TRUE, dig.lab = 3),
        bc_u = cut(uncertainty, breaks = classInt::classIntervals(
          var = uncertainty, n = dim, style = style
        )$brks, include.lowest = TRUE, dig.lab = 3)
      ) |>
      mutate(across(starts_with("bc_"), as.integer)) |>
      tidyr::unite("bi_class", bc_s:bc_u, sep = "-")
  }
}
