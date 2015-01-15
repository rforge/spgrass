# Copyright 2001 by Roger S. Bivand
#
# contour.G is a wrapper 
contourG <- function (x, layer = NULL, xlab = "", ylab = "",
    reverse = NULL, add = FALSE, ...) 
{
    G <- x
    if (class(G) != "grassmeta") 
        stop("Data not a grass object")
    if (!add) {
        plot(G$xlim, G$ylim, xlim = G$xlim, ylim = G$ylim, asp = 1, 
            xlab = xlab, ylab = ylab, type = "n")
    }
    if (!is.null(layer)) {
        if (length(layer) != G$Ncells) 
            stop("GRASS object metadata do not match layer length")
        if (is.null(reverse)) 
            reverse <- reverse(G)
        contour(x = G$xseq, y = G$yseq, z = t(matrix(layer[reverse], 
            nrow = G$Nrow, ncol = G$Ncol, byrow = TRUE)), add = TRUE, 
            ...)
    }
}

