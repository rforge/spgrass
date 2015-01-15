# Copyright 2001-4 by Roger S. Bivand
#
# east() is an access function to return the eastings coordinates
# of raster cell centres from a grassmeta object
#

east <- function(object) UseMethod("east")

east.default <- function(object) stop("no default method for east")

east.grassmeta <- function(object)
{
    if (class(object) != "grassmeta") stop("No GRASS metadata object")
    if(is.loaded("eastG", PACKAGE="GRASS")) {
	east <- .Call("eastG", object, PACKAGE="GRASS")
    } else {
        east <- as.numeric(c(matrix(object$xseq, length(object$xseq), 
	    length(object$ryseq))))
    }
    invisible(east)
}


