library(ggplot2)
library(dplyr)
require(caTools)
library(pROC)
library(caret)
library(purrr)
library(tidyr)
library(jcolors)
jcolors('default')
library(reshape2)

options(scipen = 999)

### Reading Data

creditcard <- read.csv("creditcard.csv")
summary(creditcard)
creditcard$Class <- as.factor(creditcard$Class)

############### Full Dataset EDA ###################

### Distribution of Variable Amount 
ggplot(data = creditcard, aes(Amount)) + geom_histogram(fill = "blue", alpha = 0.6) 
## Highly Skewed, performing log transformation

creditcard$Amount = log(creditcard$Amount)
ggplot(data = creditcard, aes(Amount)) + geom_histogram(fill = "blue", alpha = 0.6)
## Looks better

### distribution of other variables

p1 <- ggplot(data = creditcard, aes(V1)) + geom_histogram(fill = "blue", alpha = 0.6)
p2 <- ggplot(data = creditcard, aes(V2)) + geom_histogram(fill = "blue", alpha = 0.6)
p3 <- ggplot(data = creditcard, aes(V3)) + geom_histogram(fill = "blue", alpha = 0.6)
p4 <- ggplot(data = creditcard, aes(V4)) + geom_histogram(fill = "blue", alpha = 0.6)
p5 <- ggplot(data = creditcard, aes(V5)) + geom_histogram(fill = "blue", alpha = 0.6)
p6 <- ggplot(data = creditcard, aes(V6)) + geom_histogram(fill = "blue", alpha = 0.6)
p7 <- ggplot(data = creditcard, aes(V7)) + geom_histogram(fill = "blue", alpha = 0.6)
p8 <- ggplot(data = creditcard, aes(V8)) + geom_histogram(fill = "blue", alpha = 0.6)
p9 <- ggplot(data = creditcard, aes(V9)) + geom_histogram(fill = "blue", alpha = 0.6)
p10 <- ggplot(data = creditcard, aes(V10)) + geom_histogram(fill = "blue", alpha = 0.6)
p11 <- ggplot(data = creditcard, aes(V11)) + geom_histogram(fill = "blue", alpha = 0.6)
p12 <- ggplot(data = creditcard, aes(V12)) + geom_histogram(fill = "blue", alpha = 0.6)
p13 <- ggplot(data = creditcard, aes(V13)) + geom_histogram(fill = "blue", alpha = 0.6)
p14 <- ggplot(data = creditcard, aes(V14)) + geom_histogram(fill = "blue", alpha = 0.6)
p15 <- ggplot(data = creditcard, aes(V15)) + geom_histogram(fill = "blue", alpha = 0.6)
p16 <- ggplot(data = creditcard, aes(V16)) + geom_histogram(fill = "blue", alpha = 0.6)
p17 <- ggplot(data = creditcard, aes(V17)) + geom_histogram(fill = "blue", alpha = 0.6)
p18 <- ggplot(data = creditcard, aes(V18)) + geom_histogram(fill = "blue", alpha = 0.6)
p19 <- ggplot(data = creditcard, aes(V19)) + geom_histogram(fill = "blue", alpha = 0.6)
p20 <- ggplot(data = creditcard, aes(V20)) + geom_histogram(fill = "blue", alpha = 0.6)
p21 <- ggplot(data = creditcard, aes(V21)) + geom_histogram(fill = "blue", alpha = 0.6)
p22 <- ggplot(data = creditcard, aes(V22)) + geom_histogram(fill = "blue", alpha = 0.6)
p23 <- ggplot(data = creditcard, aes(V23)) + geom_histogram(fill = "blue", alpha = 0.6)
p24 <- ggplot(data = creditcard, aes(V24)) + geom_histogram(fill = "blue", alpha = 0.6)
p25 <- ggplot(data = creditcard, aes(V25)) + geom_histogram(fill = "blue", alpha = 0.6)
p26 <- ggplot(data = creditcard, aes(V26)) + geom_histogram(fill = "blue", alpha = 0.6)
p27 <- ggplot(data = creditcard, aes(V27)) + geom_histogram(fill = "blue", alpha = 0.6)
p28 <- ggplot(data = creditcard, aes(V28)) + geom_histogram(fill = "blue", alpha = 0.6)

gridExtra::grid.arrange(p1, p2, p3, p4, p6, p7, p8, p9, p10, p11, p12, p13, p14,
                        p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25,
                        p26, p27, p28)
#### Some variables exhibit normal distribution, some don't


#### Relationship with time - No special relationship

ggplot(data = creditcard, aes(x = Time, y = exp(Amount))) +
  geom_line(aes(color = Class)) + scale_color_jcolors(palette = "pal2")

### Dependent Variable Distribution - Highly imbalanced
ggplot(data = creditcard, aes(Class)) + geom_histogram(stat = "count", 
                                                       fill = "blue", alpha = 0.6)

## Amount Distribution
ggplot(data = creditcard, aes(x = Class, y = exp(Amount), color = Class)) + geom_jitter()

### Pie chart of distribution
slices <- c(284315, 492)
lbls <- c("Not Fraudulent", "Fraudulent")
pct <- round(slices/sum(slices)*100, 2)
lbls <- paste(lbls, pct)
lbls <- paste(lbls,"%",sep="")
colors = c("royalblue2", "red")
pie(slices, labels = lbls, col = colors)

### Correlation with Class - not reliable due to heavy imbalance in data

creditcard_cor <- creditcard[1:30]
mydata <- cbind(creditcard_cor, as.numeric(creditcard$Class))
names(mydata) <- c("Time", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10",
                   "V11", "V12", "V13", "V14",  "V15", "V16", "V17", "V18", "V19", "V20",
                   "V21", "V22", "V23", "V24", "V25", "V26", "V27", "V28", "Amount",
                   "Class" )

cormat <- round(cor(mydata),2)

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


