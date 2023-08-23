# import libraries
library(glmnet)
library(rpart)
library(e1071)
library(nnet)
library(randomForest)


# Models
formula <- as.formula(sold_out ~ .)

LogitModel <- function(data) {
  model <- glm(formula, data = data, family = binomial)
  return(model)
}

ClassTreesModel <- function(data) {
  model <- rpart(formula, data = data, method="class")
  return(model)
}

SVMModel <- function(data) {
  model <- svm(formula, data = data)
  return(model)
}

NNModel <- function(data) {
  model <- nnet(formula, data = data, size=10)
  return(model)
}

RandomForestModel <- function(data) {
  model <- randomForest(formula, data = data)
  return(model)
}

library(caret)
library(mltools)

ten_fold_cv <- function(model_func, data, k = 10) {
  folds <- createFolds(data$sold_out, k = k)
  mcc_values <- c()
  
  for (fold in folds) {
    train_data <- data[-fold, ]
    test_data <- data[fold, ]
    
    model <- model_func(train_data)
    predictions <- predict(model, test_data, type="response")
    if (is.factor(predictions)) {
      predictions <- as.numeric(as.character(predictions))
    }
    
    mcc <- mcc(test_data$sold_out, as.factor(ifelse(predictions > 0.5, 1, 0)))
    mcc_values <- c(mcc_values, mcc)
  }
  
  return(mean(mcc_values))
}

# Import data & clean
library(readr)
data <- read_csv("../SoldOutData.csv")
data <- subset(data, select = -id)
data <- na.omit(data)
date_columns <- c("date", "local_date", "announce_date")
numeric_columns <- c("score", "popularity", "venue_score", "listing_count", "average_price", "lowest_price", "highest_price", "median_price", "primary_performer_score", "performer_2_score")
integer_columns <- c("n_performers", "venue_n_upcoming_events", "primary_performer_event_count", "performer_2_event_count")
factor_columns <- c("type", "venue", "country", "state", "segment", "primary_performer", "performer_2", "sold_out")

## convert columns:
for (col in date_columns) {data[[col]] <- as.Date(data[[col]], format="%Y-%m-%dT%H:%M:%S")}
for (col in numeric_columns) {data[[col]] <- as.numeric(data[[col]])}
for (col in integer_columns) {data[[col]] <- as.integer(data[[col]])}
for (col in factor_columns) {data[[col]] <- as.factor(data[[col]])}


models <- list(LogitModel = LogitModel,
               ClassTreesModel = ClassTreesModel,
               SVMModel = SVMModel,
               NNModel = NNModel,
               RandomForestModel = RandomForestModel)


results <- sapply(names(models), function(model_name) {
  ten_fold_cv(models[[model_name]], data, k = 10)
})

results_table <- as.data.frame(t(results), row.names = names(models))
colnames(results_table) <- c("MCC")
print(results_table)