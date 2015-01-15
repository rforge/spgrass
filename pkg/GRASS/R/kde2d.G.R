# GRASS adaptation Copyright 1999-2000 by Roger S. Bivand

#
# kde2d and bandwidth.nrd copyright 1994-9 W.N.Venables & B.D.Ripley
#
kde2d.G <- function (G, x, y, h, reverse=NULL, Z=NULL) 
{
    bandwidth.nrd <- function (x) 
    {
        r <- quantile(x, c(0.25, 0.75))
        h <- (r[2] - r[1])/1.34
        4 * 1.06 * min(sqrt(var(x)), h) * length(x)^(-1/5)
    }
    nx <- length(x)
    if (length(y) != nx) 
        stop("Data vectors must be the same length")
    if (missing(h)) 
        h <- c(bandwidth.nrd(x), bandwidth.nrd(y))
    h <- h/4
    ax <- outer(G$xseq, x, "-")/h[1]
    ay <- outer(G$yseq, y, "-")/h[2]
    z <- matrix(dnorm(ax), G$Ncol, nx) %*%
            t(matrix(dnorm(ay), G$Nrow, nx))/(nx * h[1] * h[2])
    if (!is.null(Z)) {
        if (length(Z) != nx) 
            stop("Data vectors must be the same length")
        z1 <- matrix(dnorm(ax), G$Ncol, nx) %*% diag(Z) %*%
            t(matrix(dnorm(ay), G$Nrow, nx))/(nx * h[1] * h[2])
        z <- z1 / z
    }
    if (is.null(reverse)) reverse <- reverse(G)
    return(as.vector(z)[reverse])
}


