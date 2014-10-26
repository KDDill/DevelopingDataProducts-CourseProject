library(shiny)

# Define UI for random distribution application 
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Classify the Iris Species"),

  # Sidebar with controls to select the random distribution type
  # and number of observations to generate. Note the use of the br()
  # element to introduce extra vertical spacing
 
  # Sidebar with sliders that demonstrate various available options
  sidebarPanel(
	helpText('Use the sliders below to select new flower measurements.'),

    # Sepal Length slider
    sliderInput("Sepal.Length", "Sepal Length:", 
                min=4, max=8, value=6, step=0.5),

    # Sepal Width slider
    sliderInput("Sepal.Width", "Sepal Width:", 
                min = 2, max = 4.5, value = 3, step= 0.25),

    # Petal Length slider
    sliderInput("Petal.Length", "Petal Length:",
                min = 1, max = 7, value=5, step=0.5),

    # Petal Width slider
    sliderInput("Petal.Width", "Petal Width:", 
                min = 0, max = 2.5, value = 1, step = 0.25),

	br(), 
	helpText("Press the 'Update Measurements' button to submit the new flower measurements."),
	submitButton("Update Measurements"),
	br(),
	helpText("Use the tabs to view: the flower input values and species classification, iris species classification tree, boxplots by iris species, and summary table of the classified iris species")
  ),
  # Show a tabset that includes a plot, summary, and table view
  # of the generated distribution
  mainPanel(
    tabsetPanel(
		# Show a table summarizing the values entered
		tabPanel("Input Values", h3(textOutput("caption")), br(),tableOutput("values")),
		tabPanel("Classification Tree", plotOutput("tree")),
		tabPanel("BoxPlot", plotOutput("plot")), 
		tabPanel("Summary", verbatimTextOutput("summary")) 
    )
  )
))
