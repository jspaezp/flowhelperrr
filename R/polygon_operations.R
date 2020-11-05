
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

test_point_in_path <- function() {
    sample_square <- list(c(0,0), c(0,1), c(1,1), c(1,0))

    is_point_in_path(0.5, 0.5, sample_square)
    is_point_in_path(2, 2, sample_square)
    is_point_in_path(-1, 2, sample_square)
    is_point_in_path(1, -2, sample_square)

    is_point_in_path(c(0.5, 2, -1, 1, 0.8), c(0.5, 2, 2, -2, 0.1), sample_square)

    sample_square_df <- data.frame(x = c(0,0,1,1), y = c(0,1,1,0))
    is_point_in_path(c(0.5, 2, -1, 1, 0.8), c(0.5, 2, 2, -2, 0.1), sample_square_df)

}
