###################### Split into training and testing #######################
smp_size <- floor(0.75 * nrow(balanced.data))
set.seed(101) 
train_ind <- sample(seq_len(nrow(balanced.data)), size = smp_size)
creditcard_train <- balanced.data[train_ind, ]
creditcard_test <- balanced.data[-train_ind, ]
creditcard_train <- creditcard_train[, -1]
creditcard_test <- creditcard_test[, -1]

### Logistic Model ## AUC 0.9411
model_logistic <- glm(data = creditcard_train, Class ~ ., family = binomial())
summary(model_logistic)

invisible(roc(creditcard_train$Class, fitted(model_logistic), plot=T, print.thres = "best", legacy.axes=T,
              print.auc =T,col="red3"))


## KNN
library(class)

model_knn <- knn(train = creditcard_train, 
                 test = creditcard_test, cl = creditcard_train$Class, k = 5)

model_knn_all <- knn(train = creditcard_train, 
                 test = creditcard[,-1], cl = creditcard_train$Class, k = 5)

## Decision Tress

library(rpart)

model_regtree = rpart(data = creditcard_train, Class ~ .)
rpart.plot::prp(model_regtree)

