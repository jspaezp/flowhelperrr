
#' Check if a point is contained in a polygon
#'
#' based on: https://en.wikipedia.org/wiki/Even%E2%80%93odd_rule
#' @param x The x coordinates of point.
#' @param y The y coordinates of point.
#' @param poly a list of numeric vectors defining the polygon
#'             list(c(x, y), c(x, y), ...) or a data.frame
#'             data.frame(x = c(0,0,1), y = c(0,1,1))
#' @param poly_df a data.frame defining a polygon, column are expected
#' @param point_df a data.frame defining the points to check, column names are expected
#'
#' @return
#' @export
#'
#' @examples
#' poly_selection <- data.frame(
#'   Petal.Length = c(2, 4, 6),
#'   Sepal.Width = c(2, 4, 2)
#' )
#'
#' dplyr::mutate(
#'   iris,
#'   point_in_poly = is_point_in_path(
#'     Petal.Length,
#'     Sepal.Width,
#'     poly_selection
#'   )
#' )
is_point_in_path <- function(x, y, poly) {
  stopifnot(length(x) == length(y))

  if (is.data.frame(poly)) {
    poly <- split(poly, seq_len(nrow(poly)))
    poly <- lapply(poly, unlist, use.names = FALSE)
  }

  j <- length(poly)
  c <- rep(FALSE, length(x))

  for (i in seq_len(j)) {
    crosses_y <- (poly[[i]][2] > y) != (poly[[j]][2] > y)

    dx <- poly[[j]][1] - poly[[i]][1]
    dy <- poly[[j]][2] - poly[[i]][2]

    crosses_x <- (x < poly[[i]][1] + (dx) * (y - poly[[i]][2]) / (dy))
    crosses_both <- crosses_y & crosses_x

    c[crosses_both] <- !c[crosses_both]
    j <- i
  }


  return(c)
}


#' @export
#' @describeIn is_point_in_path Find wether points are inside a polygon, defining
#'             both as data frames with matching names
is_point_df_in_path <- function(point_df, poly_df) {
  stopifnot(all(colnames(poly_df)[1:2] %in% colnames(point_df)))
  x_name <- colnames(poly_df)[[1]]
  y_name <- colnames(poly_df)[[2]]

  is_point_in_path(
    x = point_df[[x_name]],
    y = point_df[[y_name]],
    poly_df
  )
}


#' Scale polygons around their center
#'
#' @param poly a data frame defining a polygon (x and y coordinates)
#' @param scaling a numeric vector that defines the scaling factor
#'
#' @return data.frame defining a scaled polygon
#' @export
#'
#' @examples
#' scale_polygon(data.frame(x = c(1, 2, 3), y = c(1, 2, 1)), 2)
#'
#' poly <- data.frame(x = c(1, 1, 0, 0), y = c(1, 0, 0, 1))
#' library(ggplot2)
#' ggplot(data = NULL, aes(x = x, y = y)) +
#'   geom_polygon(data = poly, fill = "black") +
#'   geom_polygon(data = scale_polygon(poly, 0.5), fill = "gray") +
#'   geom_polygon(data = scale_polygon(poly, 2), alpha = 0.2, fill = "red") +
#'   geom_polygon(data = scale_polygon(poly, c(1, 3)), alpha = 0.2, fill = "green") +
#'   geom_polygon(data = scale_polygon(poly, c(3, 1)), alpha = 0.2, fill = "blue")
scale_polygon <- function(poly, scaling) {
  stopifnot(ncol(poly) == 2)
  # translate to origin (subtract the scaling center)
  scale_center <- colMeans(poly)
  scaling_poly <- as.matrix(poly)
  scaling_poly <- t(scaling_poly) - scale_center

  # scale by the correct amount (multiply by a constant)
  scaling_poly <- scaling_poly * scaling

  # translate from origin (add the scaling center)
  scaling_poly <- scaling_poly <- t(scaling_poly + scale_center)

  return(as.data.frame(scaling_poly))
}
