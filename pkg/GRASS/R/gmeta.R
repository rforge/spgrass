# Copyright 1999-2003 by Roger S. Bivand
#
# gmeta is a function that returns GRASS LOCATION metadata in a
# grassmeta object.
#
# CHANGED 000329 from g.region -g to g.region -p to get numbers of
# rows and columns directly
# CHANGED 000614 to replace dataframe xy by list xy
#
# CHANGED 000628 to introduce support for compiled "gmeta"
#
# CHANGED 000706 to move east, north, obsno and reverse to access functions
#
# CHANGED 000714 to add interp argument
#
# CHANGED 030109 to cope with interpreted problems when location
# is lat/lon

gmeta <- function(interp=FALSE) {
    if (length(Sys.getenv("GISBASE")) == 0) {
	stop("No GRASS environment detected - start GRASS before entering R")
    }
    if(is.loaded("gmeta", PACKAGE="GRASS") && (interp == FALSE)) {
	G <- .Call("gmeta", PACKAGE="GRASS")
    } else {
	G <- vector(mode="list")
	G$LOCATION <- system("g.gisenv LOCATION_NAME", intern=TRUE)
	G$MAPSET <- system("g.gisenv MAPSET", intern=TRUE)
	META <- system("g.region -p", intern=TRUE)
	ML <- length(META)
	if (ML > 8) G$proj <- paste(META[1:(ML-8)], sep=" ", collapse="; ")
	if (length(grep("Latitude-Longitude", G$proj)) == 0) {
	    META.i <- function(META, i) {
		as.numeric(unlist(strsplit(META[ML-i], ":"))[2])
	    }
	    G$n <- META.i(META, 7)
	    G$s <- META.i(META, 6)
	    G$w <- META.i(META, 5)
	    G$e <- META.i(META, 4)
	    G$nsres <- META.i(META, 3)
	    G$ewres <- META.i(META, 2)
	} else {
	    dmstodd <- function(str) {
		res <- vector(mode="list")
		res$dms <- unlist(strsplit(str, ":"))
		res$n <- length(res$dms)
		res <- getNSWE(res)
		ndms <- as.numeric(res$dms)
		dd <- 0
		for (i in 1:res$n) dd <- dd + ndms[i]*(60^(-(i-1)))
		if (!is.na(res$res) && (res$res == "S" || res$res == "W"))
		    dd <- -dd
		dd
	    }
	    getNSWE <- function(dms) {
		dum <- as.character(NA)
		if(length(grep("[NSWE]", dms$dms[dms$n])) > 0) {
		    dum <- substr(dms$dms[dms$n], nchar(dms$dms[dms$n]),
			nchar(dms$dms[dms$n]))
		    dms$dms[dms$n] <- substr(dms$dms[dms$n], 1,
			nchar(dms$dms[dms$n])-1)
		}
		dms$res <- dum
		dms
	    }
	    tmp <- unlist(strsplit(META[ML-7], " "))
	    G$n <- dmstodd(tmp[length(tmp)])
	    tmp <- unlist(strsplit(META[ML-6], " "))
	    G$s <- dmstodd(tmp[length(tmp)])
	    tmp <- unlist(strsplit(META[ML-5], " "))
	    G$w <- dmstodd(tmp[length(tmp)])
	    tmp <- unlist(strsplit(META[ML-4], " "))
	    G$e <- dmstodd(tmp[length(tmp)])
	    if (G$e < G$w) G$e <- G$e + 360
	    tmp <- unlist(strsplit(META[ML-3], " "))
	    G$nsres <- dmstodd(tmp[length(tmp)])
	    tmp <- unlist(strsplit(META[ML-2], " "))
	    G$ewres <- dmstodd(tmp[length(tmp)])
	}
	G$Nrow <- as.numeric(unlist(strsplit(META[ML-1], ":"))[2])
	G$Ncol <- as.numeric(unlist(strsplit(META[ML], ":"))[2])
	G$Ncells <- G$Nrow * G$Ncol
	G$xlim <- c(G$w, G$e)
	G$ylim <- c(G$s, G$n)
	G$xseq <- seq(from=G$w + (G$ewres/2), to=G$e - (G$ewres/2), by=G$ewres)
	G$yseq <- seq(from=G$s + (G$nsres/2), to=G$n - (G$nsres/2), by=G$nsres)
	G$ryseq <- rev(G$yseq)
	class(G) <- "grassmeta"
    }
    invisible(G)
}

get.GRASSChkGISRC <- function() {
      get("ChkGISRC", env = .GRASS.meta)
}

GRASS.connect <- function(manual=FALSE, gisdbase=NULL, loc=NULL, mapset=NULL) {
      assign("ChkGISRC", FALSE, env = .GRASS.meta)
      if (manual) {
	      if (any(c(is.null(gisdbase), is.null(loc), is.null(mapset))))
                    stop("missing specification values")
	      z <- .Call("R_G__set_init", as.integer(1), PACKAGE="GRASS")
	      if (z != 1) stop("Init not set")
	      if (!file.exists(gisdbase)) stop(paste(gisdbase, "not found"))
              set.GISDBASE(gisdbase)
              set.LOCATION(loc)
              set.MAPSET(mapset)
              if (class(try(gmeta())) != "grassmeta")
		    stop("cannot retrieve window metadata from specificed location")
              assign("ChkGISRC", TRUE, env = .GRASS.meta)
              assign("gisrc", "faked", env = .GRASS.meta)
              cat("GRASS environment variables inserted manually\n")
            return()
      }
      if (Sys.getenv("GISRC") == "") return()
      gisrc <- .Call("R_G_get_gisrc_file", PACKAGE="GRASS")
      if (class(gisrc) == "gisrc") {  
              assign("ChkGISRC", TRUE, env = .GRASS.meta)
              assign("gisrc", gisrc, env = .GRASS.meta)
              cat("GRASS environment variables in:", gisrc, "\n")
      } else {
              cat("No GRASS environment found\n")
              assign("ChkGISRC", FALSE, env = .GRASS.meta)
              cat(paste("If GRASS.connect() fails in this way",
              "and you are running under CygWin,\nplease set the",
              "CygWin root file system prefix using:",
              "set.cygwinstring()", "\nand re-run GRASS.connect()\n"))
      }
}

make.maas.location <- function() {
	if (get.GRASSChkGISRC())
		stop ("Please run examples and checks outside GRASS")
	data(utm.maas)
	assign("maas.loc", FALSE, env = .GRASS.meta)
	rootdir <- tempdir()
	z <- .Call("R_G__set_init", as.integer(1), PACKAGE="GRASS")
	if (z != 1) stop("Init not set")
	set.GISDBASE(rootdir)
	set.LOCATION("maas")
	set.MAPSET("RGRASS")
	z <- .Call("R_G_make_maas", maas.metadata, PACKAGE="GRASS")
	if (z != 0) stop("error creating location")
	if (class(try(gmeta())) == "grassmeta")
		assign("maas.loc", TRUE, env = .GRASS.meta)
	z <- get("maas.loc", env = .GRASS.meta)
	z
}

set.cygwinstring <- function(cygwin) {
      if (!is.character(cygwin)) stop("Character string required")
      newcygwin <- .Call("R_G_set_cygwinstring", as.character(cygwin)[1],
	PACKAGE="GRASS")
      newcygwin
}

get.cygwinstring <- function() {
      cygwin <- .Call("R_G_get_cygwinstring", PACKAGE="GRASS")
      cygwin
}


set.LOCATION <- function(loc) {
      if (!is.character(loc)) stop("Character string required")
      newloc <- .Call("R_G_set_locstring", as.character(loc)[1], 
	PACKAGE="GRASS")
      newloc
}

get.LOCATION <- function() {
      loc <- .Call("R_G_get_location", PACKAGE="GRASS")
      loc
}


set.GISDBASE <- function(gisdbase) {
      if (!is.character(gisdbase)) stop("Character string required")
      newgisdbase <- .Call("R_G_set_gisdbasestring", as.character(gisdbase)[1],
	PACKAGE="GRASS")
      newgisdbase
}

get.GISDBASE <- function() {
      gisdbase <- .Call("R_G_get_gisdbase", PACKAGE="GRASS")
      gisdbase
}

set.MAPSET <- function(mapset) {
      if (!is.character(mapset)) stop("Character string required")
      newmapset <- .Call("R_G_set_mapset", as.character(mapset)[1], 
	PACKAGE="GRASS")
      newmapset
}

get.MAPSET <- function() {
      mapset <- .Call("R_G_get_mapset", PACKAGE="GRASS")
      mapset
}

