test_that("Points in polygons are detected", {
    sample_square <- list(c(0,0), c(0,1), c(1,1), c(1,0))

    expect_true(is_point_in_path(0.5, 0.5, sample_square))
    expect_false(is_point_in_path(2, 2, sample_square))
    expect_false(is_point_in_path(-1, 2, sample_square))
    expect_false(is_point_in_path(1, -2, sample_square))

    expect_equal(
        is_point_in_path(
            c(0.5, 2, -1, 1, 0.8),
            c(0.5, 2, 2, -2, 0.1),
            sample_square),
        c(TRUE, FALSE, FALSE, FALSE, TRUE))

})

test_that("Points in polygons are detected usiong a DF defining polygon", {
    sample_square_df <- data.frame(x = c(0,0,1,1), y = c(0,1,1,0))

    expect_equal(
        is_point_in_path(
            c(0.5, 2, -1, 1, 0.8),
            c(0.5, 2, 2, -2, 0.1),
            sample_square_df),
        c(TRUE, FALSE, FALSE, FALSE, TRUE))


})


test_that("Points in polygons are detected usiong a DF defining polygon", {
    sample_square_df <- data.frame(x = c(0,0,1,1), y = c(0,1,1,0))

    expect_equal(
        is_point_in_path(
            c(0.5, 2, -1, 1, 0.8),
            c(0.5, 2, 2, -2, 0.1),
            sample_square_df),
        c(TRUE, FALSE, FALSE, FALSE, TRUE))


})


test_that("Points in polygons work on NSE", {
    sample_square_df <- data.frame(x = c(0,0,1,1), y = c(0,1,1,0))
    sample_points <- data.frame(x = c(0.5, 2, -1, 1, 0.8),
                                y = c(0.5, 2, 2, -2, 0.1))

    samp_points_out <- dplyr::mutate(
        sample_points,
        in_path = is_point_in_path(
            x,
            y,
            sample_square_df))

    expect_equal(
        samp_points_out$in_path,
        c(TRUE, FALSE, FALSE, FALSE, TRUE))


})

test_that("is_point_df_in_path works", {
    sample_square_df <- data.frame(x = c(0,0,1,1), y = c(0,1,1,0))
    testing_points <- data.frame(x = c(0.5, 2, -1, 1, 0.8),
                                 y = c(0.5, 2, 2, -2, 0.1))

    expect_equal(
        is_point_df_in_path(
            testing_points,
            sample_square_df),
        c(TRUE, FALSE, FALSE, FALSE, TRUE))
})

test_that("is_point_df_in_path follow order", {
    sample_rectangle_df <- data.frame(x = c(0,0,100,100), y = c(0,1,1,0))
    testing_points <- data.frame(x = c(1, 2, 3, 4, 5),
                                 y = c(-1, 0.2, 3, 500, 0.1))

    expect_equal(
        is_point_df_in_path(
            testing_points,
            sample_rectangle_df),
        c(FALSE, TRUE, FALSE, FALSE, TRUE))

    # This checks if inverting the order of the variables in the rectangle df
    # changes the result
    sample_rectangle_df <- data.frame(y = c(0,1,1,0), x = c(0,0,100,100))
    expect_equal(
        is_point_df_in_path(
            testing_points,
            sample_rectangle_df),
        c(FALSE, TRUE, FALSE, FALSE, TRUE))

    # Same as before but invering the testing points df column order
    sample_rectangle_df <- data.frame(x = c(0,0,100,100), y = c(0,1,1,0))
    testing_points <- data.frame(y = c(-1, 0.2, 3, 500, 0.1),
                                 x = c(1, 2, 3, 4, 5))

    expect_equal(
        is_point_df_in_path(
            testing_points,
            sample_rectangle_df),
        c(FALSE, TRUE, FALSE, FALSE, TRUE))

    # This just makes sure the points are out if we actually invert the
    # coordinates names
    testing_points <- data.frame(x = c(-1, 0.2, 3, 500, 0.1),
                                 y = c(1, 2, 3, 4, 5))

    expect_equal(
        is_point_df_in_path(
            testing_points,
            sample_rectangle_df),
        c(FALSE, FALSE, FALSE, FALSE, FALSE))
})
