# Copyright 2000-3 by Roger S. Bivand. 
#

.GRASS.meta <- new.env(FALSE, globalenv())
assign("ChkGISRC", FALSE, env = .GRASS.meta)
assign("maas.loc", FALSE, env = .GRASS.meta)

.First.lib <- function(lib, pkg) {
	library.dynam("GRASS", pkg, lib)
	.Call("R_G_init", "RGRASS_INTERFACE", PACKAGE="GRASS")
	GRASS.connect()
}

