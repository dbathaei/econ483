# Set the seed for reproducibility (optional)
set.seed(123)
confusion_matrix <- function(depvar, preds, depvar_name, method_name)
{
  tab <- data.frame(table (depvar, preds))
  colnames(tab) <- c(depvar_name, "Predictions", method_name)
  return(tab)
}

MCC <- function(depvar, predictions, depvar_name, method_name)
{
  conf_mat <- confusion_matrix(depvar = depvar, preds =predictions, depvar_name = depvar_name, method_name = method_name)
  
  TN <- conf_mat[1, method_name]# True negative
  FP <- conf_mat[2, method_name]# False positive
  FN <- conf_mat[3, method_name]# False negative  
  TP <- conf_mat[4, method_name]# True positive
  
  TOP1 <- (TP*TN)
  TOP2 <- (FP*FN)
  TOP <- TOP1 - TOP2
  ONE <- (TP + FP)
  TWO <- (TP + FN)
  THREE <- (TN + FP)
  FOUR <- (TN + FN)
  BOTTOM <- ONE*TWO*THREE*FOUR
  BOTTOM <- sqrt(BOTTOM)
  
  MCC <- TOP/BOTTOM
  # MCC <- (TP*TN - FP*FN)/(sqrt( (TP + FP)*(TP + FN)*(TN + FP)*(TN + FN)) ) # Matthews correlation coefficient
  
  return(MCC)
}

sumcc = 0
SUMCC = data.frame(MATT = as.double(0))
SUMCC <- SUMCC[-1,]

for (i in 1:10){
  samplevector <- sample(1:nrow(data), 1800)
  train_data <- data[samplevector, ]
  test_data <- data[-samplevector,]
  RANGERMODEL <- train(sold_out ~ .,
                       data = train_data,
                       method = "ranger",
                       trControl = CVfold,
                       tuneGrid = RDF_tune_grid)
  
  predictions <- predict(RANGERMODEL, newdata = test_data)
  confusion <- confusionMatrix(predictions, test_data$sold_out)
  mcc <- (confusion$table[1,1] * confusion$table[2,2] - confusion$table[1,2] * confusion$table[2,1]) /
    sqrt((confusion$table[1,1] + confusion$table[1,2]) *
           (confusion$table[1,1] + confusion$table[2,1]) *
           (confusion$table[2,2] + confusion$table[1,2]) *
           (confusion$table[2,2] + confusion$table[2,1]))
  newRow <- c(mcc)
  sumcc <- sumcc + mcc
  SUMCC <- rbind(SUMCC,newRow)
  print(confusion)
  cat(sumcc/i, "--", mcc, "\n")
}
