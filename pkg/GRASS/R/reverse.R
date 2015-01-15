# Copyright 2000 by Roger S. Bivand
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
# reverse() is an access function to return the reversed order of
# raster cells for use with image()
#
reverse <- function(G)
{
    if (class(G) != "grassmeta") stop("No GRASS metadata object")
    if(is.loaded("reverseG", PACKAGE="GRASS")) {
	reversed <- .Call("reverseG", G, PACKAGE="GRASS")
    } else {
	eastG <- east(G)
	northG <- north(G)
        reversed <- as.integer(order(northG, eastG))
    }
    invisible(reversed)
}




