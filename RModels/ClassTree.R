library(rpart)

# Fit the full tree
full_tree <- rpart(sold_out ~ ., data = data, method = "class")

# Extract the cp table
cp_table <- data.frame(full_tree$cptable)

# Filter the cp values within the desired range
cp_range <- cp_table[cp_table$CP >= 0.01 & cp_table$CP <= 0.1,]

# Find the best cp value (i.e., the one with the lowest xerror)
best_cp <- cp_range[which.min(cp_range$xerror), "CP"]

# Print the best cp value
print(paste("Best CP:", best_cp))

# Prune the tree using the best cp value
best_pruned_tree <- prune(full_tree, cp = best_cp)

# Visualize the pruned tree
plot(best_pruned_tree)
text(best_pruned_tree)
