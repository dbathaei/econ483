# k-fold cross validation
library(caret)

CVmethod <- trainControl(method="cv", number = 10)

GLMmodel <- train(formula,
                      data = data,
                      method="glm",
                      trControl = CVmethod,
                      family=binomial())

CTREEmodel <- train(formula,
                    data = data,
                    method="ctree",
                    trainControl = CVmethod)
  
print(CTREEmodel)
