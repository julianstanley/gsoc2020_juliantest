#
# A simple Shiny application demonstrating gfpop for GSOC2020.
#
library(shiny)
library(gfpop)
library(ggplot2)
library(plyr)

n <- 1000
myData <- dataGenerator(n, c(0.1,0.3,0.5,0.8,1), c(1,2,1,3,1), sigma = 1)
myData_df <- data.frame("V1" = 1:n, "V2" = myData)

ui <- fluidPage(
    titlePanel("How does penalty affect changepoint detection in gfpop?"),
    
    # Sidebar with slider input
    sidebarLayout(
        sidebarPanel(
            # File input
            fileInput(inputId = "datainput", "Upload a CSV File! (two columns, no headers.)"),
            
            # Penalty input
            numericInput(inputId = "pen",
                         label = "Penalty",
                         value = 15)
        ),
        mainPanel(
            plotOutput("gfpopPlot")
        )
    )
)

server <- function(input, output) {
    output$gfpopPlot <- renderPlot({
        # Setup data
        inFile <- input$datainput
        if(is.null(inFile)) {
            print("null")
            data_input <- myData_df
        }
        else {
            data_input <- read.csv(inFile$datapath, header = TRUE)
        }
        
        penalty <- as.double(input$pen)
        myGraph <- graph(penalty = penalty, type = "updown")
        model <- gfpop(data = data_input$V2, mygraph = myGraph, type = "mean")
        num_changepoints <- length(model$changepoints)
        changepoint_data <- data.frame(changepoint = model$changepoints,
                                       changepoint_end = c(1, model$changepoints[1:num_changepoints-1]),
                                       y = model$parameters)
        ggplot(changepoint_data) +
            geom_point(data = data.frame(data_input), aes(x = V1, y = V2)) +  
            geom_segment(aes(x = changepoint, xend = changepoint_end, y = y, yend = y), size = 1.5, col = "red") +
            xlab("X units (arbitrary)") +
            ylab("Univariate gaussian data (randomly generated)")
    })
}

# Run the application
shinyApp(ui = ui, server = server)