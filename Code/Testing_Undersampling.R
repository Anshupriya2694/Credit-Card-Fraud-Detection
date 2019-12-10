############ UNDER-SAMPLING #############

#### Test Dataset
### Logistic Model (Accuracy: 0.9309)

predict_logistic <- predict.glm(model_logistic, newdata = creditcard_test, type = "response")
pred <- rep(0, 246)
pred[predict_logistic > 0.453] <- 1

xtab <- table(pred, creditcard_test$Class)
confusionMatrix(xtab)

cutpointr::F1_score(tp = 117, fp = 11, tn = 112, fn = 6) ###0.9323
cutpointr::recall(tp = 117, fp = 11, tn = 112, fn = 6) ###0.951
cutpointr::precision(tp = 117, fp = 11, tn = 112, fn = 6) ###0.9141

### KNN (Accuracy : 0.9431)

xtab_knn <- table(model_knn, creditcard_test$Class)
caret::confusionMatrix(xtab_knn) 

cutpointr::F1_score(tp = 117, fp = 6, tn = 79, fn = 44) ###0.8239437
cutpointr::recall(tp = 117, fp = 6, tn = 79, fn = 44) ###0.7267081
cutpointr::precision(tp = 117, fp = 6, tn = 79, fn = 44) ####0.951

### Decision Trees
pred_regtree <- predict(model_regtree, newdata = creditcard_test)[,2]

pred_1 <- rep(0, 246)
pred_1[pred_regtree > 0.453] <- 1

xtab_regtree <- table(pred_1, creditcard_test$Class)

caret::confusionMatrix(xtab_regtree) ##Accuracy 0.9309 

cutpointr::F1_score(tp = 112, fp = 6, tn = 117, fn = 11) ###0.9294606
cutpointr::recall(tp = 112, fp = 6, tn = 117, fn = 11) ###0.9105691
cutpointr::precision(tp = 112, fp = 6, tn = 117, fn = 11) ###0.9491

#### Entire Dataset

### Logistic Model (Accuracy: 0.9413)

predict_logistic_all <- predict.glm(model_logistic, newdata = creditcard, type = "response")
pred_all <- rep(0, nrow(creditcard))
pred_all[predict_logistic_all > 0.453] <- 1

xtab_all <- table(pred_all, creditcard$Class)
confusionMatrix(xtab_all)

cutpointr::F1_score(tp = 472, fp = 16704, tn = 267611, fn = 20) ###0.0534
cutpointr::recall(tp = 472, fp = 16704, tn = 267611, fn = 20) ###0.9593
cutpointr::precision(tp = 472, fp = 16704, tn = 267611, fn = 20) ###0.02748

### KNN (Accuracy : 0.9736)

xtab_knn_all <- table(model_knn_all, creditcard$Class)
caret::confusionMatrix(xtab_knn_all) 

cutpointr::F1_score(tp = 463, fp = 7480, tn = 276835, fn = 29) ###0.1097
cutpointr::recall(tp = 463, fp = 7480, tn = 276835, fn = 29) ###0.94105
cutpointr::precision(tp = 463, fp = 7480, tn = 276835, fn = 29) ####0.05829

### Decision Trees Accuracy: 0.5205
pred_regtree_all <- predict(model_regtree, newdata = creditcard[,-1])[,2]

pred_1_all <- rep(0, nrow(creditcard))
pred_1_all[pred_regtree > 0.453] <- 1

xtab_regtree_all <- table(pred_1_all, creditcard$Class)

caret::confusionMatrix(xtab_regtree_all)

cutpointr::F1_score(tp = 262, fp = 136327, tn = 147988, fn = 230) ###0.00382
cutpointr::recall(tp = 262, fp = 136327, tn = 147988, fn = 230) ###0.5325
cutpointr::precision(tp = 262, fp = 136327, tn = 147988, fn = 230) ###0.001918





