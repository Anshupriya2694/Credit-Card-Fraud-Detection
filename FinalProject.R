library(ggplot2)
library(dplyr)
require(caTools)
library(pROC)
library(caret)

options(scipen = 999)
creditcard <- read.csv("creditcard.csv")

summary(creditcard)
creditcard$Class <- as.factor(creditcard$Class)
creditcard$Amount = log(creditcard$Amount)

ggplot(data = creditcard, aes(Class)) + geom_histogram(stat = "count", 
                                                       fill = "blue", alpha = 0.6)

#ggplot(data = creditcard, aes(x = Class, y = Amount, color = Class)) + geom_jitter()

slices <- c(284315, 492)
lbls <- c("Not Fraudulent", "Fraudulent")
pct <- round(slices/sum(slices)*100, 2)
lbls <- paste(lbls, pct)
lbls <- paste(lbls,"%",sep="")
colors = c("royalblue2", "red")
pie(slices, labels = lbls, col = colors)

ggplot(data = creditcard, aes(Amount)) + geom_histogram(fill = "blue", alpha = 0.6,
                                                             aes(y =..density..))

#ggplot(data = creditcard, aes(Time, exp(Amount))) + geom_bar(stat = "identity")

############### Full Dataset EDA ###################

### Independent Variable EDA

creditcard_cor <- creditcard[1:30]
mydata <- cbind(creditcard_cor, as.numeric(creditcard$Class))
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





#################### Splitting of the Dataset #######################

creditcard_fraud <- creditcard[creditcard$Class == 1, ]
creditcard_notFraud <- creditcard[creditcard$Class == 0, ]

library(jcolors)
jcolors('default')

ggplot(data = creditcard, aes(x = Time, y = exp(Amount))) +
  geom_line(aes(color = Class)) + scale_color_jcolors(palette = "pal2")

############## T-SNE ##########

library(Rtsne)

train_Rtsne <- creditcard
Labels <- train_Rtsne$Class
train_Rtsne$Class <- as.factor(train_Rtsne$Class)

colors = rainbow(length(unique(train_Rtsne$Class)))
names(colors) = unique(train_Rtsne$Class)

tsne_full <- Rtsne(train_Rtsne[, -1], dims = 2, perplexity = 30, verbose = TRUE, max_iter = 49,
              check_duplicates = FALSE)

d_tsne_1 = as.data.frame(tsne_full$Y)

ggplot(d_tsne_1, aes(x=V1, y=V2, col = train_Rtsne$Class, alpha = 0.4)) +  
  geom_point(size=0.25) #+
  #guides(colour=guide_legend(override.aes=list(size=6))) +
  #theme_light(base_size=20) +
  #theme(axis.text.x=element_blank(),
  #      axis.text.y=element_blank())
#plot(tsne_full$Y)

#text(tsne_full$Y, labels = train_Rtsne$Class, col = colors[train_Rtsne$Class])

############################# Under-sampling #################################

set.seed(100)
creditcard_new <- sample_n(creditcard_notFraud, 492)

creditcard_new <- rbind(creditcard_new, creditcard_fraud)

creditcard_new$Amount[which(!is.finite(creditcard_new$Amount))] <- 0

ggplot(data = creditcard_new, aes(Class)) + geom_histogram(stat = "count", 
                                                           fill = "blue", alpha = 0.6)

ggplot(data = creditcard_new, aes(Amount)) + geom_histogram(fill = "blue", alpha = 0.6)

ggplot(data = creditcard_new, aes(Time, Amount)) + geom_line(col = "blue", alpha = 0.6)

ggplot(data = creditcard_new, aes(x = Time, y = Amount)) +
  geom_line(aes(color = Class)) + scale_color_jcolors(palette = "pal2")

###################### Split into training and testing #######################
smp_size <- floor(0.75 * nrow(creditcard_new))
set.seed(101) 
train_ind <- sample(seq_len(nrow(creditcard_new)), size = smp_size)
creditcard_train <- creditcard_new[train_ind, ]
creditcard_test <- creditcard_new[-train_ind, ]
creditcard_train <- creditcard_train[, -1]
creditcard_test <- creditcard_test[, -1]
####################### Independent Variable EDA ##########################

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


#Variables - V2, V4, V11 - high positive; V14, V12, V10 - high negative



############## T-SNE Undersampling ##########

library(Rtsne)

train <- creditcard_new
Labels <- train_Rtsne$Class
train$Class <- as.factor(train$Class)

colors = rainbow(length(unique(train$Class)))
names(colors) = unique(train$Class)

tsne <- Rtsne(train[,-1], dims = 2, perplexity = 40, verbose=TRUE, max_iter = 500, 
              check_duplicates = F)


d_tsne_2 = as.data.frame(tsne$Y)

ggplot(d_tsne_2, aes(x=V1, y=V2, col = train$Class)) +  
  geom_point(size=0.25)

### Logistic Model 
model_logistic <- glm(data = creditcard_train, Class ~ ., family = binomial())
summary(model_logistic)

invisible(roc(creditcard_train$Class, fitted(model_logistic), plot=T, print.thres = "best", legacy.axes=T,
              print.auc =T,col="red3"))

predict_logistic <- predict.glm(model_logistic, newdata = creditcard_test, type = "response")
pred <- rep(0, 246)

predict_logistic_full <- predict.glm(model_logistic, newdata = creditcard, type = "response")

pred[predict_logistic > 0.453] <- 1

pred_full <- rep(0, nrow(creditcard))
pred_full[predict_logistic_full > 0.482] <- 1

xtab <- table(pred, creditcard_test$Class)

confusionMatrix(xtab)

xtab_full <- table(pred_full, creditcard$Class)

confusionMatrix(xtab_full)

cutpointr::F1_score(tp = 113, fp = 10, tn = 119, fn = 4) ###0.9416667
cutpointr::recall(tp = 113, fp = 10, tn = 119, fn = 4) ###0.965812
cutpointr::precision(tp = 113, fp = 10, tn = 119, fn = 4)

## KNN
library(class)

model_knn <- knn(train = creditcard_train, 
                 test = creditcard_test, cl = creditcard_train$Class, k = 1)

xtab_knn <- table(model_knn, creditcard_test$Class)

caret::confusionMatrix(xtab_knn) 
### Accuracy : 0.9431

cutpointr::F1_score(tp = 117, fp = 6, tn = 79, fn = 44) ###0.8239437
cutpointr::recall(tp = 117, fp = 6, tn = 79, fn = 44) ###0.7267081
cutpointr::precision(tp = 117, fp = 6, tn = 79, fn = 44) ###0.9512195
plot.roc()
model_knn_full <- knn(train = creditcard_train, 
                 test = creditcard, cl = creditcard_train$Class, k = 1)

xtab_knn_full <- table(model_knn_full, creditcard$Class)

caret::confusionMatrix(xtab_knn_full) ###Accuracy 0.6439


## Decision Trees

library(rpart)

model_regtree = rpart(data = creditcard_train, Class ~ .)
rpart.plot::prp(model_regtree)

pred_regtree <- predict(model_regtree, newdata = creditcard_test)[,2]

pred_1 <- rep(0, 246)
pred_1[pred_regtree > 0.453] <- 1


xtab_regtree <- table(pred_1, creditcard_test$Class)

caret::confusionMatrix(xtab_regtree) ##Accuracy 0.9309 

cutpointr::F1_score(tp = 112, fp = 6, tn = 117, fn = 11) ###0.9294606
cutpointr::recall(tp = 112, fp = 6, tn = 117, fn = 11) ###0.9105691
cutpointr::precision(tp = 112, fp = 6, tn = 117, fn = 11)
pred_regtree_full <- predict(model_regtree, newdata = creditcard)[,2] 
pred_1_full <- rep(0, 284807)
pred_1_full[pred_regtree > 0.482] <- 1

xtab_regtree_full <- table(pred_1_full, creditcard$Class)

caret::confusionMatrix(xtab_regtree_full) ## 0.5691

##################### Over Sampling SMOTE ############################

library(DMwR)
balanced.data <- SMOTE(Class ~., creditcard, 
                       perc.over = 100)

balanced.data$Amount[which(!is.finite(balanced.data$Amount))] <- 0

#### EDA #####

ggplot(data = balanced.data, aes(Class)) + geom_histogram(stat = "count", 
                                                           fill = "blue", alpha = 0.6)

ggplot(data = balanced.data, aes(Amount)) + geom_histogram(fill = "blue", alpha = 0.6)

ggplot(data = balanced.data, aes(Time, Amount)) + geom_line(col = "blue", alpha = 0.6)

ggplot(data = balanced.data, aes(x = Time, y = Amount)) +
  geom_line(aes(color = Class)) + scale_color_jcolors(palette = "pal2")

###################### Split into training and testing #######################
smp_size <- floor(0.75 * nrow(balanced.data))
set.seed(101) 
train_ind <- sample(seq_len(nrow(balanced.data)), size = smp_size)
creditcard_train <- balanced.data[train_ind, ]
creditcard_test <- balanced.data[-train_ind, ]
creditcard_train <- balanced.data[, -1]
creditcard_test <- balanced.data[, -1]
####################### Independent Variable EDA ##########################

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


#Variables - V2, V4, V11 - high positive; V14, V12, V10 - high negative



############## T-SNE Undersampling ##########

library(Rtsne)

train <- balanced.data
Labels <- train_Rtsne$Class
train$Class <- as.factor(train$Class)

colors = rainbow(length(unique(train$Class)))
names(colors) = unique(train$Class)

tsne <- Rtsne(train[,-1], dims = 2, perplexity = 40, verbose=TRUE, max_iter = 500, 
              check_duplicates = F)


d_tsne_2 = as.data.frame(tsne$Y)

ggplot(d_tsne_2, aes(x=V1, y=V2, col = train$Class)) +  
  geom_point(size=0.25)



### Logistic Model ## AUC 0.992
model_logistic <- glm(data = creditcard_train, Class ~ ., family = binomial())
summary(model_logistic)

invisible(roc(creditcard_train$Class, fitted(model_logistic), plot=T, print.thres = "best", legacy.axes=T,
              print.auc =T,col="red3"))

predict_logistic <- predict.glm(model_logistic, newdata = creditcard_test, type = "response")
pred <- rep(0, 1968)

predict_logistic_full <- predict.glm(model_logistic, newdata = creditcard, type = "response")

pred[predict_logistic > 0.422] <- 1

pred_full <- rep(0, nrow(creditcard))
pred_full[predict_logistic_full > 0.482] <- 1

xtab <- table(pred, creditcard_test$Class)

confusionMatrix(xtab)

xtab_full <- table(pred_full, creditcard$Class)

###  Accuracy : 0.9644

confusionMatrix(xtab_full)

cutpointr::F1_score(tp = 938, fp = 24, tn = 960, fn = 46) ###0.9640288
cutpointr::recall(tp = 938, fp = 24, tn = 960, fn = 46) ###0.953252
cutpointr::precision(tp = 938, fp = 24, tn = 960, fn = 46)

## KNN
library(class)

model_knn <- knn(train = creditcard_train, 
                 test = creditcard_test, cl = creditcard_train$Class, k = 1)

xtab_knn <- table(model_knn, creditcard_test$Class)

caret::confusionMatrix(xtab_knn) 
### Accuracy : 1

cutpointr::F1_score(tp = 117, fp = 6, tn = 79, fn = 44) ###0.8239437
cutpointr::recall(tp = 117, fp = 6, tn = 79, fn = 44) ###0.7267081
cutpointr::precision(tp = 117, fp = 6, tn = 79, fn = 44) #### 0.9512195
plot.roc()
model_knn_full <- knn(train = creditcard_train, 
                      test = creditcard, cl = creditcard_train$Class, k = 1)

xtab_knn_full <- table(model_knn_full, creditcard$Class)

caret::confusionMatrix(xtab_knn_full) ###Accuracy 0.6439


## Decision Tress

library(rpart)

model_regtree = rpart(data = creditcard_train, Class ~ .)
rpart.plot::prp(model_regtree)

pred_regtree <- predict(model_regtree, newdata = creditcard_test)[,2]

pred_1 <- rep(0, 1968)
pred_1[pred_regtree > 0.453] <- 1


xtab_regtree <- table(pred_1, creditcard_test$Class)

caret::confusionMatrix(xtab_regtree) ##Accuracy : 0.9405

cutpointr::F1_score(tp = 915, fp = 69, tn = 936, fn = 48) ### 0.9399076
cutpointr::recall(tp = 915, fp = 69, tn = 936, fn = 48) ### 0.9501558
cutpointr::precision(tp = 915, fp = 69, tn = 936, fn = 48)
pred_regtree_full <- predict(model_regtree, newdata = creditcard)[,2] 
pred_1_full <- rep(0, 284807)
pred_1_full[pred_regtree > 0.482] <- 1

xtab_regtree_full <- table(pred_1_full, creditcard$Class)

caret::confusionMatrix(xtab_regtree_full) ## 0.5691


