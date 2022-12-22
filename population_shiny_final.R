#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(dplyr)              # An opinionated collection of R packages designed for data science.
library(EnvStats)               # A comprehensive R package for environmental statistics.
library(tidyr)
#extrafont::loadfonts(device="win")
library(ggplot2)
library(RColorBrewer)
library(stringr)
library(forcats)
library(shiny)
library(shinyMatrix)


source(file = 'changeable_inputs_mult.R')

#Create an initial matrix for the gains table in the shiny app
m = matrix(c(1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2),
           10,
           2,
           dimnames = list(NULL,
                           c('CPTs','MAJs')) #rename the columns
)

#set row names for the gains matrix
rownames(m) <-  c('1','2','3','4','5','6','7','8','9','10')


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Population Simulation"),
  
  # Numeric INput
  sidebarLayout(
    sidebarPanel(

      

      
      matrixInput(inputId = 'gains_matrix',
                label = 'Choose number of gains per year',
                value = m,
                rows = list(names = TRUE),
                cols = list(names = TRUE )
      ),
      
      numericInput(
        inputId = 'sims',
        label = "Number of simulations to run",
        value = 10,
        min = 1,
        max = 1000,
        step = 1,
        width = NULL
      ),
      
      actionButton(inputId = 'gobutton',
                   label = 'Click to start simulation')
    ),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("boxplot"),
      plotOutput('barplot')
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  source('changeable_inputs_mult.R')
  
  data <- eventReactive(input$gobutton, {
    whole_sim(gains = input$gains_matrix, sims = input$sims)
  })
  
  
  
  
  
  output$boxplot <- renderPlot({  
    
    data() %>% 
      #total_collection() %>% 
      mutate(rank = forcats::fct_relevel(rank, 'LTC','MAJ')) %>% 
      ggplot(aes(x = factor(year), y = number, color = rank)) +
      geom_boxplot() + 
      facet_wrap(~rank )+
      labs(
        title = 'Box Plots by Rank for Years 1-10',
        x = 'Year',
        y = 'Quantity of Officers'
      ) +
      ylim(0,25) +
      scale_fill_manual(values = c('orange','#0066C0')) +
      scale_color_manual(values = c('orange','#0066C0')) +
      # theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
      theme(title = element_text(face="bold",size = 14,"TITLE"),
            axis.text = element_text(size = 12),
            legend.text = element_text(size = 12)) +
      geom_vline(xintercept=25,linetype="dashed", 
                 color = "green", size=1) 
    
  })
  
  output$barplot <- renderPlot({
    
    data() %>% 
      #total_collection() %>% 
      ggplot(aes(x = number, y = factor(year), fill = rank)) +
      geom_col(width=0.7, position = position_dodge(width=0.8)) +coord_flip() +
      scale_fill_manual(values = c('orange','#0066C0'))+
      labs(
        title = 'Average AGR Officer Strength Predictions',
        #subtitle = str_c('For ', num_of_sims, ' Simulations'),
        x = 'Number of Officers',
        y = 'Year'
      ) +
      theme(title = element_text(face="bold",size = 14,"TITLE"),
            axis.text = element_text(size = 12),
            legend.text = element_text(size = 12)) +
      
      geom_vline(xintercept=25,linetype="dashed",color = "green", size=1)
  })
  
  
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)


