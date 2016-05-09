setwd("C:/Users/Samruddhi Somani/Documents/McCombs/Spring/Marketing/Project 4")

library(BoomSpikeSlab)
library(stargazer)
library(caret)
library(reshape2)
library(ggplot2)
library(ggthemes)
library(Rsolnp)

load('custacquisition_test.Rdata')

#find categorical variables
dumA = X[, c('Gender', 'Resp_DM', 'MarStatus', 'USCitizen', 'HomeOwner', 'JobMilitary', 'JobHealthcare', 'JobEdu', 
             'JobSmallBusiness', 'Veteran', 'RecentlyMovedIn', 'HasComprehensive', 'SUV', 'SportsCar', 'Truck',
             'RecentMailOrder')]

dumB = X[,84:96]
dum = cbind(dumA, dumB)

#changing dummies to factors
X_mod=X
X_mod[,names(dum)]=lapply(X[,names(dum)],factor)

#programmatic formula creation
nK = length(names(X))
fmla_comp = rep('', nK)  # array of formula components
for (i in 1:nK) { # fill in formular components
  fmla_comp[i] = paste0(names(X)[i])
}


fmla = as.formula(paste("Resp ~ ", paste(fmla_comp[2:nK], collapse= "+")))

#fitting logit glm
glmfit=glm(fmla,data=X_mod, family='binomial')
summary(glmfit)


#fitting bayesian model
start=Sys.time()
print(start)

lzp=LogitZellnerPrior(mm,successes=Resp,expected.model.size=20,prior.success.probability=mean(Resp))

ss=logit.spike(fmla,niter=1000,data=X_mod,initial_value=glmfit,seed=42,ping=10,nthreads=3,prior=lzp)

end=Sys.time()

timespent=end-start

save.image('oops.Rdata')

print (timespent)

#pulling model names
coef=summary(ss)$coefficients

new=rownames(coef[coef[,5]!=0,])[2:14]

for (n in 1:length(new)){
  new[n]=gsub ('[[:digit:]]+', '', new[n])
}

fmla_new=paste("Resp~",paste(new,collapse="+"))
glmfit2=glm(as.formula(fmla_new),data=X_mod,family='binomial')

#quadratic
fmla_new2=paste0(fmla_new,"+I(Age^2)+I(Socio_Finance^2)")
glmfit3=glm(as.formula(fmla_new2),data=X_mod, family='binomial')

#interactions
fmla_new3=paste0(fmla_new2,"+Gender:MarStatus+Age:MarStatus+UnemployRate:MarStatus+UnemployRate:Gender")
glmfit4=glm(as.formula(fmla_new3),data=X_mod,family='binomial')

################
#VALIDATIONS###
################

load("custacquisition_holdout.Rdata")

#changing dummies to factors
X_mod=X
X_mod[,names(dum)]=lapply(X[,names(dum)],factor)

p=predict(glmfit,X_mod,type="response")
bp=predict(glmfit3,X_mod,type="response")

#translating to class
p_f=as.integer(p>0.5)
bp_f=as.integer(bp>0.5)
tbl=rbind(table(p_f),table(bp_f),table(Resp))
rownames(tbl)=c('Frequentist','Bayesian','Actual')

#confusion matrix
confusionMatrix(p_f, Resp)
confusionMatrix(bp_f,Resp)


### original glm
ind = order(p, decreasing = TRUE)

prob.rank = p[ind]
df = data.frame(prob = p, response = Resp)
df.order = df[order(df[,1], decreasing = TRUE),]

df.order$rank = 1:dim(df)[1]
head(df.order)

df.order$percentile = df.order$rank / dim(df)[1] * 100
head(df.order)

rate_original = rep(0,500)

for (i in 1:500) {
  df.select = df.order[df.order$percentile < i/100,]
  rate_original[i] = sum(df.select$Resp)/dim(df.select)[1]
}

#optimization
get_profit <- function(df, x) {
  df.select = df.order[df.order$percentile < x,]
  revenue = sum(df.select$Resp * 20)
  cost = dim(df.select)[1] * 2.5 + 100000
  profit = revenue - cost
  all = list(revenue = revenue, cost = cost, profit = profit)
  return(all)
}

profits = c(NA,500)
revenue = c(NA,500)
cost = c(NA,500)
for (i in 1:500) {
  profits[i] = get_profit(df.order, i/100)$profit
  revenue[i] = get_profit(df.order, i/100)$revenue
  cost[i] = get_profit(df.order, i/100)$cost
}
plot(profits,main="Simple Logit: Profits versus Targeted Percentile",xlab="Percentile x 100",ylab="Profit")
which.max(profits) / 100

plot(rate, type = 'b',main="Response Rate versus Percentile",xlab="Percentile x 100",ylab="Response Rate")

###bayesian glm
ind = order(bp, decreasing = TRUE)

prob.rank = bp[ind]
df = data.frame(prob = bp, response = Resp)
df.order = df[order(df[,1], decreasing = TRUE),]

df.order$rank = 1:dim(df)[1]
head(df.order)

df.order$percentile = df.order$rank / dim(df)[1] * 100
head(df.order)

rate_bayesian = rep(0,500)

for (i in 1:500) {
  df.select = df.order[df.order$percentile < i/100,]
  rate_bayesian[i] = sum(df.select$Resp)/dim(df.select)[1]
}

plot(rate, type = 'b',main="Response Rate versus Percentile",xlab="Percentile x 100",ylab="Response Rate")

rate=cbind.data.frame(Simple=rate_original,Bayesian=rate_bayesian,i=seq(0.01,5,by=0.01))
rate_melt=melt(rate,id=c(i))

#optimization
get_profit <- function(df, x) {
  df.select = df.order[df.order$percentile < x,]
  revenue = sum(df.select$Resp * 20)
  cost = dim(df.select)[1] * 2.5 + 100000
  profit = revenue - cost
  all = list(revenue = revenue, cost = cost, profit = profit)
  return(all)
}

profits = c(NA,500)
revenue = c(NA,500)
cost = c(NA,500)
for (i in 1:500) {
  profits[i] = get_profit(df.order, i/100)$profit
  revenue[i] = get_profit(df.order, i/100)$revenue
  cost[i] = get_profit(df.order, i/100)$cost
}
plot(profits,main="Bayesian: Profits versus Targeted Percentile",xlab="Percentile x 100",ylab="Profit")
which.max(profits) / 100


#visualization
ggplot(data=rate_melt)+geom_point(aes(x=i,y=value),size=3)+theme_few()+facet_grid(variable~.)


#address set
load("custacquisition_addresslist.Rdata")

#changing dummies to factors
X_mod=X
X_mod[,names(dum)]=lapply(X[,names(dum)],factor)

new_p=predict(glmfit3,X_mod,type="response")

###bayesian glm
ind = order(new_p, decreasing = TRUE)


df = data.frame(index = ind, prob = new_p)
df.order = df[order(df[,2], decreasing = TRUE),]
head(df.order)
df.order$rank = 1:length(new_p)
head(df.order)

df.order$percentile = df.order$rank / dim(df)[1] * 100
head(df.order)

selected = df.order[df.order$percentile<2.13,]
dim(selected)
tail(selected)

write.csv(selected, 'address.csv')

sum(selected$prob*20)

