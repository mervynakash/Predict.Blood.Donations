set.seed(123)
setwd("E:/Kaggle/Driven Data/Blood Donations/")

library(rpart)
library(randomForest)
library(dplyr)
library(ROCR)
library(earth)
library(Matrix)
library(xgboost)

train <- read.csv("Training.csv",
                  header = TRUE,
                  stringsAsFactors = FALSE,
                  na.strings = c("NA",NA,""," "))

test <- read.csv("Test.csv",
                 header = TRUE,
                 stringsAsFactors = FALSE,
                 na.strings = c("NA",NA,""," "))

str(train)
str(test)

View(train)
View(test)

#train$Made.Donation.in.March.2007 <- as.factor(train$Made.Donation.in.March.2007)

sapply(train, class)

colSums(is.na(train))
colSums(is.na(test))

colnames(train)
colnames(test)

#train <- train %>% mutate(Average.Donation = round((Months.since.First.Donation - Months.since.Last.Donation)/Number.of.Donations, 0))
#test <- test %>% mutate(Average.Donation = round((Months.since.First.Donation - Months.since.Last.Donation)/Number.of.Donations, 0))


#train <- train %>% mutate(Prob = abs(Average.Donation - Months.since.Last.Donation))
#test <- test %>% mutate(Prob = abs(Average.Donation - Months.since.Last.Donation))

#IV <- create_infotables(data = train, y = "Made.Donation.in.March.2007", parallel = FALSE)
#IV$Summary


#================================ Logistic Regression ======================================#

model1 <- glm(Made.Donation.in.March.2007~., data = train, family = binomial(link = "logit"))
summary(model1)
anova(model1, test = "Chisq")

model2 <- glm(Made.Donation.in.March.2007~Months.since.Last.Donation+Number.of.Donations+Months.since.First.Donation,
              data = train, family = binomial(link = "logit"))
summary(model2)
anova(model2, test = "Chisq")

anova(model1, model2)

split <- sample(seq_len(nrow(train)), size = floor(0.75 * nrow(train)))
new.train <- train[split,]
new.test <- train[-split,]

log.model <- glm(Made.Donation.in.March.2007~., data = new.train %>% select(-Total.Volume.Donated..c.c..), family = binomial(link = "logit"))

log.predict <- predict(log.model, new.test, type = "response")
log.predict <- ifelse(log.predict>0.5, 1, 0)

mean(log.predict == new.test$Made.Donation.in.March.2007)


glmmodel <- glm(Made.Donation.in.March.2007~., data = train %>% select(-Total.Volume.Donated..c.c..), family = binomial(link = "logit"))
glmpred <- predict(glmmodel, test, type = "response")
glmpred <- round(glmpred, 2)


solutionglm <- data.frame(test$X,Made.Donation.in.March.2007 = glmpred)
colnames(solutionglm) <- c("","Made Donation in March 2007")

write.csv(solutionglm, file = "solution_logit.csv", row.names = F)


#======================================= Decision Tree ======================================#

model_dt <- rpart(Made.Donation.in.March.2007~., data=train, control = rpart.control(cp = 0))
printcp(model_dt)

cpval <- model_dt$cptable[which.min(model_dt$cptable[,"xerror"]),"CP"]

model_dt_prune <- prune(model_dt, cp = cpval)

preddt <- predict(model_dt_prune, test)

solutiondt <- data.frame(test$X, Made.Donation.in.March.2007 = preddt)
colnames(solutiondt) <- c("","Made Donation in March 2007")

write.csv(solutiondt, file = "solution_dt.csv", row.names = F)


#======================================= MARSpline =========================================#

# Forward Pruning
model_mars_for <- earth(as.factor(Made.Donation.in.March.2007)~.,data = train, pmethod = "forward")
pred_mars_for <- as.numeric(predict(model_mars_for, test))

solutionmars <- data.frame(test$X, Made.Donation.in.March.2007 = pred_mars_for)
colnames(solutionmars) <- c("","Made Donation in March 2007")

solutionmars$`Made Donation in March 2007` <- ifelse(solutionmars$`Made Donation in March 2007`<0, 0, solutionmars$`Made Donation in March 2007`)

write.csv(solutionmars, file = "solutionmars.csv", row.names = F)

# Backward Pruning 
model_mars_back <- earth(as.factor(Made.Donation.in.March.2007)~.,data = train, pmethod = "backward")
pred_mars_back <- as.numeric(predict(model_mars_back, test))

solutionmars_back <- data.frame(test$X, Made.Donation.in.March.2007 = pred_mars_back)
colnames(solutionmars_back) <- c("","Made Donation in March 2007")

write.csv(solutionmars_back,file = "solutionmars_back.csv", row.names = F)

# Cross Validation Pruning
model_mars_cv <- earth(as.factor(Made.Donation.in.March.2007)~.,data = train, pmethod = "cv", nfold = 10, ncross = 3)
pred_mars_cv <- as.numeric(predict(model_mars_cv, test))

solutionmars_cv <- data.frame(test$X, Made.Donation.in.March.2007 = pred_mars_cv)
colnames(solutionmars_cv) <- c("","Made Donation in March 2007")

write.csv(solutionmars_cv,file = "solutionmars_cv.csv", row.names = F)


#============================ xgBoost ===============================================#

train.mat <- sparse.model.matrix(Made.Donation.in.March.2007~., train)
test.mat <- sparse.model.matrix(~., test)
head(train.mat)

dtrain <- xgb.DMatrix(data=train.mat, label = train$Made.Donation.in.March.2007)

xgbModel <- xgboost(dtrain, max_depth = 13, nthreads = 2, nrounds = 4,
                    eta = 1, objective = "binary:logistic", verbose = 2)

xgbpred <- predict(xgbModel, test.mat)

solutions_xgb <- data.frame(test$X, Made.Donation.in.March.2007 = xgbpred)
colnames(solutions_xgb) <- c("","Made Donation in March 2007")

write.csv(solutions_xgb, file = "solutions_xgb.csv", row.names = F)
