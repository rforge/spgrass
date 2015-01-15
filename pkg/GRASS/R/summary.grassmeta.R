# Copyright 1999-2000 by Roger S. Bivand
#
# summary.grassmeta displays the metadata prepared when map layers are moved to R.
#
# CHANGED 000329 RSB added projection output
summary.grassmeta <- function(object, ...) {
	G <- object
	if (class(G) != "grassmeta") stop("Data not a grass object")
	cat("Data from GRASS 5.0 LOCATION ", G$LOCATION, " with ", G$Ncol,
	" columns and ", G$Nrow, " rows;\n", G$proj, "\nThe west-east range is: ",
	G$w, ", ", G$e, ",\nand the south-north: ",
	G$s, ", ", G$n,
	";\nWest-east cell sizes are ", G$ewres,
	" units,\nand south-north ", G$nsres,
	" units.\n", sep="")
}
