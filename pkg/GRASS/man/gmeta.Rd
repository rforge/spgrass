% Copyright 1999-2004 by Roger S. Bivand
%
\name{gmeta}
\alias{gmeta}
\alias{east}
\alias{north}
\alias{east.default}
\alias{north.default}
\alias{east.grassmeta}
\alias{north.grassmeta}
\alias{obsno}
\alias{reverse}
\alias{make.maas.location}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Reads GRASS metadata from the current LOCATION}
\description{
GRASS LOCATION metadata are read into a list in R, and processed to provide other functions with parameters and structures they require.
}
\usage{
gmeta(interp=FALSE)
east(object)
north(object)
\method{east}{default}(object)
\method{north}{default}(object)
\method{east}{grassmeta}(object)
\method{north}{grassmeta}(object)
obsno(G)
reverse(G)
make.maas.location()

}
\arguments{
 \item{interp}{if interp is TRUE, the interface uses text transfer through \code{system()}}
 \item{G}{a grassmeta object returned by \code{gmeta}}
 \item{object}{a grassmeta object returned by \code{gmeta}}
}
%- maybe also `usage' for other objects documented here.
\details{
The function retrieves metadata from the GRASS LOCATION from which R was started, and stores it in a list. The metadata is taken from the current, active region, and the implied resolution for raster layers. Next, this is used to create a number of auxilliary objects used by other interface routines. Other auxilliary objects may be constructed using the access functions \code{east.grassmeta}, \code{north.grassmeta}, \code{obsno}, and \code{reverse}. The function returns a list with class \code{grassmeta}:
}
\value{
  \item{LOCATION}{GRASS LOCATION name}
  \item{MAPSET}{GRASS MAPSET within the LOCATION}
  \item{proj}{GRASS projection description}
  \item{n}{Northern edge: numeric}
  \item{s}{Southern edge: numeric}
  \item{w}{Western edge: numeric}
  \item{e}{Eastern edge: numeric}
  \item{nsres}{North-South resolution in measurement units, typically metres or decimal degrees}
  \item{ewres}{East-West resolution in measurement units, typically metres or decimal degrees}
  \item{Nrow}{Number of rows of raster cells}
  \item{Ncol}{Number of columns of raster cells}
  \item{Ncells}{Number of raster cells}
  \item{xlim}{East-West range}
  \item{ylim}{North-South range}
  \item{xseq}{Sequence of raster cell East-West midpoint coordinates}
  \item{yseq}{Sequence of raster cell North-Soutb midpoint coordinates}
  \item{ryseq}{Reversed sequence of raster cell North-Soutb midpoint coordinates}

In addition, a number of internal GRASS environment variables are exposed for reading and manipulation - these are at present visible but should be used only with caution, and signal the future deprecation of the gmeta() mechanism for handling metadata.
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand, R. S., (2000) Using the R statistical data analysis language on GRASS 5.0 GIS data base files. Computers and Geosciences, 26, pp. 1043-1052.}
\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\note{The functions in this package are intended to work with the GRASS geographical information system. The examples for wrapper functions will will work whether or not R is running in GRASS, and whether or not the current location is that of the data set used for the examples. Examples of interface functions will however (from version 0.2-2) only work outside GRASS, to avoid possible overwriting of GRASS database locations and/or files.}

\seealso{\code{\link{summary.grassmeta}}}

\examples{
if(!get("maas.loc", env = .GRASS.meta)) make.maas.location()
G <- gmeta()
summary(G)
}
\keyword{spatial}
\keyword{IO}
