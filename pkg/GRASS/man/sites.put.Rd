% Copyright 1999-2003 by Roger S. Bivand
%
\name{sites.put}
\alias{sites.put}
\alias{sites.put2}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Export GRASS sites file}
\description{
 \code{sites.put()} moves a single numeric or character vector site to GRASS, using the metadata from \code{gmeta()}. \code{sites.put2()} moves a data frame to a GRASS sites list, and requires the specification of the columns of the data frame to be treated as dimensions.
}
\usage{
sites.put(G, lname="", east, north, var, debug=FALSE)
sites.put2(G, data, id=NULL, dims, lname="", all.sites=FALSE,
	check=TRUE)
}
%- maybe also `usage' for other objects documented here.
\arguments{
 \item{G}{GRASS metadata from \code{gmeta()}}
 \item{lname}{Name for new GRASS sites file}
 \item{east}{Eastings of points}
 \item{north}{Northings of points}
 \item{var}{numeric or character vector of attribute values at these points for export}
 \item{debug}{if TRUE, the temporary ASCII file used for transfer is not deleted on exit from the function}
 \item{data}{data frame to be exported as a GRASS 5.0 format sites list}
 \item{id}{default NULL, can be the index or name of a numeric column in data}
 \item{dims}{character vector of column names or integer vector of column indices in data for sites list coordinates, expected to be in x, y, z1, ... order}
 \item{all.sites}{if FALSE, retreive only sites in current GRASS region, if TRUE, retreive all sites}
 \item{check}{check to see if \code{lname} already exists as a sites list in the GRASS database, and abort if it does; if FALSE \code{sites.put2()} will overwrite existing files (default TRUE)}
}
\value{
  none
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand, R. S., (2000) Using the R statistical data analysis language on GRASS 5.0 GIS data base files. Computers and Geosciences, 26, pp. 1043-1052.}
\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\note{The functions in this package are intended to work with the GRASS geographical information system. The examples for wrapper functions will will work whether or not R is running in GRASS, and whether or not the current location is that of the data set used for the examples. Examples of interface functions will however (from version 0.2-2) only work outside GRASS, to avoid possible overwriting of GRASS database locations and/or files.}

\seealso{\code{\link{sites.get}}}

\examples{
if(!get("maas.loc", env = .GRASS.meta)) make.maas.location()
data(utm.maas)
Zn.o <- as.ordered(cut(utm.maas$Zn, labels=c("insignificant", "low",
"medium", "high", "crisis"), breaks=c(100, 200, 400, 700, 1000, 2000), 
include.lowest=TRUE))
G <- gmeta()
nameQ <- c("ex.Zn.in", "ex.Znlog.in", "ex.Zncat.in")
Zn <- data.frame(east=utm.maas$east, north=utm.maas$north, Zn=utm.maas$Zn)
sites.put2(G, Zn, dims=c("east", "north"), lname=nameQ[1], check=FALSE)
log.Zn <- data.frame(east=utm.maas$east, north=utm.maas$north,
 log.Zn=log(utm.maas$Zn))
sites.put2(G, log.Zn, dims=c("east", "north"), lname=nameQ[2], check=FALSE)
Zn.o.df <- data.frame(east=utm.maas$east, north=utm.maas$north, Zn.o=Zn.o)
sites.put2(G, Zn.o.df, dims=c("east", "north"), lname=nameQ[3], check=FALSE)
newdf <- data.frame(utm.maas, Zn.o)
sites.put2(G, newdf, dims=c("east", "north", "elev"), lname="ex.utm.maas",
 check=FALSE)
}
\keyword{spatial}
\keyword{IO}
