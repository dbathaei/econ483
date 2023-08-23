nnData <- data[,-which(names(data) %in% c("region", "Canada", "country", "local_date", "announce_date", "segment"))]
nnData$sold_out <- as.numeric(nnData$sold_out)
maxs <- apply(nnData, 2, max)
mins <- apply(nnData, 2, min)
scaled <- as.data.frame(scale(nnData,
                              center = mins,
                              scale = maxs - mins))

nnData$region <- data$region
nnData$country <- data$country
nnData$local_date <- data$local_date
nnData$announce_date <- data$announce_date
nnData$segment <- data$segment


train_ <- scaled[samplevector,]
test_ <- scaled[-samplevector,]


library(neuralnet)

n <- names(train_)

f <- as.formula(paste("sold_out ~",
                      paste(n[!n %in% "sold_out"],
                           collapse = " + ")))
nn <- neuralnet(f,
                data = train_,
                hidden = c(4,2),
                linear.output = TRUE)

