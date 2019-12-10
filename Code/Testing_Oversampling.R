############ OVER-SAMPLING #############

#### Test Dataset
### Logistic Model (Accuracy: 0.9411)

predict_logistic <- predict.glm(model_logistic, newdata = creditcard_test, type = "response")
pred <- rep(0, nrow(creditcard_test))

pred[predict_logistic > 0.432] <- 1

xtab <- table(pred, creditcard_test$Class)

confusionMatrix(xtab)

cutpointr::F1_score(tp = 232, fp = 7, tn = 231, fn = 22) ###00.9412
cutpointr::recall(tp = 232, fp = 7, tn = 231, fn = 22) ###0.91338
cutpointr::precision(tp = 232, fp = 7, tn = 231, fn = 22) ####0.9707

### KNN Accuracy : 0.9695

caret::confusionMatrix(xtab_knn) 

cutpointr::F1_score(tp = 249, fp = 10, tn = 228, fn = 5) ###0.9707
cutpointr::recall(tp = 249, fp = 10, tn = 228, fn = 5) ###0.9803
cutpointr::precision(tp = 249, fp = 10, tn = 228, fn = 5) ####0.9614

### Decision Trees Accuracy: 0.9248 

pred_regtree <- predict(model_regtree, newdata = creditcard_test)[,2]

pred_1 <- rep(0, nrow(creditcard_test))
pred_1[pred_regtree > 0.453] <- 1


xtab_regtree <- table(pred_1, creditcard_test$Class)

caret::confusionMatrix(xtab_regtree) 

cutpointr::F1_score(tp = 228, fp = 11, tn = 227, fn = 26) ### 0.9249
cutpointr::recall(tp = 228, fp = 11, tn = 227, fn = 26) ### 0.89763
cutpointr::precision(tp = 228, fp = 11, tn = 227, fn = 26) ### 0.9539749

#### Entire Dataset

### Logistic Model (Accuracy: 0.9702)

predict_logistic_all <- predict.glm(model_logistic, newdata = creditcard, type = "response")
pred_all <- rep(0, nrow(creditcard))
pred_all[predict_logistic_all > 0.432] <- 1

xtab_all <- table(pred_all, creditcard$Class)
confusionMatrix(xtab_all)

cutpointr::F1_score(tp = 458, fp = 8460, tn = 275855, fn = 34) ###0.09734
cutpointr::recall(tp = 458, fp = 8460, tn = 275855, fn = 34) ###0.93089
cutpointr::precision(tp = 458, fp = 8460, tn = 275855, fn = 34) ###0.0513

### KNN (Accuracy : 0.9764)

xtab_knn_all <- table(model_knn_all, creditcard$Class)
caret::confusionMatrix(xtab_knn_all) 

cutpointr::F1_score(tp = 462, fp = 6685, tn = 277630, fn = 30) ###0.1209
cutpointr::recall(tp = 462, fp = 6685, tn = 277630, fn = 30) ###0.9390
cutpointr::precision(tp = 462, fp = 6685, tn = 277630, fn = 30) ####0.0646

### Decision Trees Accuracy: 0.5141
pred_regtree_all <- predict(model_regtree, newdata = creditcard[,-1])[,2]

pred_1_all <- rep(0, nrow(creditcard))
pred_1_all[pred_regtree > 0.453] <- 1

xtab_regtree_all <- table(pred_1_all, creditcard$Class)

caret::confusionMatrix(xtab_regtree_all)

cutpointr::F1_score(tp = 218, fp = 138105, tn = 146210, fn = 274) ###0.00314
cutpointr::recall(tp = 218, fp = 138105, tn = 146210, fn = 274) ###0.4431
cutpointr::precision(tp = 218, fp = 138105, tn = 146210, fn = 274) ###0.001576














