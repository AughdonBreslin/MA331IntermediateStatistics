### R code from vignette source 'unmarked.Rnw'

###################################################
### code chunk number 1: unmarked.Rnw:1-3
###################################################
options(width=70)
options(continue=" ")


###################################################
### code chunk number 2: unmarked.Rnw:93-101
###################################################
library(unmarked)
wt <- read.csv(system.file("csv","widewt.csv", package="unmarked"))
y <- wt[,2:4]
siteCovs <-  wt[,c("elev", "forest", "length")]
obsCovs <- list(date=wt[,c("date.1", "date.2", "date.3")],
    ivel=wt[,c("ivel.1",  "ivel.2", "ivel.3")])
wt <- unmarkedFrameOccu(y = y, siteCovs = siteCovs, obsCovs = obsCovs)
summary(wt)


###################################################
### code chunk number 3: unmarked.Rnw:106-108
###################################################
wt <- csvToUMF(system.file("csv","widewt.csv", package="unmarked"),
               long = FALSE, type = "unmarkedFrameOccu")


###################################################
### code chunk number 4: unmarked.Rnw:115-117
###################################################
pcru <- csvToUMF(system.file("csv","frog2001pcru.csv", package="unmarked"),
                 long = TRUE, type = "unmarkedFrameOccu")


###################################################
### code chunk number 5: unmarked.Rnw:123-124
###################################################
obsCovs(pcru) <- scale(obsCovs(pcru))


###################################################
### code chunk number 6: unmarked.Rnw:132-135
###################################################
fm1 <- occu(~1 ~1, pcru)
fm2 <- occu(~ MinAfterSunset + Temperature ~ 1, pcru)
fm2


###################################################
### code chunk number 7: unmarked.Rnw:150-151
###################################################
backTransform(fm2, 'state')


###################################################
### code chunk number 8: unmarked.Rnw:169-170
###################################################
backTransform(linearComb(fm2, coefficients = c(1,0,0), type = 'det'))


###################################################
### code chunk number 9: unmarked.Rnw:178-180
###################################################
newData <- data.frame(MinAfterSunset = 0, Temperature = -2:2)
round(predict(fm2, type = 'det', newdata = newData, appendData=TRUE), 2)


###################################################
### code chunk number 10: unmarked.Rnw:188-190
###################################################
confint(fm2, type='det')
confint(fm2, type='det', method = "profile")


###################################################
### code chunk number 11: unmarked.Rnw:199-202
###################################################
fms <- fitList('psi(.)p(.)' = fm1, 'psi(.)p(Time+Temp)' = fm2)
modSel(fms)
predict(fms, type='det', newdata = newData)


###################################################
### code chunk number 12: unmarked.Rnw:209-222
###################################################
chisq <- function(fm) {
    umf <- getData(fm)
    y <- getY(umf)
    y[y>1] <- 1
    sr <- fm@sitesRemoved
    if(length(sr)>0)
        y <- y[-sr,,drop=FALSE]
    fv <- fitted(fm, na.rm=TRUE)
    y[is.na(fv)] <- NA
    sum((y-fv)^2/(fv*(1-fv)), na.rm=TRUE)
    }

(pb <- parboot(fm2, statistic=chisq, nsim=100, parallel=FALSE))


###################################################
### code chunk number 13: unmarked.Rnw:247-251
###################################################
re <- ranef(fm2)
EBUP <- bup(re, stat="mode")
CI <- confint(re, level=0.9)
rbind(PAO = c(Estimate = sum(EBUP), colSums(CI)) / 130)


