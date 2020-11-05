
library(shiny)
library(miniUI)
library(ggplot2)

ggpolygon <- function(data, xvar, yvar) {

    # ggpolygon(mtcars, "hp", "mpg")

    ui <- miniPage(
        gadgetTitleBar("Click to select points"),
        miniContentPanel(
            # The click="click" argument means we can listen for
            # brush events on the plot using input$click
            plotOutput("plot", height = "100%", click = "click")
        )
    )

    server <- function(input, output, session) {

        points <- data.frame("x" = NULL, "y" = NULL)

        g <- ggplot(data, aes_string(xvar, yvar)) + geom_point()

        # Render the plot
        output$plot <- renderPlot({
            # print(points)
            if (!is.null(input$click)) {
                new_point <- c(input$click$x, input$click$y)
                names(new_point) <- c(xvar, yvar)
                points <<- rbind(
                    points,
                    new_point)

                colnames(points) <<- c(xvar, yvar)

            }

            # Plot the data with x/y vars indicated by the caller.
            if (ncol(points > 0)) {
                g <- g +
                    geom_polygon(
                        data = points,
                        alpha = 0.1) +
                    geom_point(
                        data = points,
                        colour = "red", size = 2)
            }

            g
        })

        # Handle the Done button being pressed.
        observeEvent(input$done, {
            # Return the clicked points.
            message(
                "To generate the data.frame, type \n'data.frame(",
                toString(points, digits = 2), ")'")
            stopApp(points)
        })
    }

    runGadget(ui, server)
}

