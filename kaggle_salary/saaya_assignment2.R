# Importing the data
setwd('~/data_science/instr_repo/GADS4/data/kaggle_salary')
data <- read.csv("train.csv")

# 1) Split the data into training and test sets
set.seed(123)
data$fold <- sample(1:10, nrow(data), replace=T)
test <- subset(data, fold == 6)
train <- subset(data, fold != 6)

# MAE Function
mae <- function(x,y){
  return(mean(abs(x-y)))
}

# Testing Function
checkMAE <- function(model){
  trainError <- mae(fitted(model), train$SalaryNormalized)
  testError <- mae(predict(model, test), test$SalaryNormalized)
  results <- c("Training MAE:", trainError, "Test MAE:", testError)
  return(results)
}

# Testing Function for models with log()
checkMAELog <- function(model){
  trainError <- mae(exp(fitted(model)), train$SalaryNormalized)
  testError <- mae(exp(predict(model, test)), test$SalaryNormalized)
  results <- c("Training MAE:", trainError, "Test MAE:", testError)
  return(results)
}

# 2) Build a simple linear regression using the available categorical variables. 
#Test 1: category
model <- lm(SalaryNormalized ~ Category, data=train)
summary(model)
checkMAE(model)
#Check the distribution
hist(train$SalaryNormalized)
hist(log(train$SalaryNormalized))
#Test 1 with log()
model <- lm(log(SalaryNormalized) ~ Category, data=train)
summary(model)
checkMAELog(model)

### This is just an idea written in Python. I wasn't sure how or if it's possible to do this in R.
###
#l = []
#for columnName in train:
#  model = lm(SalaryNormalized ~ columnName, data=train)
#  MAE = checkMAE(model)
#  l.append((columnName, MAE))
###Then, sort l based on trainError or testError to see which columnName has the lowest MAE.
###(assuing checkMAE function would return a list if done in Python: [trainError, testError])
#  return l
###
###After this, I would try and create models with 2, 3, or more of the top columnNames.

#Back to R...
#Some of the models I've tried:
model <- lm(log(SalaryNormalized) ~ Category + Company, data=train) #checkMAELog returned error
model <- lm(log(SalaryNormalized) ~ Category + ContractType, data=train)
model <- lm(log(SalaryNormalized) ~ Category + ContractTime, data=train)
model <- lm(log(SalaryNormalized) ~ Category + LocationNormalized, data=train) #checkMAELog returned error
model <- lm(log(SalaryNormalized) ~ Category + LocationRaw, data=train) # took too long to process
model <- lm(log(SalaryNormalized) ~ Category + SourceName, data=train) #checkMAELog returned error
model <- lm(log(SalaryNormalized) ~ Category + ContractType + ContractTime, data=train) # so far the best
summary(model)
checkMAELog(model)

### Tried to remove the missing data error.
#unique(train$Category)
#train$EngineeringJobs <- grepl("Engineering", train$Category)
#test$EngineeringJobs <- grepl("Engineering", test$Category)
#train$HRJobs <- grepl("HR & Recruitment", train$Category)
#test$HRJobs <- grepl("HR & Recruitment", test$Category)
#
#for(i in unique(train$Category)){
#  
#}
#model <- lm(log(SalaryNormalized) ~ ContractType + ContractTime + EngineeringJobs + HRJobs, data=train)
#summary(model)
#checkMAELog(model)
###

# validation
error_from_fold <- function(n) {
  model <- lm(log(SalaryNormalized) ~ Category + ContractType + ContractTime, data=subset(data, fold != n))
  test <- subset(data, fold == n)
  error <- mae(exp(predict(model, test)), test$SalaryNormalized)
  return(error)
}
sapply(1:10, error_from_fold)
mean(sapply(1:10, error_from_fold))

# Actual test data
testfile <- read.csv("test.csv")

### temporary solution
testfile$Category[testfile$Category=="Part time Jobs"] <- "Other/General Jobs"
###

finalmodel <- lm(log(SalaryNormalized) ~ Category + ContractType + ContractTime, data=data)
predictions <- exp(predict(finalmodel, testfile))

# Write to a file
submission <- data.frame(Id=testfile$Id,
                         Salary=predictions)
write.csv(submission, "Saaya_submission.csv", row.names=FALSE)
