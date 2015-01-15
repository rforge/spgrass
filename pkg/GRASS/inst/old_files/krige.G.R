# Copyright 2001 by Roger S. Bivand
#

krige.G <- function(point.obj, at, var.mod.obj, G, mask=NULL) 
{
    require(sgeostat)
    require(spatial)
    if (!inherits(point.obj, "point")) 
        stop("point.obj must be of class, \"point\".\n")
    if (!inherits(var.mod.obj, "variogram.model")) 
        stop("var.mod.obj must be of class, \"variogram.model\".\n")
    if (class(G) != "grassmeta") 
        stop("G not a grass object")
    at.val <- point.obj[[match(at, names(point.obj))]]
    nugget <- var.mod.obj$parameters[1]
    sill <- var.mod.obj$parameters[2]
    range <- var.mod.obj$parameters[3]
    names(nugget) <- NULL
    names(range) <- NULL
    names(sill) <- NULL
    se <- sqrt(nugget + sill)
    alpha <- nugget / (nugget + sill)
    d <- range
    model <- attr(var.mod.obj, "type")
    kr.model <- NULL
    if (model == "exponential")
        kr.model <- surf.gls(0, expcov, x=point.obj$x, y=point.obj$y,
            z=at.val, d=d, alpha=alpha, se=se)
    else if (model == "gaussian")
        kr.model <- surf.gls(0, gaucov, x=point.obj$x, y=point.obj$y,
            z=at.val, d=d, alpha=alpha, se=se)
    else if (model == "spherical")
        kr.model <- surf.gls(0, sphercov, x=point.obj$x, y=point.obj$y,
            z=at.val, d=d, alpha=alpha, se=se, D=2)
    else stop("unsupported variogram model")
    if (!is.null(mask)) {
        if (length(mask) != G$Ncells)
            stop ("mask length does not equal grid size")
        s <- cbind(east(G)[!is.na(mask)], 
	    north(G)[!is.na(mask)])
    }
    else s <- cbind(east(G), north(G))
    zhat <- prmat2.G(kr.model, s)
    sehat <- semat2.G(kr.model, s)
    if (!is.null(mask)) {
        res1 <- as.numeric(rep(NA,length(mask)))
        res1[!is.na(mask)] <- zhat
        res2 <- as.numeric(rep(NA,length(mask)))
        res2[!is.na(mask)] <- sehat
        return(list(kr=kr.model, zhat=res1, sehat=res2))
    }
    return(list(kr=kr.model, zhat=zhat, sehat=sehat))
}
prmat2.G <- function (obj, s) 
{
    predval <- function(obj, xp, yp) {
        npt <- length(xp)
        .C("VR_krpred", z = double(npt), as.double(xp), as.double(yp), 
            as.double(obj$x), as.double(obj$y), as.integer(npt), 
            as.integer(length(obj$x)), as.double(obj$yy), PACKAGE="spatial")$z
    }
    require(spatial)
    if (!inherits(obj, "trgls")) 
        stop("object not from kriging")
    .C("VR_frset", as.double(obj$rx[1]), as.double(obj$rx[2]), 
        as.double(obj$ry[1]), as.double(obj$ry[2]), PACKAGE="spatial")
    alph <- obj$alph
    if (length(alph) <= 1) {
        mm <- 1.5 * sqrt((obj$rx[2] - obj$rx[1])^2 + (obj$ry[2] - 
            obj$ry[1])^2)
        alph <- c(alph[1], obj$covmod(seq(0, mm, alph[1])))
    }
    .C("VR_alset", as.double(alph), as.integer(length(alph)), PACKAGE="spatial")
    z <-  predict.trls(obj, s[,1], s[,2]) + predval(obj, s[,1], s[,2])
    invisible(z)
}
semat2.G <- function (obj, s, se) 
{
    seval <- function(obj, xp, yp) {
        npt <- length(xp)
        np <- obj$np
        npar <- ((np + 1) * (np + 2))/2
        .C("VR_prvar", z = double(npt), as.double(xp), as.double(yp), 
            as.integer(npt), as.double(obj$x), as.double(obj$y), 
            as.double(obj$l), as.double(obj$r), as.integer(length(obj$x)), 
            as.integer(np), as.integer(npar), as.double(obj$l1f), 
	    PACKAGE="spatial")$z
    }
    require(spatial)
    if (!inherits(obj, "trgls")) 
        stop("object not from kriging")
    .C("VR_frset", as.double(obj$rx[1]), as.double(obj$rx[2]), 
        as.double(obj$ry[1]), as.double(obj$ry[2]), PACKAGE="spatial")
    alph <- obj$alph
    if (length(alph) <= 1) {
        mm <- 1.5 * sqrt((obj$rx[2] - obj$rx[1])^2 + (obj$ry[2] - 
            obj$ry[1])^2)
        alph <- c(alph[1], obj$covmod(seq(0, mm, alph[1])))
    }
    .C("VR_alset", as.double(alph), as.integer(length(alph)), PACKAGE="spatial")
    np <- obj$np
    npar <- ((np + 1) * (np + 2))/2
    if (missing(se)) 
        se <- sqrt(sum(obj$W^2)/(length(obj$x) - npar))
    z <- se * sqrt(seval(obj, s[,1], s[,2]))
    invisible(z)
}
