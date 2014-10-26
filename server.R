library(shiny)
library(caret)
library(reshape)
library(ggplot2)
library(datasets)
library(rpart.plot)
library(rpart)
library(e1071)

MyIris <-iris

# Define server logic for random distribution application
shinyServer(function(input, output) {
 # Reactive expression to generate the requested distribution. This is 
  # called whenever the inputs change. The renderers defined 
  # below then all use the value computed from this expression
 sliderValues <- reactive({
    # Compose data frame
    data.frame(
      Measurments = c("Sepal Length", 
               "Sepal Width",
               "Petal Length",
               "Petal Width"),
      Values = as.character(c(input$Sepal.Length, 
                             input$Sepal.Width,
                             input$Petal.Length,
                             input$Petal.Width)), 
      stringsAsFactors=FALSE)
  }) 

  # Show the values using an HTML table
  output$values <- renderTable({
    sliderValues()
  })

  SpeciesSelection <- reactive({      
	Newdata <- data.frame(Sepal.Length = input$Sepal.Length,
						  Sepal.Width = input$Sepal.Width,
						  Petal.Length = input$Petal.Length,
						  Petal.Width = input$Petal.Width)
  })
  
  
  # Generate a plot of the data. Also uses the inputs to build the 
  # plot label. Note that the dependencies on both the inputs and
  # the 'data' reactive expression are both tracked, and all expressions 
  # are called in the sequence implied by the dependency graph
  output$plot <- renderPlot({
	modelFit <-train(Species~.,method="rpart", data=MyIris)
	newPred <- predict(modelFit,SpeciesSelection())
    irismelt <- melt(MyIris, "Species")
	irismelt$SpeciesClass <- ifelse(irismelt$Species==newPred, "Classified Species", "Other Species")
	# Boxplot	
	p <- ggplot(irismelt, aes(variable,value, fill=SpeciesClass)) +
			geom_boxplot() + facet_wrap(~Species) + labs(fill="Species Classification") +
			scale_fill_manual(values=c("Classified Species"="purple","Other Species"="grey")) +
			theme(axis.text.x=(element_text(angle=45, vjust=.5, hjust=.5)))
	 print(p)	
  })

  # Generate a summary of the data
    output$summary <- renderPrint({
   	modelFit <-train(Species~.,method="rpart", data=MyIris)
	newPred <- predict(modelFit,SpeciesSelection())
	summary(droplevels(iris[iris$Species == newPred,]))
  })

  formulaText <- reactive({
	modelFit <-train(Species~.,method="rpart", data=MyIris)
	newPred <- predict(modelFit,SpeciesSelection())
	paste("Based on these measurements, this is a Iris", newPred, "flower")
  })

  # Return the formula text for printing as a caption
  output$caption <- renderText({
    formulaText()
  })
  
  output$tree <- renderPlot({
	modelFit <-train(Species~.,method="rpart", data=MyIris)
	newPred <- predict(modelFit,SpeciesSelection())
	complexity <- ifelse(newPred=="setosa", 1, ifelse(newPred=="versicolor", 2, 3))
	trees <- modelFit$finalModel
	cols <- ifelse(trees$frame$yval == complexity, "purple", "darkgray")
	prp(trees, type = 1, extra = 0,col=cols, branch.col=cols, varlen=0, split.col=cols)
  })  
})
