#
# A simple Shiny application demonstrating gfpop for GSOC2020.
#
library(shiny)
library(gfpop)
library(ggplot2)
library(plyr)
library(plotly)

n <- 1000
myData <-
    dataGenerator(n, c(0.1, 0.3, 0.5, 0.8, 1), c(1, 2, 1, 3, 1), sigma = 1)
myData_df <- data.frame("V1" = 1:n, "V2" = myData)

ui <- fluidPage(
    titlePanel("How does penalty affect changepoint detection in gfpop?"),
    
    # Sidebar with slider input
    sidebarLayout(
        sidebarPanel(
            # File input
            fileInput(inputId = "datainput", "Upload a CSV File! (two columns, no headers.)"),
            
            # Penalty input
            numericInput(
                inputId = "pen",
                label = "Penalty",
                value = 15
            )
        ),
        mainPanel(
            h1("Static plot:"),
            plotOutput("gfpopPlot"),
            h1("Interactive plot:"),
            plotlyOutput("gfpopPlot_interactive")
        )
    )
)

server <- function(input, output) {
    # A helper function to get data, either from environment or from user input
    setup_data <- function() {
        inFile <- input$datainput
        if (is.null(inFile)) {
            data_input <- myData_df
        }
        else {
            data_input <- read.csv(inFile$datapath, header = TRUE)
        }
        return(data_input)
    }
    
    # Given some data, generate a changepoint dataframe
    generate_changepoint <- function(data_input, penalty) {
        myGraph <- graph(penalty = penalty, type = "updown")
        model <-
            gfpop(data = data_input$V2,
                  mygraph = myGraph,
                  type = "mean")
        num_changepoints <- length(model$changepoints)
        changepoint_data <-
            data.frame(
                changepoint = model$changepoints,
                changepoint_end = c(0, model$changepoints[1:num_changepoints -
                                                              1]),
                y = model$parameters
            )
        return(changepoint_data)
    }
    
    # Gets the changepoint location associated with this location on the x axis
    get_associated_changepoint <-
        function(x_loc, changepoint_data) {
            consistent_changepoint_data <-
                subset(changepoint_data,
                       (changepoint >= x_loc) & (changepoint_end <= x_loc))
            return(head(consistent_changepoint_data, 1))
        }
    
    # Given data and it's associated changepoint data, annotates data points
    # with the changepoint interval in which that data falls
    annotate_data_with_changepoint <-
        function(data_input, changepoint_data) {
            matched_changepoints <-
                plyr::ldply(by(data_input, 1:nrow(data_input),
                               function(row)
                                   get_associated_changepoint(row$V1, changepoint_data)),
                            rbind)
            annotated_data <- cbind(data_input, matched_changepoints)
            return(
                data.frame(
                    X = annotated_data$V1,
                    Y = annotated_data$V2,
                    changepoint = annotated_data$changepoint,
                    changepoint_end = annotated_data$changepoint_end,
                    y = annotated_data$y,
                    CP_Data = paste(
                        "Assoc. CP: ",
                        "\n",
                        '\t',
                        "Begin:",
                        annotated_data$changepoint_end,
                        "\n",
                        '\t',
                        "End:",
                        annotated_data$changepoint,
                        "\n",
                        '\t',
                        "CP_Y:",
                        annotated_data$y
                    )
                )
            )
        }
    
    output$gfpopPlot <- renderPlot({
        data_input <- setup_data()
        changepoint_data <-
            generate_changepoint(data_input, as.double(input$pen))
        ggplot(changepoint_data) +
            geom_point(data = data.frame(data_input), aes(x = V1, y = V2)) +
            geom_segment(
                aes(
                    x = changepoint,
                    xend = changepoint_end,
                    y = y,
                    yend = y
                ),
                size = 1.5,
                col = "red"
            ) +
            xlab("X units (arbitrary)") +
            ylab("Univariate gaussian data (randomly generated)")
    })
    
    output$gfpopPlot_interactive <- renderPlotly({
        data_input <- setup_data()
        changepoint_data <-
            generate_changepoint(data_input, as.double(input$pen))
        changepoint_data_annot <-
            annotate_data_with_changepoint(data_input, changepoint_data)
        
        g <-
            ggplot(changepoint_data_annot, aes(
                x = X,
                y = Y,
                text = CP_Data
            )) +
            geom_point() +
            geom_segment(
                aes(
                    x = changepoint,
                    xend = changepoint_end,
                    y = y,
                    yend = y
                ),
                size = 1.5,
                col = "red"
            ) +
            xlab("X units (arbitrary)") +
            ylab("Univariate gaussian data (randomly generated)")
        ggplotly(g, tooltip = c("X", "Y", "text"))
    })
}

# Run the application
shinyApp(ui = ui, server = server)