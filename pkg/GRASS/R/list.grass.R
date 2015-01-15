# Copyright 2003 by Roger S. Bivand
#
list.grass <- function(type="cell") {
	types <- c("cell", "site_lists", "dig_plus")
	if (!(type %in% types)) stop(paste(type, "unknown value"))
	mpsts <- get.mapsets()
	res <- vector(mode="list", length=length(mpsts))
	names(res) <- mpsts
	for (i in 1:length(mpsts))
		if (file.exists(paste(get.GISDBASE(), get.LOCATION(), 
			mpsts[i], type, sep="/"))) 
			res[[i]] <- list.files(paste(get.GISDBASE(), 
				get.LOCATION(), mpsts[i], type, sep="/"))
	class(res) <- "glist"
	attr(res, "type") <- type
	res
}

print.glist <- function(x, ...) {
	mpsts <- names(x)
	if (any(!sapply(x, is.null))) {
		cat("----------------------------------------------\n")
		for (i in 1:length(mpsts))
			if (!is.null(x[[i]])) {
				cat(attr(x, "type"), 
					" files avalable in mapset ",
					mpsts[i], ":\n", sep="")
				print(x[[i]], quote=FALSE)
				cat("\n")
			}
		cat("----------------------------------------------\n")
	}
	invisible(x)
}

