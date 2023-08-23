library(leaps)

# Prepare the data
X <- model.matrix(sold_out ~ . - 1, data) # Create model matrix (removing intercept)

# Compute the correlation matrix
cor_matrix <- cor(X)

# Find pairs with high correlation
high_cor <- findCorrelation(cor_matrix, cutoff = 0.75)

# Remove one of the highly correlated pairs
X_filtered <- X[, -high_cor]

# Re-run best subset selection
best_subset_filtered <- regsubsets(sold_out ~ ., data = data.frame(X_filtered, sold_out = data$sold_out), nvmax = ncol(X_filtered))
# Get summary of best subset selection
summary_best_subset <- summary(best_subset_filtered)

# Identify the best model based on Cp (or other criteria)
BMADJR <- which.min(summary_best_subset$adjr2)
BMCP <- which.min(summary_best_subset$cp)
BMBIC <- which.min(summary_best_subset$bic)

# Get the names of the best predictors
BMADJRpr <- names(coef(best_subset_filtered, id = BMADJR))
BMCPpr <- names(coef(best_subset_filtered, id = BMCP))
BMBICpr <- names(coef(best_subset_filtered, id = BMBIC))


formADJR <- as.formula(paste("sold_out ~", paste(BMADJRpr[-1], collapse=" + "))) # Exclude intercept
formCP <- as.formula(paste("sold_out ~", paste(BMCPpr[-1], collapse=" + "))) # Exclude intercept
formBIC <- as.formula(paste("sold_out ~", paste(BMBICpr[-1], collapse=" + "))) # Exclude intercept

