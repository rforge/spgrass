# Copyright 2000 by Roger S. Bivand
#
# north() is an access function to return the northings coordinates
# of raster cell centres from a grassmeta object
#
north <- function(object) UseMethod("north")

north.default <- function(object) stop("no default method for north")

north.grassmeta <- function(object)
{
    if (class(object) != "grassmeta") stop("No GRASS metadata object")
    if(is.loaded("northG", PACKAGE="GRASS")) {
	north <- .Call("northG", object, PACKAGE="GRASS")
    } else {
        north <- as.numeric(c(matrix(object$ryseq, length(object$xseq),
	    length(object$ryseq), byrow=TRUE)))
    }
    invisible(north)
}

