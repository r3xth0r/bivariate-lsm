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
