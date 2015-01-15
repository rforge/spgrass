% Copyright 2003 by Roger S. Bivand
%
\name{get.mapsets}
\alias{get.mapsets}
\alias{refresh.mapsets}
\title{Access GRASS readable mapsets search path}
\description{
Access GRASS readable mapsets search path by reading the internal structure
read from the \code{SEARCH\_PATH} file in the current mapset root.
}
\usage{
get.mapsets()
refresh.mapsets()
}
\value{
\code{get.mapsets()} returns the current setting as a character vector of 
mapsets, while \code{refresh.mapsets()} returns the updated mapset names, 
also as a character vector.
}
\details{
The functions are needed because the R interface is run as
a GRASS program within which the \code{SEARCH\_PATH} file is
only read once. If, during an R/GRASS session, a command such
as \code{system("g.mapsets mapset=new.mapset")} is given, the
\code{SEARCH\_PATH} file will be updated, but not the values earlier
read into the interface. Consequently, after any \code{system("g.mapsets
mapset=\ldots")}, \code{refresh.mapsets()} should be run to update the
internal values.
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand,
R. S., (2000) Using the R statistical data analysis language on GRASS
5.0 GIS data base files. Computers and Geosciences, 26, pp. 1043-1052.}
\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\keyword{spatial}
\keyword{IO}

