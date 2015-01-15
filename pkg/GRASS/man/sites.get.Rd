% Copyright 1999-2003 by Roger S. Bivand
%
\name{sites.get}
\alias{sites.get}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Import GRASS sites file}
\description{
 \code{sites.get} moves one GRASS 5.0 sites file to a data frame, returning the filled object.
}
\usage{
sites.get(G, slist="", all.sites=FALSE, collapse.labels=TRUE, debug=FALSE, interp=FALSE)
}
%- maybe also `usage' for other objects documented here.
\arguments{
 \item{G}{GRASS metadata from \code{gmeta()}}
 \item{slist}{GRASS sites file name}
 \item{all.sites}{if FALSE, retreive only sites in current GRASS region, if TRUE, retreive all sites}
 \item{collapse.labels}{If the sites file is old-style or malformed (d.sites.pg map=), collapse label strings to single string per point}
 \item{debug}{if TRUE, the temporary ASCII file used for transfer in interpreted mode is not deleted on exit from the function}
 \item{interp}{if TRUE, the interpreted version of the function is used instead of the loaded compiled version}
}
\value{
  A data frame with columns: east, north, and var1, ..., varn, where n is the number of attributes held in the GRASS sites file, some of which may be factors, and which may include the site id number. Under the interpreted interface, the attributes are named var1, var2, etc., under the compiled interface as id, str1, str2, etc., num1, num2, etc., unless the sites file has a labels header containing the same number of labels as the number of columns in the data table returned, in which case the labels are used.
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand, R. S., (2000) Using the R statistical data analysis language on GRASS 5.0 GIS data base files. Computers and Geosciences, 26, pp. 1043-1052.}
\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\note{The functions in this package are intended to work with the GRASS geographical information system. The examples for wrapper functions will will work whether or not R is running in GRASS, and whether or not the current location is that of the data set used for the examples. Examples of interface functions will however (from version 0.2-2) only work outside GRASS, to avoid possible overwriting of GRASS database locations and/or files.}

\seealso{\code{\link{sites.put}}}

\examples{
if(!get("maas.loc", env = .GRASS.meta)) make.maas.location()
G <- gmeta()
example(sites.put)
ex.Zn.log <- sites.get(G, slist="ex.Znlog.in")
mean(ex.Zn.log$log.Zn - log(utm.maas$Zn))
ex.Zn.cat <- sites.get(G, slist="ex.Zncat.in")
table(Zn.o, ex.Zn.cat$Zn.o)
utm.maas.new <- sites.get(G, slist="ex.utm.maas")
names(utm.maas.new)
table(Zn.o, utm.maas.new$Zn.o)
}
\keyword{spatial}
\keyword{IO}
