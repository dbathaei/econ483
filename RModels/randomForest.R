# Number of predictors (excluding the response variable)
num_predictors <- ncol(data) - 1

# Define the range of mtry values to test
mtry_values <- c(2, floor(sqrt(num_predictors)), floor(num_predictors / 2), num_predictors)

# Define the tuning grid
RDF_tune_grid <- expand.grid(
  mtry = mtry_values,
  splitrule = c("gini", "hellinger", "extratrees"),
  min.node.size = c(1, 5, 10) # You can adjust these values
)

for (row in sampled){
  if (exists(data[row,])){
    data[-row,]
  }
}
# Define the tuning grid
RDF_tune_grid <- expand.grid(
  mtry = mtry_values,
  splitrule = c("gini", "hellinger", "extratrees"),
  min.node.size = c(1, 5, 10) # You can adjust these values
)
RANGERMODEL <- train(sold_out ~ .,
                     data = train_data,
                     method = "ranger",
                     trControl = CVfold,
                     tuneGrid = RDF_tune_grid)
