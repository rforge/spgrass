% Copyright 1999-2000 by Roger S. Bivand
%
\name{plot.grassmeta}
\alias{plot.grassmeta}
\alias{legtext}
\alias{leglabs}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Equal scale plots for GRASS raster and site data}
\description{
plot.grassmeta provides a simple interface between grass data objects and the \code{image()} function; category layers may be plotted by taking \code{unclass()} of the layer, and setting zlim to non-default values. If layer is not set, a blank base map is plotted, for instance for use with \code{points()}.
}
\usage{
\method{plot}{grassmeta}(x, layer=NULL, xlab="", ylab="", reverse=NULL, add=FALSE,
 breaks=NULL, ...)
legtext(break.levels)
leglabs(x1, under="under", over="over", between="-")
}

%- maybe also `usage' for other objects documented here.
\arguments{
 \item{x}{GRASS metadata from \code{gmeta()}}
 \item{layer}{GRASS-ordered raster layer passed on to \code{image()}}
 \item{xlab}{a title for the x axis, passed to \code{plot()}}
 \item{ylab}{a title for the y axis, passed to \code{plot()}}
 \item{reverse}{see \code{help(reverse)}}
 \item{add}{FALSE for new plot, TRUE to overlay layer on prior plot}
 \item{\dots}{parameters passed through to \code{image()}}
 \item{break.levels}{vector of image break levels}
 \item{breaks}{vector of image break levels}
 \item{x1}{in leglabs(), a vector of breaks}
 \item{under}{character value to denote under}
 \item{over}{character value to denote over}
 \item{between}{character value to denote between}
}
\details{
 The function uses \code{asp=1} from the \code{plot.window()} function to
ensure that the scales chosen to be equal on both axes, that is 1cm represents
the same units on each. The \code{legtext} function is a small helper to aid
in converting image break levels into legend texts, taking a numeric argument
as \code{image(break=)}, and returning a character vector.
}
\value{
  none
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand, R. S., (2000) Using the R statistical data analysis language on GRASS 5.0 GIS data base files. Computers and Geosciences, 26, pp. 1043-1052.}
\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\note{The functions in this package are intended to work with the GRASS geographical information system. The examples for wrapper functions will will work whether or not R is running in GRASS, and whether or not the current location is that of the data set used for the examples. Examples of interface functions will however (from version 0.2-2) only work outside GRASS, to avoid possible overwriting of GRASS database locations and/or files.}

\seealso{\code{\link{plot.window}}, \code{\link{image}}}

\examples{
data(utm.maas)
Zn.o <- as.ordered(cut(utm.maas$Zn, labels=c("insignificant", "low",
"medium", "high", "crisis"), breaks=c(100, 200, 400, 700, 1000, 2000), 
include.lowest=TRUE))
G <- maas.metadata
plot(G)
points(utm.maas$east, utm.maas$north, pch=unclass(Zn.o))
legend(x=c(269800, 270500), y=c(5652300, 5653000), pch=c(1:5),
legend=levels(Zn.o))
title("Note equal east and north scales")
example(kde2d.G)
}
\keyword{spatial}
\keyword{IO}
\keyword{hplot}
