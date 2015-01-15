% Copyright 1999-2000 by Roger S. Bivand
%
\name{pcbs}
\alias{pcbs}
\docType{data}
\title{PCBs in an area of South Wales}
\usage{data(pcbs)}
\description{
The \code{pcbs} data frame has 70 rows and 3 columns.
It records contamination of the environment with polychlorinated biphenyls around the site of a large plant for the incineration of chemical wastes near Pontypool, South Wales.
}
\format{
  This data frame contains the following columns:
  \describe{
    \item{east}{a numeric vector - UTM zone 30 eastings coordinates}
    \item{north}{a numeric vector - UTM zone 30 northings coordinates}
    \item{pcbs}{a numeric vector - standardised scores for seven types of PCB}
  }
}
\details{
 The original data were positioned in relation to National Grid coordinates, and have been reprojected to UTM zone 30, using the WGS84 ellipsoid.
}
\source{
 Bailey, T. C., Gatrell, A. C. 1995 Interactive Spatial Data Analysis (Longman, Harlow); pages 149-150, courtesy of Andrew Lovett, School of Environmental Sciences, University of East Anglia.
}
\note{This dataset will only work if R is started from inside GRASS, choosing the location for the Pontypool PCBs data. GRASS installations differ in permissions needed to establish a new location, and system administrator privileges may be needed to create the Pontypool location. Information about the necessary metadataare as follows. The actual data may be accessed from R: \code{data(pcbs)}.
  \describe{
    \item{projection }{UTM}
    \item{ellipsoid }{WGS84}
    \item{zone }{30}
    \item{north }{77200}
    \item{south }{74500}
    \item{west }{68000}
    \item{east }{70200}
    \item{nsres }{25}
    \item{ewres }{25}
    \item{rows }{108}
    \item{cols }{88}
  }
}

\examples{
data(pcbs)
pcbs.o <- as.ordered(cut(pcbs$pcbs, labels=c("insignificant", "low",
"medium", "high", "crisis"), breaks=c(1,20,100,500,1000,5000),
include.lowest=TRUE))
table(pcbs.o)
plot(pcbs$east, pcbs$north, pch=unclass(pcbs.o), xlab="", ylab="", asp=1)
legend(x=c(67980, 68480), y=c(74710, 75180), pch=c(1:5), legend=levels(pcbs.o))

}
\keyword{datasets}
