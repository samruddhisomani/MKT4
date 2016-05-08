setwd("C:/Users/Samruddhi Somani/Documents/McCombs/Spring/Marketing/Project 4")

#library(caret)
#library (ROCR)
library(spikeSlabGAM)

# #data load
# load(file="custacquisition_test.RData")
# 
# #scaled x
# #scX=as.data.frame(scale(X))
# 
# #programmatically creating formula
# #
# nK = length(names(X))
# fmla_comp = rep('', nK)  # array of formula components
# for (i in 1:nK) { # fill in formular components
#   fmla_comp[i] = paste0(names(X)[i])
# }
# fmla = as.formula(paste("Resp ~ ", paste(fmla_comp[2:nK], collapse= "+"))) 
#  
# #new data frame
# #newX=cbind.data.frame(Resp,X) 
# 
# glmfit = glm(fmla, data=X, family="binomial")
# summary(glmfit)
# 
# glm_coefs=summary(glmfit)$coefficients[,c(1,4)]
# sig_coefs = glm_coefs[order(glm_coefs[glm_coefs[,2] < 0.05]),]
# order_coefs = sig_coefs[order(sig_coefs[,1], decreasing = TRUE),]
# exp(order_coefs[1:6,1])
# 
# ### Predict
# # read holdout
# load('custacquisition_holdout.RData')
# pred.prob = predict.glm(glmfit, newdata = X, type = 'response')
# summary(pred.prob)
# pred.class = rep(0, length(pred.prob))
# pred.class[pred.prob>0.5] = 1
# table(pred.class)
# 
# cm = confusionMatrix(pred.class, Resp)
# pred <- prediction(pred.class, Resp);
# 
# # Recall-Precision curve             
# RP.perf <- performance(pred, "prec", "rec")
# par(mfrow = c(1, 1))
# plot (RP.perf)
# 
# # ROC curve
# ROC.perf <- performance(pred, "tpr", "fpr");
# plot (ROC.perf)
# 
# # ROC area under the curve
# auc.tmp <- performance(pred,"auc");
# auc <- as.numeric(auc.tmp@y.values)
# miss = 278/(278+64)
# 
# ### rank the probability
# ind = order(pred.prob, decreasing = TRUE)
# 
# prob.rank = pred.prob[ind]
# prob.df = data.frame(prob)
# df = data.frame(prob = pred.prob, response = Resp)
# df.order = df[order(df[,1], decreasing = TRUE),]
# df.order$rank = 1:dim(df)[1]
# head(df.order)
# df.order$percentile = df.order$rank / dim(df)[1] * 100
# head(df.order)
# df.select = df.order[df.order$percentile < 1,]
# 
# rate = c()
# for (i in 1:500) {
#   df.select = df.order[df.order$percentile < i/100,]
#   rate[i] = sum(df.select$Resp)/dim(df.select)[1]
# }
# plot(rate, type = 'b')
# sum(df.select$Resp)/dim(df.select)[1]
# 
# # What would you set the percentile to if the fixed and variable 
# # costs of mailing is $100,000 and $2.50 respectively, and the value 
# # of a lead is $20. Hint: you can use an optimizer here, 
# # or compute the expected profits for a range of top percentiles.
# 
# get_profit <- function(df, x) {
#   df.select = df.order[df.order$percentile < x,]
#   revenue = sum(df.select$Resp * 20)
#   cost = dim(df.select)[1] * 2.5 + 100000
#   profit = revenue - cost
#   all = list(revenue = revenue, cost = cost, profit = profit)
#   return(all)
# }
# 
# profits = c()
# revenue = c()
# cost = c()
# for (i in 1:500) {
#   profits[i] = get_profit(df.order, i)$profit
#   revenue[i] = get_profit(df.order, i)$revenue
#   cost[i] = get_profit(df.order, i)$cost
# }
# plot(profits)
# which.max(profits) / 100

############# Bayesian ##############
#data load
load(file="custacquisition_test.RData")

#scaled x
#scX=as.data.frame(scale(X))

#find categorical variables
dumA = X[, c('Gender', 'Resp_DM', 'MarStatus', 'USCitizen', 'HomeOwner', 'JobMilitary', 'JobHealthcare', 'JobEdu', 
             'JobSmallBusiness', 'Veteran', 'RecentlyMovedIn', 'HasComprehensive', 'SUV', 'SportsCar', 'Truck',
             'RecentMailOrder')]

dumB = X[,84:96]
dum = cbind(dumA, dumB)

#identifying linears 
lin = setdiff(names(X), names(dum))
names(dum)

#building formula object
nK = length(names(dum))
fmla_dum = rep('', nK)
for (i in 2:nK) {
  prefix = "fct"
  fmla_dum[i] = paste0(prefix, "(", names(dum)[i], ")") }

nK = length(lin)
fmla_lin = rep('', nK)
for (i in 2:nK) {
  prefix = "lin"
  fmla_lin[i] = paste0(prefix, "(", lin[i], ")") }

fmla_comp = c(fmla_lin, fmla_dum)
fmla = as.formula(paste("Resp ~ ", paste(fmla_comp, collapse= "+")))

#bayesian variable selection
m = spikeSlabGAM(formula=fmla, data=X, family="binomial")

save.image('oops.Rdata')
