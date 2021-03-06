 \name{spgrass6-package}
\alias{spgrass6-package}
\alias{spgrass6}
\docType{package}
\title{
Interface between GRASS geographical information system and R
}
\description{
Interpreted interface between GRASS geographical
information system, versions 6 and 7, and R, based on starting R from within the
GRASS environment, or on running R stand-alone and creating a throw-away GRASS environment from within R. The interface uses classes defined in the sp package
to hold spatial data.
}

\details{
Index:
\preformatted{
readRAST                read GRASS raster files
writeRAST               write GRASS raster files
readVECT                read GRASS vector object files
writeVECT               write GRASS vector object files
gmeta                   read GRASS metadata from the current LOCATION
getLocationProj         return a PROJ.4 string of projection information
gmeta2grd               create a GridTopology object from the GRASS region
vInfo                   return vector geometry information
vColumns                return vector database columns information
vDataCount              return count of vector database rows
vect2neigh              return area neighbours with shared boundary length
}
Further information may be found in the document \code{doc/spgrass_0.3.pdf} in the directory returned by \code{system.file("", package="spgrass6")}.
}
\author{
Roger Bivand

Maintainer: Roger Bivand <Roger.Bivand@nhh.no>

}

\keyword{ package }
\keyword{ spatial }


\examples{
if (nchar(Sys.getenv("GISRC")) > 0) {
  require(rgdal)
  soilsph <- readRAST("soils.ph", ignore.stderr=TRUE, plugin=FALSE)
  summary(soilsph)
  grd <- gmeta2grd(ignore.stderr=TRUE)
  grd
  set.seed(1)
  pts <- spsample(soilsph, 200, "random")
  smple <- SpatialPointsDataFrame(pts, data=over(pts, soilsph))
  summary(smple)
  writeVECT(smple, "sp_dem", v.in.ogr_flags="overwrite", ignore.stderr=TRUE)
  bugsDF <- readVECT("bugsites", ignore.stderr=TRUE, mapset="PERMANENT")
  summary(bugsDF)
  vInfo("streams", ignore.stderr=TRUE)
  vColumns("streams", ignore.stderr=TRUE)
  vDataCount("streams", ignore.stderr=TRUE)
  streams <- readVECT("streams", type="line,boundary",
    remove.duplicates=FALSE, ignore.stderr=TRUE, plugin=FALSE)
  summary(streams)
}
}
