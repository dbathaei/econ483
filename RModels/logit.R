categorical_columns <- c("country", "region", "segment")

# Create a formula to include all the categorical variables
dummy_formula <- as.formula(paste("~", paste(categorical_columns, collapse=" + ")))

# Create dummy variables using model.matrix()
dummy_vars <- model.matrix(dummy_formula, data = data)[, -1] # Exclude intercept column

# Combine dummy variables with original data (excluding original categorical variables)
prepared_data <- cbind(data[, !(names(data) %in% categorical_columns)], dummy_vars)

