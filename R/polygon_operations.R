
#' Check if a point is contained in a polygon
#'
#' based on: https://en.wikipedia.org/wiki/Even%E2%80%93odd_rule
#' @param x The x coordinates of point.
#' @param y The y coordinates of point.
#' @param poly a list of numeric vectors defining the polygon
#'             list(c(x, y), c(x, y), ...) or a data.frame
#'             data.frame(x = c(0,0,1), y = c(0,1,1))
#'
#' @return
#' @export
#'
#' @examples
#' poly_selection <- data.frame(
#'     Petal.Length = c(2,4,6),
#'     Sepal.Width = c(2,4,2))
#'
#' dplyr::mutate(
#'     iris,
#'     point_in_poly = is_point_in_path(
#'         Petal.Length,
#'         Sepal.Width,
#'         poly_selection))
is_point_in_path <- function(x, y, poly) {
    if (is.data.frame(poly)) {
        poly <- split(poly, seq_len(nrow(poly)))
    }

    j <- length(poly)
    c <- FALSE

    for (i in seq_len(j)) {
        crosses_y <- (poly[[i]][2] > y) != (poly[[j]][2] > y)
        dx <- poly[[j]][1] - poly[[i]][1]
        dy <- poly[[j]][2] - poly[[i]][2]

        crosses_x <- (x < poly[[i]][1] + (dx) * (y - poly[[i]][2]) / (dy))
        if (crosses_y & crosses_x) {
            c = !c
        }

        j <- i
    }


    return(c)
}

is_point_in_path <- Vectorize(is_point_in_path, vectorize.args = c("x", "y"))


is_point_df_in_path <- function(point_df, poly_df) {

    stopifnot(all(colnames(poly_df)[1:2] %in% colnames(point_df)))
    x_name <- colnames(poly_df)[[1]]
    y_name <- colnames(poly_df)[[2]]

    is_point_in_path(
        x = point_df[[x_name]],
        y = point_df[[y_name]],
        poly_df)
}
