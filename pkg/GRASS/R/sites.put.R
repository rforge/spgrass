# Copyright 1999-2003 by Roger S. Bivand
#
# sites.put moves a single variable site to GRASS, using the metadata
# prepared when layers were got from the GRASS data base.
#
sites.put <- function(G, lname="", east, north, var, 
	debug=FALSE) {
	warning("This function may be withdrawn, consider using sites.put2()")
	if (class(G) != "grassmeta") stop("Data not a grass object")
	if (length(lname) != 1)
		stop("Single new GRASS data base file name required")

	G.list <- list.grass(type="site_lists")
	res <- lname %in% G.list[[match(get.MAPSET(), get.mapsets())]]
	if (any(res))
		stop(paste(lname, ": GRASS sites file already exists ", 
		"in mapset: ", get.MAPSET(), sep=""))
	if (length(east) != length(north))
		stop("Different numbers of eastings and northings")
	if (length(east) != length(var))
		stop("Different numbers of coordinates and observations")
	inregion <- (east >= G$w & east <= G$e) & (north >= G$s & north <= G$n)
	if(all(!inregion)) stop("None of the site locations are inside the current GRASS region")
	if(any(!inregion)) warning("Some site locations are outside the current GRASS region")
	FILE <- tempfile("RtoGR")
	if (is.numeric(var))
		a <- data.frame(x=east, y=north, z=as.character(paste("%", var, sep="")))
	else
		a <- data.frame(x=east, y=north, z=as.character(paste("@", var, sep="")))
	write.table(a, row.names=FALSE, col.names=FALSE, quote=FALSE, file=FILE)
	system(paste("s.in.ascii input=", FILE, " sites=", lname, sep=""))
	if (!debug) unlink(FILE)
}

sites.put2 <- function(G, data, id=NULL, dims, lname="", all.sites=FALSE,
	check=TRUE) {
	if (class(G) != "grassmeta") stop("Data not a grass object")
	if (class(data) != "data.frame") stop("Data frame required")
	nas <- unlist(lapply(data, function(x) any(is.na(x))))
	if (any(nas)) stop("NAs cannot be moved to GRASS sites files")
	if (!is.loaded("sitesput", PACKAGE="GRASS")) stop(paste("sitesput",
		"compiled function not loaded, use old sitesput() function"))	

	if(!is.logical(check)) stop("check must be logical")
	n <- nrow(data)
	if (is.null(id)) {
		ids <- as.integer(1:n)
		idname <- "id"
		xid <- NULL
	} else {
		if (length(id) > 1) stop ("single id required")
		if (is.character(id)) {
			xid <- match(id, colnames(data))
			if (is.na(xid))
				stop ("id not found")
			ids <- data[,xid]
			idname <- id
		} else {
			if (is.integer(id) && id > 0 && id <= ncol(data)) {
				ids <- data[,id]
				idname <- colnames(data)[id]
				xid <- id
			} else {
				stop ("id not valid number")
			}
		}
	}
	if(!is.numeric(ids)) stop ("id not numeric")
	if(is.integer(ids)) cattype <- 0
	else cattype <- 2

	ndims <- length(dims)
	if (ndims < 2) stop("less than two dimensions")
	if (is.character(dims)) {
		xdims <- match(dims, names(data))
		if (any(is.na(xdims)))
			stop ("dims not found")
		dims.mat <- as.matrix(data[, dims])
		dimsnames <- dims
	} else if (is.integer(dims)) {
		if (any(dims < 1) || any (dims > ncol(data))) 
			stop ("dims not valid")
		dims.mat <- as.matrix(data[, dims])
		dimsnames <- names(data)[dims]
		xdims <- dims
	} else stop ("dims not valid")
	if (!is.numeric(dims.mat)) stop ("dims not numeric")
	if (is.integer(dims.mat)) dims.mat <- as.numeric(dims.mat)

	if (length(lname) != 1)
		stop("Single new GRASS data base file name required")
	if (!is.logical(all.sites)) stop("all.sites not logical")
	if (!is.logical(check)) stop("check not logical")

	if (is.null(xid)) drops <- xdims
	else drops <- c(xid, xdims)
	dnames <- colnames(data)
	data.attr <- as.data.frame(data[, -drops])
	da.ncol <- ncol(data.attr)
	dblnames <- NULL
	dbl.mat <- NULL
	strnames <- NULL
	str.mat <- NULL
	if (da.ncol == 0) {
		xnumeric <- NULL
		xother <- NULL
		ndbls <- 0
		nstrs <- 0
		dblnames <- NULL
		strnames <- NULL
		warning("No attributes transferred, only dimensions")
	} else {
		dnames <- dnames[-drops]

		xnumeric <- which(unlist(lapply(data.attr, is.numeric)))
		xother <- which(unlist(lapply(data.attr,
			function(x) !is.numeric(x))))
		ndbls <- length(xnumeric)
		
		if (length(xnumeric) > 0) {
			if (da.ncol == 1) {
				dbl.mat <- matrix(data.attr[,1], ncol=1, nrow=n)
			} else {
				dbl.mat <- as.matrix(data.attr[, xnumeric])
			}
			dblnames <- dnames[xnumeric]
			if (is.integer(dbl.mat)) dbl.mat <- as.numeric(dbl.mat)
		}

		nstrs <- length(xother)
	
		if (nstrs > 0) {
			if (da.ncol == 1) {
				str.mat <- matrix(as.character(data.attr[,1]), 
					ncol=1, nrow=n)
			} else {
				str.mat <- as.matrix(data.attr[, xother])
			}
			strnames <- dnames[xother]
		}
	}

	labs <- paste(c(dimsnames, idname, dblnames, strnames), collapse=" ")
	n.args <- as.integer(c(cattype, n, ndims, ndbls, nstrs))
	call <- deparse(match.call(), width=500)

	res <- list(G=G, lname=lname, n.args=n.args, all.sites=all.sites, 
		labs=labs, ids=ids, dims.mat=dims.mat, dbl.mat=dbl.mat, 
		str.mat=str.mat, call=call, check=check)
	xx <- .Call("sitesput", res, PACKAGE="GRASS")

	invisible(xx)
}
