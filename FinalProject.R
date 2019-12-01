library(ggplot2)
library(dplyr)
require(caTools)
library(pROC)
library(caret)

options(scipen = 999)
creditcard <- read_csv("creditcard.csv")

summary(creditcard)
creditcard$Class <- as.factor(creditcard$Class)

ggplot(data = creditcard, aes(Class)) + geom_histogram(stat = "count")

slices <- c(284315, 492)
lbls <- c("Not Fraudulent", "Fraudulent")
pct <- round(slices/sum(slices)*100, 2)
lbls <- paste(lbls, pct)
lbls <- paste(lbls,"%",sep="")
pie(slices, labels = lbls)

ggplot(data = creditcard, aes(Amount)) + geom_histogram()

ggplot(data = creditcard, aes(Time, Amount)) + geom_bar(stat = "identity") + 
  ylim(0, 10000)


creditcard_fraud <- creditcard[creditcard$Class == 1, ]
creditcard_notFraud <- creditcard[creditcard$Class == 0, ]

############################# Under-sampling #################################

set.seed(100)
creditcard_new <- sample_n(creditcard_notFraud, 492)

creditcard_new <- rbind(creditcard_new, creditcard_fraud)
summary(creditcard_new)

ggplot(data = creditcard_new, aes(Class)) + geom_histogram(stat = "count")

ggplot(data = creditcard_new, aes(Amount)) + geom_histogram()

ggplot(data = creditcard_new, aes(Time, Amount)) + geom_bar(stat = "identity") + 
  ylim(0, 10000)


smp_size <- floor(0.75 * nrow(creditcard_new))
set.seed(101) 
train_ind <- sample(seq_len(nrow(creditcard_new)), size = smp_size)
creditcard_train <- creditcard_new[train_ind, ]
creditcard_test <- creditcard_new[-train_ind, ]

### Independent Variable EDA

creditcard_cor <- creditcard_new[1:30]
mydata <- cbind(creditcard_cor, as.numeric(creditcard_new$Class))
names(mydata) <- c("Time", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10",
                   "V11", "V12", "V13", "V14",  "V15", "V16", "V17", "V18", "V19", "V20",
                   "V21", "V22", "V23", "V24", "V25", "V26", "V27", "V28", "Amount",
                   "Class" )

cormat <- round(cor(mydata),2)
library(reshape2)
melted_cormat <- melt(cormat)
ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()

# Get lower triangle of the correlation matrix
get_lower_tri<-function(cormat){
  cormat[upper.tri(cormat)] <- NA
  return(cormat)
}
# Get upper triangle of the correlation matrix
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}

upper_tri <- get_upper_tri(cormat)
upper_tri
melted_cormat <- melt(upper_tri, na.rm = TRUE)
ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 1, 
                                   size = 10, hjust = 1))+
  coord_fixed()



### Logistic Model 
model_logistic <- glm(data = creditcard_train, Class ~ ., family = binomial())
summary(model_logistic)

invisible(roc(creditcard_train$Class, fitted(model_logistic), plot=T, print.thres = "best", legacy.axes=T,
              print.auc =T,col="red3"))

predict_logistic <- predict.glm(model_logistic, newdata = creditcard_test, type = "response")
pred <- rep(0, 246)

predict_logistic_full <- predict.glm(model_logistic, newdata = creditcard, type = "response")

pred[predict_logistic > 0.482] <- 1

pred_full <- rep(0, nrow(creditcard))
pred_full[predict_logistic_full > 0.482] <- 1

xtab <- table(pred, creditcard_test$Class)

confusionMatrix(xtab)

xtab_full <- table(pred_full, creditcard$Class)

confusionMatrix(xtab_full)

cutpointr::F1_score(tp = 463, fp = 15755, tn = 268560, fn = 29)
cutpointr::recall(tp = 463, fp = 15755, tn = 268560, fn = 29)

## KNN
library(class)

model_knn <- knn(train = creditcard_train, 
                 test = creditcard_test, cl = creditcard_train$Class, k = 1)

xtab_knn <- table(model_knn, creditcard_test$Class)

caret::confusionMatrix(xtab_knn) 
### Accuracy : 0.6789

model_knn_full <- knn(train = creditcard_train, 
                 test = creditcard, cl = creditcard_train$Class, k = 1)

xtab_knn_full <- table(model_knn_full, creditcard$Class)

caret::confusionMatrix(xtab_knn_full) ###Accuracy 0.6439


## Decision Tress

library(rpart)

model_regtree = rpart(data = creditcard_train, Class ~ .)
rpart.plot::prp(model_regtree)

pred_regtree <- predict(model_regtree, newdata = creditcard_test)[,2]

pred_1 <- rep(0, 246)
pred_1[pred_regtree > 0.482] <- 1

xtab_regtree <- table(pred_1, creditcard_test$Class)

caret::confusionMatrix(xtab_regtree) ## 0.939

pred_regtree_full <- predict(model_regtree, newdata = creditcard)[,2]
pred_1_full <- rep(0, 284807)
pred_1_full[pred_regtree > 0.482] <- 1

xtab_regtree_full <- table(pred_1_full, creditcard$Class)

caret::confusionMatrix(xtab_regtree_full) ## 0.5691

##################### Over Sampling SMOTE ############################








