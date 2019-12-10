############ UNDER-SAMPLING #############

###################### Split into training and testing #######################
smp_size <- floor(0.75 * nrow(creditcard_new))
set.seed(101) 
train_ind <- sample(seq_len(nrow(creditcard_new)), size = smp_size)
creditcard_train <- creditcard_new[train_ind, ]
creditcard_test <- creditcard_new[-train_ind, ]
creditcard_train <- creditcard_train[, -1]
creditcard_test <- creditcard_test[, -1]

set.seed(100)
creditcard_new <- sample_n(creditcard_notFraud, 492)

creditcard_new <- rbind(creditcard_new, creditcard_fraud)

creditcard_new$Amount[which(!is.finite(creditcard_new$Amount))] <- 0

### Logistic Model 

model_logistic <- glm(data = creditcard_train, Class ~ ., family = binomial())
summary(model_logistic)

invisible(roc(creditcard_train$Class, fitted(model_logistic), plot=T, print.thres = "best", legacy.axes=T,
              print.auc =T,col="red3"))

### KNN

library(class)

model_knn <- knn(train = creditcard_train, 
                 test = creditcard_test, cl = creditcard_train$Class, k = 5)

model_knn_all <- knn(train = creditcard_train, 
                 test = creditcard[,-1], cl = creditcard_train$Class, k = 5)

### Decision Trees

library(rpart)

model_regtree = rpart(data = creditcard_train, Class ~ .)
rpart.plot::prp(model_regtree)

