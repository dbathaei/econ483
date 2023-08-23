library(dplyr)

# Extract results
tree_results <- TREEMODEL$results %>% mutate(Model = "Decision Tree")
svm_results <- SVMMODEL$results %>% mutate(Model = "SVM")
ranger_results <- RANGERMODEL$results %>% mutate(Model = "Random Forest")
nn_results <- NNMODEL$results %>% mutate(Model = "Neural Network")

# Combine results
combined_results <- bind_rows(tree_results, svm_results, ranger_results, nn_results)


# Extract results for logistic model
log_results <- data.frame(
  Model = "Logistic Regression",
  Accuracy = 1 - LOGMODEL$delta[1],
  Kappa = NA, # Kappa might not be directly available from cv.glm
  AccuracySD = NA, # Standard deviations might not be directly available from cv.glm
  KappaSD = NA
)

# Add logistic model results to the combined results
final_results <- bind_rows(combined_results, log_results)
