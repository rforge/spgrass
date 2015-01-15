% Copyright 1999-2000 by Roger S. Bivand
%
\name{kde2d.G}
\alias{kde2d.G}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Two-Dimensional Kernel Density Estimation on a GRASS Grid}
\description{
 A version of \code{kde2d()} in the MASS package of the VR collection using the metadata of the underlying GRASS LOCATION. \code{kde2d()} is for "two-dimensional kernel density estimation with an axis-aligned bivariate normal kernel, evaluated on a square grid." An optional feature is the introduction of a weighted moving average through the Z argument.
}
\usage{
kde2d.G(G, x, y, h, reverse=NULL, Z=NULL)
}
%- maybe also `usage' for other objects documented here.
\arguments{
 \item{G}{GRASS metadata from \code{gmeta()}}
 \item{x}{x coordinate of data}
 \item{y}{y coordinate of data}
 \item{h}{vector of bandwidths for x and y directions.
             Defaults to normal reference bandwidth.}
 \item{reverse}{see \code{help(reverse)}}
 \item{Z}{vector of attribute values}
}
\value{
  A vector of \code{G$Ncells} values is returned, with the results of density/weighted moving average calculations ordered as a GRASS raster file. Density values are points per unit area, while moving average values are in the units of the Z variable.
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand, R. S., (2000) Using the R statistical data analysis language on GRASS 5.0 GIS data base files. Computers and Geosciences, 26, pp. 1043-1052.}
\author{Original \code{kde2d(), bandwidth.nrd()}: Brian D. Ripley and Bill Venables as detailed in the MASS package documentation; adapted by Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\note{The functions in this package are intended to work with the GRASS geographical information system. The examples for wrapper functions will will work whether or not R is running in GRASS, and whether or not the current location is that of the data set used for the examples. Examples of interface functions will however (from version 0.2-2) only work outside GRASS, to avoid possible overwriting of GRASS database locations and/or files.}


\seealso{\code{\link[MASS]{kde2d}}}

\examples{
data(utm.maas)
G <- maas.metadata
inregion <- (utm.maas$east >= G$w & utm.maas$east <= G$e) &
  (utm.maas$north >= G$s & utm.maas$north <= G$n)
if(all(!inregion)) stop("None of the site locations are inside the current GRASS region")
if(any(!inregion)) warning("Some site locations are outside the current GRASS region")
plot(G, kde2d.G(G=G, utm.maas$east, utm.maas$north, h=c(300,300))*maasmask)
points(utm.maas$east, utm.maas$north)
rug(utm.maas$east, side=1, ticksize=0.02)
rug(utm.maas$north, side=2, ticksize=0.02)
title(main="Kernel estimates of density of soil sample placing",
  xlab="(Bailey & Gatrell, pp. 84-88")
plot(G, kde2d.G(G=G, utm.maas$east, utm.maas$north, h=c(300,300), Z=utm.maas$Zn)*maasmask)
points(utm.maas$east, utm.maas$north)
rug(utm.maas$east, side=1, ticksize=0.02)
rug(utm.maas$north, side=2, ticksize=0.02)
title(main="Kernel density weighted average, Zn ppm",
  xlab="(Bailey & Gatrell, pp. 159-161")
}
\keyword{spatial}
\keyword{IO}
