# import libraries
library(glmnet)
library(rpart)
library(e1071)
library(nnet)
library(randomForest)
library(boot)
library(ranger)
library(caret)
library(leaps)
library(mltools)
library(tidyverse)

set.seed(123)
data <- read.csv("../Week1/SoldOutData.csv")
data <- subset(data, select = c(-id,-venue, -type, -primary_performer, -performer_2, -date))
data <- na.omit(data)


date_columns <- c("local_date", "announce_date")
numeric_columns <- c("score", "popularity", "venue_score", "listing_count", "average_price", "lowest_price", "highest_price", "median_price", "primary_performer_score", "performer_2_score")
integer_columns <- c("n_performers", "venue_n_upcoming_events", "primary_performer_event_count", "performer_2_event_count")
factor_columns <- c("country", "region", "Canada", "segment")



# Regions
Northeast <- c("CT", "ME", "MA", "NH", "RI", "VT", "NJ", "NY", "PA", "NL", "NS", "PE", "NB", "QC")
Midwest <- c("IL", "IN", "MI", "OH", "WI", "IA", "KS", "MN", "MO", "NE", "ND", "SD", "ON", "MB")
South <- c("DE", "FL", "GA", "MD", "NC", "SC", "VA", "DC", "WV", "AL", "KY", "MS", "TN", "AR", "LA", "OK", "TX")
West <- c("AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY", "AK", "CA", "HI", "OR", "WA", "BC", "YT", "NT", "NU")

# Assign regions
data$region <- NA
data$region[data$state %in% Northeast] <- "Northeast"
data$region[data$state %in% Midwest] <- "Midwest"
data$region[data$state %in% South] <- "South"
data$region[data$state %in% West] <- "West"
data$region <- as.factor(data$region)

# CanadaTF
data$Canada <- FALSE
data$Canada[data$state %in% c("AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT")] <- TRUE

# Delete "state"
data$state <- NULL
data <- na.omit(data)
## convert columns:
for (col in date_columns) {data[[col]] <- as.Date(data[[col]], format="%Y-%m-%dT%H:%M:%S")}
for (col in numeric_columns) {data[[col]] <- as.numeric(data[[col]])}
for (col in integer_columns) {data[[col]] <- as.integer(data[[col]])}
for (col in factor_columns) {data[[col]] <- as.factor(data[[col]])}


data[["sold_out"]] <- as.factor(data[["sold_out"]])
samplevector <- sample(1:nrow(data), 1800)
train_data <- data[samplevector, ]
test_data <- data[-samplevector,]




lmdata <- train_data

#Linear 
linear_model <- lm(sold_out ~ ., data = train_data)



BESTSUBSET <- regsubsets(sold_out ~., data = train_data, nvmax = length(colnames(train_data)))
BSM <- summary(BESTSUBSET)
data.frame(
  Adj.R2 = which.max(BSM$adjr2),
  CP = which.min(BSM$cp),
  BIC = which.min(BSM$bic)
)
# id: model id
# object: regsubsets object
# data: data used to fit regsubsets
# outcome: outcome variable
get_model_formula <- function(id, object, outcome){
  # get models data
  models <- summary(object)$which[id,-1]
  # Get outcome variable
  #form <- as.formula(object$call[[2]])
  #outcome <- all.vars(form)[1]
  # Get model predictors
  predictors <- names(which(models == TRUE))
  predictors <- paste(predictors, collapse = "+")
  # Build model formula
  as.formula(paste0(outcome, "~", predictors))
}

get_cv_error <- function(model.formula, data){
  set.seed(1)
  train.control <- trainControl(method = "cv", number = 10)
  cv <- train(model.formula, data = data, method = "glm",
              trControl = train.control)
  cv$results
}

BSMids <- c(11, 11, 5)
CVerrors <- map(BSMids, get_model_formula, BESTSUBSET, "sold_out") %>%
  map(get_cv_error, data = prepared_data) %>%
  unlist()


fold <- 10
CVfold <- trainControl(method="cv", number = fold)
LOGMODEL <- train(sold_out ~ ., data = train_data, method = "glm", family = "binomial", trControl = CVfold)



full_tree <- rpart(sold_out ~ ., data = train_data, method = "class")
cp_table <- data.frame(full_tree$cptable)
cp_range <- cp_table[cp_table$CP >= 0.01 & cp_table$CP <= 0.1,]
best_cp <- cp_range[which.min(cp_range$xerror), "CP"]
tune_grid <- data.frame(cp = best_cp)
print(paste("Best CP:", best_cp))

# Prune the tree using the best cp value
best_pruned_tree <- prune(full_tree, cp = best_cp)
TREEMODEL <- train(sold_out ~ .,
                   data = train_data,
                   method = "rpart",
                   trControl = CVfold,
                   tuneGrid = tune_grid)

SVMMODEL <- train(sold_out ~ .,
                  data = train_data,
                  method = "svmRadial",
                  trControl = CVfold)


# Number of predictors (excluding the response variable)
num_predictors <- ncol(train_data) - 1

# Define the range of mtry values to test
mtry_values <- c(2, floor(sqrt(num_predictors)), floor(num_predictors / 2), num_predictors)

# Define the tuning grid
RDF_tune_grid <- expand.grid(
  mtry = mtry_values,
  splitrule = "hellinger",
  min.node.size = c(5, 10) # You can adjust these values
)
RANGERMODEL <- train(sold_out ~ .,
                     data = train_data,
                     method = "ranger",
                     trControl = CVfold,
                     tuneGrid = RDF_tune_grid)


nnet_tune_grid <- expand.grid(size = seq(1, 10, by = 2), # Number of hidden units
                              decay = seq(0, 0.1, by = 0.02))
NNMODEL <- train(
  sold_out ~ .,
  data = train_data,
  method = "nnet",
  trControl = CVfold, # Cross-validation control
  tuneGrid = nnet_tune_grid, # Tuning grid
  MaxNWts = 10000, # Maximum number of weights (increase if needed)
  trace = FALSE # Suppresses verbose output
)




lOGITres <- predict(LOGMODEL, newdata = test_data)
TREEres <- predict(TREEMODEL,newdata = test_data)
SVMres <- predict(SVMMODEL, newdata = test_data)
RANGERres <- predict(RANGERMODEL, newdata = test_data)
NNres <- predict(NNMODEL, newdata = test_data)



LOGITconf <- confusionMatrix(lOGITres, test_data$sold_out)
TREEconf <- confusionMatrix(TREEres, test_data$sold_out)
SVMconf <- confusionMatrix(SVMres, test_data$sold_out)
RANGERconf <- confusionMatrix(RANGERres, test_data$sold_out)
NNconf <- confusionMatrix(NNres, test_data$sold_out)


LOGITmcc <- mcc(lOGITres, test_data$sold_out)
TREEmcc <- mcc(TREEres, test_data$sold_out)
SVMmcc <- mcc(SVMres, test_data$sold_out)
RANGERmcc <- mcc(RANGERres, test_data$sold_out)
NNmcc <- mcc(NNres, test_data$sold_out)


modelsMCC <- list(
  Logit = LOGITmcc,
  ClassificationTrees = TREEmcc,
  SVM = SVMmcc,
  RandomForest = RANGERmcc,
  NeuralNetworks = NNmcc
)


models <- list(
  logit = LOGMODEL,
  classTrees = TREEMODEL,
  SVM = SVMMODEL,
  randomForest = RANGERMODEL,
  NeauralNetworks = NNMODEL
)


results <- resamples(models)
bwplot(results)
