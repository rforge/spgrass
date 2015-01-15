# Copyright 2003 by Roger S. Bivand

get.mapsets <- function() {
	res <- .Call("R_G_get_mapsets", PACKAGE="GRASS")
	res
}

refresh.mapsets <- function() {
	res <- .Call("R_G_refresh_mapsets", PACKAGE="GRASS")
	res
}

