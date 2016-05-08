setwd("C:/Users/Samruddhi Somani/Documents/McCombs/Spring/Marketing/Project 4")

library(BoomSpikeSlab)
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


