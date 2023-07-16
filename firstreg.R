library(readr) # to read csv

output <- read_csv("output.csv") # reads csv
output <- subset(output, select = -id) # removes "id" column

output[] <- lapply(output, function(x) {
  if(is.character(x) | is.factor(x)) {
    x[is.na(x)] <- "NA"
    x <- as.factor(x)
  }
  return(x)
}) # removes "NA" for all irrelevant data points.


# this bit converts these columns into categories.
factor_vars <- c('name', 'domain', 'day_of_week', 'timezone', 'currency', 'venue_name', 'venue_city', 
                 'venue_country', 'schedule_status', 'cat_1', 'cat_1_subcat', 'cat_2', 'cat_2_subcat',
                 'attraction_1_name', 'attraction_2_name', 'attraction_3_name', 'attraction_4_name',
                 'attraction_5_name')
output[factor_vars] <- lapply(output[factor_vars], factor)


# These two are the codes: Run at your own risk! (takes 10 mins for each to finish)
# model <- glm(sold_out ~ ., data = output, family = binomial(link = "logit"))
# model <- lm(sold_out ~ ., data=output)
