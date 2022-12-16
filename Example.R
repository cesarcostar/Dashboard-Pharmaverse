library(shiny)

options(repos = c(
  pharmaverse = 'https://pharmaverse.r-universe.dev',
  CRAN = 'https://cloud.r-project.org'))

library(metacore)
library(metatools)
library(admiral.test)
library(xportr)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

load(metacore_example("pilot_ADaM.rda"))
metacore <- metacore %>% 
  select_dataset("ADSL")

metacore$ds_vars


adsl_preds <- build_from_derived(metacore, 
                                 ds_list = list("dm" = admiral_dm), 
                                 predecessor_only = FALSE, keep = TRUE)
head(adsl_preds, n=10)




# Define UI for dataset viewer app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Phamaverse Packages - Data Example"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Text for providing a caption ----
      # Note: Changes made to the caption in the textInput control
      # are updated in the output area immediately as you type
      textInput(inputId = "caption",
                label = "Caption:",
                value = "ADSL_Preds"),
      
      # Input: Selector for choosing dataset ----
      selectInput(inputId = "dataset",
                  label = "Choose a dataset:",
                  choices = c("StudyID")),
      
      
      # Input: Numeric entry for number of obs to view ----
      numericInput(inputId = "obs",
                   label = "Number of observations to view:",
                   value = 10),
      
      img(src = "logo.png", height = 100, width = 100),
      
      
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      ("http://examples.pharmaverse.org/data/adsl"),
      
      # Output: Formatted text for caption ----
      h3(textOutput("caption", container = span)),
      
      # Output: Verbatim text for data summary ----
      verbatimTextOutput("summary"),
      
      # Output: HTML table with requested number of observations ----
      tableOutput("view")
      
    )
  )
)

# Define server logic to summarize and view selected dataset ----
server <- function(input, output) {
  
  # Return the requested dataset ----
  # By declaring datasetInput as a reactive expression we ensure
  # that:
  #
  # 1. It is only called when the inputs it depends on changes
  # 2. The computation and result are shared by all the callers,
  #    i.e. it only executes a single time
  datasetInput <- reactive({
    switch(input$dataset,
           "StudyID" = adsl_preds)
  })
  
  # Create caption ----
  # The output$caption is computed based on a reactive expression
  # that returns input$caption. When the user changes the
  # "caption" field:
  #
  # 1. This function is automatically called to recompute the output
  # 2. New caption is pushed back to the browser for re-display
  #
  # Note that because the data-oriented reactive expressions
  # below don't depend on input$caption, those expressions are
  # NOT called when input$caption changes
  output$caption <- renderText({
    input$caption
  })
  
  # Generate a summary of the dataset ----
  # The output$summary depends on the datasetInput reactive
  # expression, so will be re-executed whenever datasetInput is
  # invalidated, i.e. whenever the input$dataset changes
  output$summary <- renderPrint({
    dataset <- datasetInput()
    summary(dataset)
  })
  
  # Show the first "n" observations ----
  # The output$view depends on both the databaseInput reactive
  # expression and input$obs, so it will be re-executed whenever
  # input$dataset or input$obs is changed
  output$view <- renderTable({
    head(datasetInput(), n = input$obs)
  })
  
}

# Create Shiny app ----
shinyApp(ui, server)