############ UNDER-SAMPLING #############

### Logistic Model (Accuracy: 0.9309)

predict_logistic <- predict.glm(model_logistic, newdata = creditcard_test, type = "response")
pred <- rep(0, 246)
pred[predict_logistic > 0.453] <- 1

xtab <- table(pred, creditcard_test$Class)
confusionMatrix(xtab)

cutpointr::F1_score(tp = 117, fp = 6, tn = 112, fn = 11) ###0.9323
cutpointr::recall(tp = 117, fp = 6, tn = 112, fn = 11) ###0.914
cutpointr::precision(tp = 117, fp = 6, tn = 112, fn = 11) ###0.951

### KNN (Accuracy : 0.9431)

caret::confusionMatrix(xtab_knn) 

cutpointr::F1_score(tp = 117, fp = 6, tn = 79, fn = 44) ###0.8239437
cutpointr::recall(tp = 117, fp = 6, tn = 79, fn = 44) ###0.7267081
cutpointr::precision(tp = 117, fp = 6, tn = 79, fn = 44) ####0.951

### Decision Trees


pred_1 <- rep(0, 246)
pred_1[pred_regtree > 0.453] <- 1

xtab_regtree <- table(pred_1, creditcard_test$Class)

caret::confusionMatrix(xtab_regtree) ##Accuracy 0.9309 

cutpointr::F1_score(tp = 112, fp = 6, tn = 117, fn = 11) ###0.9294606
cutpointr::recall(tp = 112, fp = 6, tn = 117, fn = 11) ###0.9105691
cutpointr::precision(tp = 112, fp = 6, tn = 117, fn = 11) ###0.9491
