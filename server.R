library(shiny)
library(caret)
library(reshape)
library(ggplot2)
library(datasets)
library(rpart.plot)
library(rpart)
library(e1071)

# Data used for the Decision Tree model 
MyIris <-iris

# Define server logic for Decision Tree prediction application
shinyServer(function(input, output) {
  # Reactive expression to generate the predicted iris species. 
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
  # Create the New Data for the prediction function from the slider input 
  SpeciesSelection <- reactive({      
	Newdata <- data.frame(Sepal.Length = input$Sepal.Length,
						  Sepal.Width = input$Sepal.Width,
						  Petal.Length = input$Petal.Length,
						  Petal.Width = input$Petal.Width)
  })
  
  
  # Generate a plot of the data. 
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
  # Generate the prediction text caption
  formulaText <- reactive({
	modelFit <-train(Species~.,method="rpart", data=MyIris)
	newPred <- predict(modelFit,SpeciesSelection())
	paste("Based on these measurements, this is a Iris", newPred, "flower")
  })

  # Return the formula text for printing as a caption
  output$caption <- renderText({
    formulaText()
  })
  
  # Generate a plot of the data. 
  output$tree <- renderPlot({
	modelFit <-train(Species~.,method="rpart", data=MyIris)
	newPred <- predict(modelFit,SpeciesSelection())
	complexity <- ifelse(newPred=="setosa", 1, ifelse(newPred=="versicolor", 2, 3))
	trees <- modelFit$finalModel
	cols <- ifelse(trees$frame$yval == complexity, "purple", "darkgray")
	prp(trees, type = 1, extra = 0,col=cols, branch.col=cols, varlen=0, split.col=cols)
  })  
})
