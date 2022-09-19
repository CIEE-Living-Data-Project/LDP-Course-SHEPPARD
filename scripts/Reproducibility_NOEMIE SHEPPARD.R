

#Create GitHub Token to link to OSF
install.packages("usethis")
usethis::create_github_token()
gitcreds::gitcreds_set()

#Create files
dir.create("data/")
dir.create("scripts/")

dir.create("data/url")
dir.create("data/dryad")
dir.create("data/github")

#Install groundhog package to keep track of packages
install.packages("groundhog")
library(groundhog)
ip = as.data.frame(installed.packages()[,c(1)])
pkgs <- ip[1]
groundhog.library(pkgs, "2022-04-20")

#Download data
library(emdbook)
data(ReedfrogFuncresp)

#Fit data with frair package
library(frair)
Reedfrog_fit <- frair_fit(Killed~Initial, data=ReedfrogFuncresp,
                          response="rogersII", 
                          start = list(a = 1, h = 0.1), 
                          fixed = list(T = 1))

#Plot fit
plot(Reedfrog_fit, xlab="Prey Density",pch=21, col="orange", ylab="Prey consumed", ylim=c(0, 35), xlim=c(0,95),xaxs="i",yaxs="i")
lines(Reedfrog_fit, col = "orange", lty = 1)


