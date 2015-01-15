# Copyright 1999-2000 by Roger S. Bivand
#
interp.new.G <- function(G, x, y, z, extrap = FALSE,
		duplicate = "error", dupfun = NULL, reverse=NULL) {
    require(akima)
    temp <- interp.new(x, y, z, xo=G$xseq, yo=G$yseq, 
	extrap = extrap, duplicate = duplicate, dupfun = dupfun)
    if(is.null(reverse)) reverse <- reverse(G)
    return(as.vector(temp$z)[reverse])
}
