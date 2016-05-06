
#data load
load(file="custacquisition_test.RData")

#scaled x
#scX=as.data.frame(scale(X))

#programmatically creating formula
#
nK = length(names(X))
fmla_comp = rep('', nK)  # array of formula components
for (i in 1:nK) { # fill in formular components
  fmla_comp[i] = paste0(names(X)[i])
}
fmla = as.formula(paste("Resp ~ ", paste(fmla_comp[2:nK], collapse= "+"))) 
 
#new data frame
#newX=cbind.data.frame(Resp,X) 

glmfit = glm(fmla, data=X, family="binomial")
summary(glmfit)

glm_coefs=summary(glmfit)$coefficients[,c(1,4)]
sig_coefs = glm_coefs[order(glm_coefs[glm_coefs[,2] < 0.05]),]
order_coefs = sig_coefs[order(sig_coefs[,1], decreasing = TRUE),]
exp(order_coefs[1:6,1])

#data validation 
load(file='custacquisition_holdout.Rdata')
