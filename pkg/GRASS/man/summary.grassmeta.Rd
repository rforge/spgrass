% Copyright 1999-2000 by Roger S. Bivand
%
\name{summary.grassmeta}
\alias{summary.grassmeta}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Display GRASS metadata}
\description{
 \code{summary.grassmeta()} displays the metadata collected by gmeta().
}
\usage{
\method{summary}{grassmeta}(object, ...)
}
%- maybe also `usage' for other objects documented here.
\arguments{
 \item{object}{GRASS metadata from \code{gmeta()}}
 \item{...}{other generic arguments}
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand, R. S., (2000) Using the R statistical data analysis language on GRASS 5.0 GIS data base files. Computers and Geosciences, 26, pp. 1043-1052.}
\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\note{The functions in this package are intended to work with the GRASS geographical information system. The examples for wrapper functions will will work whether or not R is running in GRASS, and whether or not the current location is that of the data set used for the examples. Examples of interface functions will however (from version 0.2-2) only work outside GRASS, to avoid possible overwriting of GRASS database locations and/or files.}

\seealso{\code{\link{gmeta}}}

\examples{
if(!get("maas.loc", env = .GRASS.meta)) make.maas.location()
G <- gmeta()
summary(G)
}
\keyword{spatial}
\keyword{IO}
