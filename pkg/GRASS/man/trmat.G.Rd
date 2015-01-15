% Copyright 1999-2000 by Roger S. Bivand
%
\name{trmat.G}
\alias{trmat.G}
\title{Evaluate Trend Surface over a GRASS Grid}
\description{
 A wrapper for \code{trmat()} from the \code{spatial} package in the VR bundle, using the metadata of the underlying GRASS LOCATION.
}
\usage{
trmat.G(G, obj, east=NULL, north=NULL)
}
%- maybe also `usage' for other objects documented here.
\arguments{
 \item{G}{GRASS metadata from \code{gmeta()}}
 \item{obj}{object returned by \code{surf.ls} or \code{surf.gls}}
 \item{east}{see \code{help(east)}}
 \item{north}{see \code{help(north)}}
}

\value{
  A vector of \code{G$Ncells} values is returned, with the results of interpolation ordered as a GRASS raster file.
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand, R. S., (2000) Using the R statistical data analysis language on GRASS 5.0 GIS data base files. \emph{Computers and Geosciences}, 26, pp. 1043-1052; Unwin, D. J., Wrigley, N. (1987) Towards a general-theory of control point distribution effects in trend surface models. \emph{Computers and Geosciences}, 13, pp. 351-355.}
\author{Original \code{trmat()}: Brian D. Ripley and Bill Venables as detailed in the spatial package documentation; adapted by Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\note{The functions in this package are intended to work with the GRASS geographical information system. The examples for wrapper functions will will work whether or not R is running in GRASS, and whether or not the current location is that of the data set used for the examples. Examples of interface functions will however (from version 0.2-2) only work outside GRASS, to avoid possible overwriting of GRASS database locations and/or files.}

\seealso{\code{\link[spatial]{trmat}}}

\examples{
data(utm.maas)
G <- maas.metadata
if(G$Ncells != length(maasmask))
    stop("example not running in Maas GRASS location")
require(spatial)
s1 <- surf.ls(1, utm.maas$east, utm.maas$north, utm.maas$Zn)
s2 <- surf.ls(2, utm.maas$east, utm.maas$north, utm.maas$Zn)
s3 <- surf.ls(3, utm.maas$east, utm.maas$north, utm.maas$Zn)
s4 <- surf.ls(4, utm.maas$east, utm.maas$north, utm.maas$Zn)
summary(s2)
summary(s3)
summary(s4)
anova(s2,s3,s4)
plot(G, trmat.G(G, s3)*maasmask, breaks=c(-10000, seq(-100, 1500, 200),
  10000), col=c("yellow", grey(8:1/8), "red"))
plot(G, ifelse(is.na(maasmask), 1, NA), breaks=c(0,2), col="wheat", add=TRUE)
plot(s3, add=TRUE)
legend(c(269900, 270600), c(5652000, 5652900), bty="n", bg="wheat",
  legend=c("> 1500", rev(legtext(seq(-100,1500,200))), "< -100", "mask=NA"),
  fill=c("red", rev(grey(8:1/8)), "yellow", "wheat"))
oldpar <- par(mfrow=c(2,2))
plot(G, trmat.G(G, s1)*maasmask, breaks=c(-10000, seq(-100, 1500, 200),
  10000), col=c("yellow", grey(8:1/8), "red"))
plot(G, ifelse(is.na(maasmask), 1, NA), breaks=c(0,2), col="wheat", add=TRUE)
plot(s1, add=TRUE)
plot(G, trmat.G(G, s2)*maasmask, breaks=c(-10000, seq(-100, 1500, 200),
  10000), col=c("yellow", grey(8:1/8), "red"))
plot(G, ifelse(is.na(maasmask), 1, NA), breaks=c(0,2), col="wheat", add=TRUE)
plot(s2, add=TRUE)
plot(G, trmat.G(G, s3)*maasmask, breaks=c(-10000, seq(-100, 1500, 200),
  10000), col=c("yellow", grey(8:1/8), "red"))
plot(G, ifelse(is.na(maasmask), 1, NA), breaks=c(0,2), col="wheat", add=TRUE)
plot(s3, add=TRUE)
plot(G, trmat.G(G, s4)*maasmask, breaks=c(-10000, seq(-100, 1500, 200),
  10000), col=c("yellow", grey(8:1/8), "red"))
plot(G, ifelse(is.na(maasmask), 1, NA), breaks=c(0,2), col="wheat", add=TRUE)
plot(s4, add=TRUE)
par(oldpar)
}
\keyword{spatial}
\keyword{IO}
