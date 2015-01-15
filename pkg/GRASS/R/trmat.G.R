# GRASS adaptation Copyright 1999-2001 by Roger S. Bivand
#

trmat.G <- function (G, obj, east=NULL, north=NULL) 
{
    require(spatial)
    if (!inherits(obj, "trls")) 
        stop("object not a fitted trend surface")
    if (class(G) != "grassmeta") 
        stop("Data not a grass object")
    if (is.null(east)) east <- east(G)
    if (is.null(north)) north <- north(G)
    z <- predict(obj, east, north) 
    invisible(z)
}


