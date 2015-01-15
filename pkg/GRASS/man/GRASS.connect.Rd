% Copyright 2003 by Roger S. Bivand
%
\name{GRASS.connect}
\alias{GRASS.connect}
\alias{get.LOCATION}
\alias{set.LOCATION}
\alias{get.MAPSET}
\alias{set.MAPSET}
\alias{get.GISDBASE}
\alias{set.GISDBASE}
\alias{get.cygwinstring}
\alias{set.cygwinstring}
\alias{get.GRASSChkGISRC}
\title{Access to underlying environment variables within GRASS}
\description{
Access functions to variables set within GRASS, should normally not be used directly.
}
\usage{
GRASS.connect(manual=FALSE, gisdbase=NULL, loc=NULL, mapset=NULL)
get.GISDBASE()
set.GISDBASE(gisdbase)
get.LOCATION()
set.LOCATION(loc)
get.MAPSET()
set.MAPSET(mapset)
get.cygwinstring()
set.cygwinstring(cygwin)
get.GRASSChkGISRC()
}
\arguments{
 \item{manual}{TRUE to set location parameters manually, FALSE by default}
 \item{gisdbase}{string: full path name to GISDBASE}
 \item{loc}{string: location name}
 \item{mapset}{string: mapset name}
 \item{cygwin}{string: CygWin prefix for prepending to GISRC and GISDBASE
values}
}
\value{
Most of the functions have side effects (apart from those getting values), but otherwise do not return much of use.

In addition, a number of internal GRASS environment variables are exposed for reading and manipulation - these are at present visible but should be used only with caution, and signal the future deprecation of the gmeta() mechanism for handling metadata.
}

%- maybe also `usage' for other objects documented here.
\details{
For users running GRASS under Cygwin with a standard single cygwin root, follow the instructions given as the library is loaded:

> library(GRASS)
If GRASS.connect() fails in this way and you are running under CygWin,
please set the CygWin root file system prefix using: set.cygwinstring()
and re-run GRASS.connect()

In such cases, the cygwin root is for example "c:/cygwin", so the cygwin GISRC variable "/home/rsb/.grassrc5" can be seen by R as "c:/cygwin/home/rsb/.grassrc5", and the GISDBASE field in that file, for example "/usr/local/grass5/data" as 
"c:/cygwin/usr/local/grass5/data".

Where the Cygwin setup is more complex, you will need to set the environment values manually:

Optionally:

> gisrcname <- Sys.getenv("GISRC")
> fix(gisrcname) \# to edit it manually to something readable
> scan(gisrcname, character(0)) \# to have an on-screen version of values

Then:

> GRASS.connect(manual=TRUE, gisdbase="the R readable full path name",
+ loc="LOCATION", mapset="MAPSET")

GRASS.connect() will attempt to insert these values and trap erroneous values.
}
\references{\url{http://grass.itc.it/statsgrass/index.html}, Bivand, R. S., (2000) Using the R statistical data analysis language on GRASS 5.0 GIS data base files. Computers and Geosciences, 26, pp. 1043-1052.}
\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\keyword{spatial}
\keyword{IO}
