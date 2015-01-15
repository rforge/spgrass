# Copyright 1999-2003 by Roger S. Bivand
#
# sites.get moves one GRASS 5.0 sites file to a data frame, returning
# the filled object. 
#
sites.get <- function(G, slist = "", all.sites=FALSE, collapse.labels=TRUE, 
	debug=FALSE, interp=FALSE) {
	if (class(G) != "grassmeta") stop("No GRASS metadata object")
	if (! is.character(slist))
		stop("character GRASS data base file name required")
	if (!is.loaded("sitesget", PACKAGE="GRASS")) interp <- TRUE
	if (interp) {

		G.list <- unlist(list.grass(type="site_lists"))
		res <- slist %in% G.list
		if (! all(res)) stop(paste("transfer terminated: ",
			slist[res == FALSE], "GRASS data base file not found"))
		if (all.sites) allsites <- " -a"
		else allsites <- ""
		FILE <- tempfile("GRtoR")
		system(paste("s.out.ascii -d", allsites, " sites=", slist,
			" > ", FILE, sep=""))
		data <- read.table(FILE, na.strings="*")
# CHANGE 000329 RSB Only expect eastings and northings, not id as before
		nc2 <- ncol(data) - 2
		nlist <- character(0)
		for (i in 1:nc2) nlist <- c(nlist, paste("var", i, sep=""))
		names(data) <- c("east", "north", nlist)
		if (!debug) unlink(FILE)
	} else {
		res <- .Call("sitesget", G, slist, all.sites, PACKAGE="GRASS")
		nncols <- attr(res, "nncols")
		if (length(res) == 1) {
			data <- as.data.frame(res)
			names(data) <- c("east", "north")
		} else {
			data <- as.data.frame(res[[1]])
			nlist <- c("east", "north")
			if (length(res[[1]]) > 2) {
				for (i in 3:length(res[[1]])) nlist <- c(nlist, 
					paste("dim", i, sep=""))
			}
			data <- cbind(data, as.data.frame(res[[2]]))
			nlist <- c(nlist, "id")
			if (nncols[3] > 0) {
				data <- cbind(data, as.data.frame(res[[3]]))
				for (i in 1:length(res[[3]])) nlist <- c(nlist, 
					paste("num", i, sep=""))
			}
			if (nncols[4] > 0) {
# changes 2003/3/28 to accept old-style labels
				if (nncols[2] < 0 &&
				    collapse.labels) {
				    oldatt <- res[[4]][[1]]
				    for (i in 2:length(res[[4]]))
					oldatt <- paste(oldatt, res[[4]][[i]])
				    data <- cbind(data, as.data.frame(oldatt))
				    nlist <- c(nlist, paste("str1", sep=""))
				} else {
				    data <- cbind(data, as.data.frame(res[[4]]))
				    for (i in 1:length(res[[4]])) nlist <- 
					c(nlist, paste("str", i, sep=""))
				}
			}
			if (!is.null(attr(res, "labels"))) {
				labs <- unlist(strsplit(attr(res, 
					"labels"), " "))
				if (length(labs) == ncol(data)) {
					colnames(data) <- make.names(labs)
				} else {
					colnames(data) <- make.names(nlist)
				}
			} else {
				colnames(data) <- make.names(nlist)
			}
		}
	}
	attr(data, "nncols") <- nncols
	invisible(data)
}
