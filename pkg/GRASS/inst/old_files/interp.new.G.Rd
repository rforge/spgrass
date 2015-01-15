% Copyright 1999-2003 by Roger S. Bivand
%
\name{interp.new.G}
\alias{interp.new.G}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Interpolation from sites to raster, Akima's new method}
\description{
 A wrapper function for \code{interp.new()} in the \code{akima} package.
}
\usage{
interp.new.G(G, x, y, z, extrap=FALSE, duplicate="error", dupfun=NULL,
	reverse=NULL)
}
%- maybe also `usage' for other objects documented here.
\arguments{
 \item{G}{GRASS metadata from gmeta()}
 \item{x}{Eastings of point locations}
 \item{y}{Northings of point locations}
 \item{z}{Observed point values to be interpolated}
 \item{extrap}{see \code{help(interp.new)}}
 \item{duplicate}{see \code{help(interp.new)}}
 \item{dupfun}{see \code{help(interp.new)}}
 \item{reverse}{see \code{help(reverse)}}
}

\value{
  A vector of \code{G$Ncells} values is returned, with the results of interpolation ordered as a GRASS raster file. NAs are inserted outside the convex hull of the data points.
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand, R. S., (2000) Using the R statistical data analysis language on GRASS 5.0 GIS data base files. Computers and Geosciences, 26, pp. 1043-1052.}
\author{Original \code{interp.new()}: Albrecht Gebhardt as detailed in the akima package documentation; adapted by Roger S. Bivand, \email{Roger.Bivand@nhh.no.}}

\note{The functions in this package are intended to work with the GRASS geographical information system. The examples for wrapper functions will will work whether or not R is running in GRASS, and whether or not the current location is that of the data set used for the examples. Examples of interface functions will however (from version 0.2-2) only work outside GRASS, to avoid possible overwriting of GRASS database locations and/or files.}


\seealso{\code{\link[akima]{interp}}}

\examples{
data(utm.maas)
Zn.o <- as.ordered(cut(utm.maas$Zn, labels=c("insignificant", "low",
"medium", "high", "crisis"), breaks=c(100, 200, 400, 700, 1000, 2000), 
include.lowest=TRUE))
G <- maas.metadata
pdata <- cbind(utm.maas$elev, utm.maas$d.river, log(utm.maas$d.river),
    utm.maas$Zn, log(utm.maas$Zn))
colnames(pdata) <- c("Elevation", "Distance", "Ln(Distance)", "Zinc",
    "Ln(Zinc)")
pairs(pdata)
mod1 <- lm(log(Zn) ~ elev + log(d.river), data=utm.maas)
summary(mod1)
anova(mod1)
inregion <- (utm.maas$east >= G$w & utm.maas$east <= G$e) &
  (utm.maas$north >= G$s & utm.maas$north <= G$n)
if(all(!inregion)) stop("None of the site locations are inside the current GRASS region")
if(any(!inregion))
    warning("Some site locations are outside the current GRASS region")
require(akima)
elev.grid <- interp.new.G(G, utm.maas$east, utm.maas$north, utm.maas$elev,
    extrap=TRUE)
brks <- c(-Inf, seq(5.4, 10.6, 0.52), +Inf)
plot(G, elev.grid*maasmask, breaks=brks,
  col=c("yellow", grey(11:2/11), "red"))
plot(G, ifelse(is.na(maasmask), 1, NA), breaks=c(0,2), col="wheat", add=TRUE)
title("Bicubic spline interpolation: local elevation")
legend(c(269900, 270600), c(5652000, 5652900), bty="n", bg="wheat",
   legend=c(rev(leglabs(brks)), "mask=NA"),
   fill=c("red", rev(grey(11:2/11)), "yellow", "wheat"))
ldist <- loess(d.river ~ east * north, data=utm.maas, span=0.2,
 control = loess.control(surface = "direct"))
bank <- predict(ldist, newdata=data.frame(east=east(maas.metadata),
 north=north(maas.metadata)))
b1 <- bank*maasmask
b1[b1 < 5] <- 5
brks <- c(seq(0, 1000, 200), +Inf)
cols <- grey(6:2/6)
plot(maas.metadata, b1, breaks=brks, col=c(cols, "red"))
plot(maas.metadata, ifelse(is.na(maasmask), 1, NA), breaks=c(0,2), col="wheat", add=TRUE)
title("Loess predictions of distance from river bank")
legend(c(269900, 270600), c(5652000, 5652900), bty="n", bg="wheat",
   legend=c(rev(leglabs(brks)), "mask=NA"),
 fill=c("red", rev(cols), "wheat"))
new <- data.frame(elev=elev.grid*maasmask, d.river=b1)
pr.mod1 <- predict(mod1, new, se.fit=TRUE)
rm(new, elev.grid, bank)
v.pr <- rep(NA, G$Ncells)
v.pr[as.integer(names(pr.mod1$fit))] <- pr.mod1$fit
summary(v.pr)
summary(exp(v.pr))
plot(G, exp(v.pr), breaks=c(-200, round(seq(142, 1154, length=9)), 5000),
  col=c("yellow", grey(9:2/9), "red"))
plot(G, ifelse(is.na(maasmask), 1, NA), col="wheat", add=TRUE)
title("Regression predictions of Zn levels, (B&McD p. 113)")
legend(c(269900, 270600), c(5652000, 5652900), bty="n", bg="wheat",
   legend=c("> 1154", rev(legtext(round(seq(142, 1154, length=9)))), "< 142",
   "mask=NA"), fill=c("red", rev(grey(9:2/9)), "yellow", "wheat"))
v.pr[as.integer(names(pr.mod1$se.fit))] <- pr.mod1$se.fit
plot(G, exp(v.pr), col=grey(16:2/16))
plot(G, ifelse(is.na(maasmask), 1, NA), col="wheat", add=TRUE)
points(utm.maas$east, utm.maas$north, pch=18)
title("Standard error of predictions")
Zn.grid <- interp.new.G(G, utm.maas$east, utm.maas$north, utm.maas$Zn,
    extrap=TRUE)
plot(G, Zn.grid*maasmask, breaks=c(-500, round(seq(15,1994,length=9)), 3000),
  col=c("yellow", grey(9:2/9), "red"))
plot(G, ifelse(is.na(maasmask), 1, NA), col="wheat", add=TRUE)
title(xlab="B&McD p. 118", main="Bicubic spline interpolation: Zn ppm")
legend(c(269900, 270600), c(5652000, 5652900), bty="n", bg="wheat",
   legend=c("> 1994", rev(legtext(round(seq(15,1994,length=9)))), "< 15",
   "mask=NA"), fill=c("red", rev(grey(9:2/9)), "yellow", "wheat"))
\dontrun{
sites.put2(G, utm.maas, dims=c("east", "north", "elev"),
  lname="ex.utm.maas1", check=FALSE)
system("s.surf.idw input=ex.utm.maas1 output=Zn.idw npoints=98 field=7")
idw <- rast.get(G, "Zn.idw")
plot(G, idw$Zn.idw*maasmask, breaks=c(-100, round(seq(15,1994,length=9)), 3000),
  col=c("yellow", grey(9:2/9), "red"))
plot(G, ifelse(is.na(maasmask), 1, NA), col="wheat", add=TRUE)
title(xlab="B&McD p. 118",
  main="Inverse squared distance interpolation: Zn ppm")
legend(c(269900, 270600), c(5652000, 5652900), bty="n", bg="wheat",
  legend=c("> 1994", rev(legtext(round(seq(15,1994,length=9)))), "< 15",
  "mask=NA"), fill=c("red", rev(grey(9:2/9)), "yellow", "wheat"))
}
}
\keyword{spatial}
\keyword{IO}
