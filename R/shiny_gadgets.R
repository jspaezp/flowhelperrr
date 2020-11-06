

#' Draw and return polygons on a shiny gadget
#'
#' @param data a data.frame
#' @param xvar a string defining the variable to use for x
#' @param yvar a string defining the varible to use for y
#'
#' @return data.frame with the coordinates delimiting the polygon
#'
#'
#' # ggpolygon(iris, "Sepal.Length", "Petal.Length")
#'
#' \if{html}{\figure{ggpolygon.png}{options: width=400 alt="ggpolygon sample"}}
#' \if{latex}{\figure{ggpolygon.png}{options: width=4in}}
#'
#' @export
ggpolygon <- function(data, xvar, yvar) {
    # ggpolygon(iris, "Sepal.Length", "Petal.Length")

    ui <- miniUI::miniPage(
        miniUI::gadgetTitleBar("Click to select points"),
        miniUI::miniContentPanel(
            # The click="click" argument means we can listen for
            # brush events on the plot using input$click
            shiny::plotOutput(
                "plot", height = "100%", click = "click"
            ))
    )

    server <- function(input, output, session) {
        points <- data.frame("x" = NULL, "y" = NULL)

        geom_data_points <- switch(
            EXPR = as.character((ncol(data) > 1000) + (ncol(data) > 10000)),
            "0" = function() ggplot2::geom_point(shape = 16, size = 1),
            "1" = function() ggplot2::geom_point(shape = "."),
            "2" = function() ggplot2::geom_hex()
        )

        g <-
            ggplot2::ggplot(data, ggplot2::aes_string(xvar, yvar)) +
            geom_data_points() +
            ggplot2::theme_bw() +
            ggplot2::scale_fill_viridis_c(trans = "sqrt")

        # Render the plot
        output$plot <- shiny::renderPlot({
            # print(points)
            if (!is.null(input$click)) {
                new_point <- c(input$click$x, input$click$y)
                names(new_point) <- c(xvar, yvar)
                points <<- rbind(points,
                                 new_point)

                colnames(points) <<- c(xvar, yvar)

            }

            # Plot the data with x/y vars indicated by the caller.
            if (ncol(points > 0)) {
                g <- g +
                    ggplot2::geom_polygon(data = points,
                                          alpha = 0.1) +
                    ggplot2::geom_point(data = points,
                                        colour = "red",
                                        size = 2)
            }

            g
        })

        # Handle the Done button being pressed.
        shiny::observeEvent(input$done, {
            # Return the clicked points.
            message(
                "To generate the data.frame, type: \n'data.frame(",
                toString(points, digits = 2),
                ")'"
            )
            shiny::stopApp(points)
        })
    }

    shiny::runGadget(ui, server, viewer = shiny::dialogViewer("ggpolygon"))
}
