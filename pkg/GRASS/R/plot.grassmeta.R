# Copyright 1999-2004 by Roger S. Bivand
#
#
# plot.grassmeta provides a simple interface between grass data
# objects and the image() function; category layers may be plotted
# by taking unclass() of the layer, and setting zlim to non-default values.
# If layer is not set, a blank base map is plotted, for instance for use
# with points().
#
plot.grassmeta <- function(x, layer=NULL, xlab="", ylab="",
    reverse=NULL, add=FALSE, breaks=NULL, ...) {
    G <- x
    if (class(G) != "grassmeta") stop("Data not a grass object")
    if (!add) {
        plot(G$xlim, G$ylim, xlim=G$xlim, ylim=G$ylim, asp=1, xlab = xlab,
            ylab = ylab, type = "n")
    }
    if (!is.null(layer)) {
	if (length(layer) != G$Ncells) {
	    if ((length(layer) == 1) && (class(layer) == "list")) {
		stop(paste(deparse(substitute(layer)), 
		    "is a list of length 1 with member", names(layer), 
		    "- try:", paste(deparse(substitute(layer)), "$", 
		    names(layer), sep="")))
	    } else if (class(layer) == "list") {
		stop(paste(deparse(substitute(layer)), "is a list object"))
	    } else stop("GRASS object metadata do not match layer length")
	}
	if (!is.null(breaks)) {
	    if (any(is.na(breaks) | is.nan(breaks))) 
		stop ("NAs found in breaks")
	    if (is.unsorted(breaks)) 
	        stop("`breaks' must be sorted non-decreasingly")
	    if (breaks[1] == -Inf) breaks[1] <- -(.Machine$double.xmax)
	    if (breaks[length(breaks)] == Inf) 
		breaks[length(breaks)] <- .Machine$double.xmax
	}
        if (is.null(reverse)) reverse <- reverse(G)
	if (is.null(breaks)) {
	    image(x=G$xseq, y=G$yseq, z=t(matrix(layer[reverse],
            	nrow=G$Nrow, ncol=G$Ncol, byrow=TRUE)), add=TRUE, 
		...)
	} else {
	    image(x=G$xseq, y=G$yseq, z=t(matrix(layer[reverse],
            	nrow=G$Nrow, ncol=G$Ncol, byrow=TRUE)), add=TRUE, 
		breaks=breaks, ...)
	}
    }
}

legtext <- function(break.levels)
{
    x <- break.levels
    n <- length(x)
    cx <- as.character(x)
    legend <- character(length=(n-1))
    for (i in 1:length(legend)) legend[i] <- paste(x[i], "-", x[i+1], sep="")
    legend
}

leglabs <- function(x1, under="under", over="over", between="-") {
	x <- x1
	res <- character(length(x)-1)
	res[1] <- paste(under, x[2])
	for (i in 2:(length(x)-2)) res[i] <- paste(x[i], between, x[i+1])
	res[length(x)-1] <- paste(over, x[length(x)-1])
	res
}

#findInterval2 <- function (x2, vec, rightmost.closed = FALSE,
# all.inside = TRUE) {
#    x <- x2
#    nx <- length(x)
#    if (any(is.na(vec) | is.nan(vec))) stop ("NAs found in vec")
#    if (is.unsorted(vec)) 
#        stop("`vec' must be sorted non-decreasingly")
#    if (vec[1] == -Inf) vec[1] <- -(.Machine$double.xmax)
#    if (vec[length(vec)] == Inf) 
#	vec[length(vec)] <- .Machine$double.xmax
#    .C("find_interv_vec", xt = as.double(vec), n = length(vec), 
#        x = as.double(x), nx = nx, as.logical(rightmost.closed), 
#        as.logical(all.inside), index = integer(nx), DUP = FALSE,
#	PACKAGE = "base")$index
#}

