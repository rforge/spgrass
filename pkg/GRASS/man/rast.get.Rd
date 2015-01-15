% Copyright 1999-2004 by Roger S. Bivand
%
\name{rast.get}
\alias{rast.get}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Import GRASS raster files}
\description{
\code{rast.get()} moves one or more GRASS 5.0 raster files to a list, returning the filled object. Setting \code{catlabels} elements, corresponding to the files named in rlist, to TRUE, imports category labels instead of codes yielding an ordered factor rather than a numeric vector, and requires more memory.
}
\usage{
rast.get(G, rlist="", catlabels=NULL, drop.unused.levels=FALSE, 
	make.ordered=TRUE, debug=FALSE, interp=FALSE)
}
\details{
\code{rast.get()} assumes firstly that the region of the GRASS LOCATION has not been changed since gmeta() was last run, secondly that resolutions of the requested map layers and the GRASS LOCATION are in accord, and thirdly that the data cover the selected region. If the second or third assumptions are not met for the interpreted version, the GRASS program \code{r.stats} run through \code{system()} will read from the underlying map layers according to the new region setting, yielding cell values at the current resolution, and inserting NAs in areas for which there are no data. For the compiled version, the user is required to work within a given map region at the same resolution.
}
%- maybe also `usage' for other objects documented here.
\arguments{
 \item{G}{GRASS metadata from \code{gmeta()}}
 \item{rlist}{character vector of GRASS raster file names; may include mapset qualifiers}
 \item{catlabels}{logical vector of length \code{length(rlist)}: if TRUE, GRASS category raster layers are imported as ordered factors, if FALSE, as numeric only}
 \item{drop.unused.levels}{default FALSE, if TRUE, drop unused levels from factor. Beware: some levels may be absent from a region of a location but should be retained, use TRUE with caution. The argument will be applied to all layers read during a single call to \code{read.get()}.}
 \item{make.ordered}{The default behaviour has been to treat all GRASS categorical rasters as ordered factors. This can be modified by setting to FALSE, when the \code{"ordered"} class tag will be removed. The argument will be applied to all layers read during a single call to \code{read.get()}.}
 \item{debug}{if TRUE, the temporary ASCII file used for transfer is not deleted on exit from the function}
 \item{interp}{if TRUE, the interpreted version of the function is used instead of the loaded compiled version}
}
\value{
  A list is returned with \code{length(rlist)} vectors and \code{G$Ncells} values in each vector; the columns are named using the names of the imported GRASS raster files. If the names of the GRASS raster files are qualified by mapset, the name of the mapset will be appended after an underscore. Those imported with category labels are ordered factors, and their names are suffixed with \code{.f}
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand, R. S., (2000) Using the R statistical data analysis language on GRASS 5.0 GIS data base files. Computers and Geosciences, 26, pp. 1043-1052.}
\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\note{The functions in this package are intended to work with the GRASS geographical information system. The examples for wrapper functions will will work whether or not R is running in GRASS, and whether or not the current location is that of the data set used for the examples. Examples of interface functions will however (from version 0.2-2) only work outside GRASS, to avoid possible overwriting of GRASS database locations and/or files.}

\seealso{\code{\link{rast.put}}}

\examples{
if(!get("maas.loc", env = .GRASS.meta)) make.maas.location()
data(utm.maas)
Zn.o <- as.ordered(cut(utm.maas$Zn, labels=c("insignificant", "low",
"medium", "high", "crisis"), breaks=c(100, 200, 400, 700, 1000, 2000), 
include.lowest=TRUE))
G <- gmeta()
if(length(ls(pat="nameR"))==0){example(rast.put)}
exget <- rast.get(G, rlist=c("ex.tr3.in",
  "ex.Zn.s3.o.in"), catlabels=as.logical(c(FALSE, TRUE)))
plot(G, exget$ex.tr3.in)
points(utm.maas$east, utm.maas$north, pch=18)
title("Cubic trend surface")
table(exget$ex.Zn.s3.o.in)
}
\keyword{spatial}
\keyword{IO}
