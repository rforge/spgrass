/* Copyright 2000-3 by Roger S. Bivand. 
*
**/
#include <sys/stat.h>
#include <sys/types.h>

#include "grassR.h"
#if defined __MINGW32_VERSION
static char *cygwinstring = NULL;
#endif /* __MINGW32_VERSION */

void R_G_init(char *name) {

/*	G_set_error_routine(R_handler);
	G_sleep_on_error(0); */
       if (G_set_program_name(name) != 0)
	      G_fatal_error("R_G_init: error setting name");
	G_no_gisinit();
}

#  if defined __MINGW32_VERSION
char *G_get_cygwinstring() {
	return(cygwinstring);
}

SEXP R_G_get_cygwinstring() {
      SEXP ans;
      PROTECT(ans=NEW_CHARACTER(1));
      SET_STRING_ELT(ans, 0,
              COPY_TO_USER_STRING(G_get_cygwinstring()));
      UNPROTECT(1);
      return(ans);
}

int G_set_cygwinstring( char *name) {
    cygwinstring = NULL;
    if (name && *name)
      cygwinstring = G_store(name);

    return 0;
}

SEXP R_G_set_cygwinstring(SEXP cygname) {
      char *name;

      char buff[255];

/*      name = G_store(CHAR(STRING_ELT(cygname, 0)));  ?? */
      strcpy(buff, CHAR(STRING_ELT(cygname, 0)));
      name = G_store(buff);
      
      if (G_set_cygwinstring(name) != 0)
              G_fatal_error("R_set_cygwinstring: cygwinstring not set");

      return(R_G_get_cygwinstring());
}

#endif /* __MINGW32_VERSION */

SEXP R_G_get_gisrc_file() {
      SEXP ans, class;
      char *gisrc;
      
      PROTECT(ans=NEW_CHARACTER(1));
      PROTECT(class=NEW_CHARACTER(1));
      gisrc = G__get_gisrc_file();
      if (gisrc) {
	   gisrc = G_store(gisrc);
           SET_STRING_ELT(ans, 0,
                COPY_TO_USER_STRING(gisrc));
           SET_STRING_ELT(class, 0, COPY_TO_USER_STRING("gisrc"));
      } else {
           SET_STRING_ELT(ans, 0,
                COPY_TO_USER_STRING("empty"));
           SET_STRING_ELT(class, 0, COPY_TO_USER_STRING("empty"));
       }
      setAttrib(ans, R_ClassSymbol, class);
      UNPROTECT(2);
      return(ans);
}

SEXP R_G_set_gisrc_file(SEXP newgisrc) {
      char *name;
      char buff[255];

/*      name = G_store(CHAR(STRING_ELT(newgisrc, 0)));  ?? */
      strcpy(buff, CHAR(STRING_ELT(newgisrc, 0)));
      name = G_store(buff);
      if (G__set_gisrc_file(name) != 0)
              G_fatal_error("R_set_gisrc_file: gisrc not set");

      return(R_G_get_gisrc_file());
}

void R_G_set_pgm(SEXP pgm) {
      char *name;
      char buff[255];

/*      name = G_store(CHAR(STRING_ELT(pgm, 0)));  ?? */
      strcpy(buff, CHAR(STRING_ELT(pgm, 0)));
      name = G_store(buff);

      if (G_set_program_name(name) != 0)
	      G_fatal_error("R_G_set_pgm: error setting name");
      return;
}

SEXP R_G_get_location() {
      SEXP ans;
      PROTECT(ans=NEW_CHARACTER(1));
      SET_STRING_ELT(ans, 0,
              COPY_TO_USER_STRING(G_getenv("LOCATION_NAME")));
      UNPROTECT(1);
      return(ans);
}

SEXP R_G_set_locstring(SEXP loc) {
      char *value;
      char buff[255];

/*      value = G_store(CHAR(STRING_ELT(loc, 0)));  ?? */
      strcpy(buff, CHAR(STRING_ELT(loc, 0)));
      value = G_store(buff);
      if (G__setenv("LOCATION_NAME", value) != 0)
              G_fatal_error("R_set_locstring: LOCATION_NAME not set");

      return(R_G_get_location());
}

SEXP R_G_get_gisdbase() {
      SEXP ans;
      PROTECT(ans=NEW_CHARACTER(1));
      SET_STRING_ELT(ans, 0,
              COPY_TO_USER_STRING(G_getenv("GISDBASE")));
      UNPROTECT(1);
      return(ans);
}

SEXP R_G_set_gisdbasestring(SEXP gisdbase) {
      char *value;
      char buff[255];

/*      value = G_store(CHAR(STRING_ELT(gisdbase, 0)));  ?? */
      strcpy(buff, CHAR(STRING_ELT(gisdbase, 0)));
      value = G_store(buff);
      if (G__setenv("GISDBASE", value) != 0)
              G_fatal_error("R_set_gisdbasestring: GISDBASE not set");

      return(R_G_get_gisdbase());
}


SEXP R_G_get_mapset() {
      SEXP ans;
      PROTECT(ans=NEW_CHARACTER(1));
      SET_STRING_ELT(ans, 0,
              COPY_TO_USER_STRING(G_getenv("MAPSET")));
      UNPROTECT(1);
      return(ans);
}

SEXP R_G_set_mapset(SEXP mapset) {
      char *value;
      char buff[255];

/*      value = G_store(CHAR(STRING_ELT(mapset, 0)));  ?? */
      strcpy(buff, CHAR(STRING_ELT(mapset, 0)));
      value = G_store(buff);
      if (G__setenv("MAPSET", value) != 0)
              G_fatal_error("R_set_gisdbasestring: MAPSET not set");

      return(R_G_get_mapset());
}

SEXP R_G__set_init(SEXP value) {
      SEXP ans;
      int init;
      int init1;
      
      PROTECT(ans=NEW_INTEGER(1));
      init = INTEGER_POINTER(value)[0];
      init1 = G__set_init(init);
      INTEGER_POINTER(ans)[0] = init1;
      UNPROTECT(1);
      return(ans);

}

/* The logic and part of the code of R_G_make_maas() are taken from Frank
 *  Warmerdam's libgrass package, (C) 2000 by the GRASS Development Team
 *  in particular libragras5-1.0.0/gis/gisinit2.c and make_loc.c
 *  */
#if defined __MINGW32_VERSION
#include <io.h>
#endif /* defined __MINGW32_VERSION */

SEXP R_G_make_maas(SEXP metadata) {
	char *location;
	char *mapset;
	struct Cell_head cellhd;
	char path[2048];
	SEXP ans;
 
	PROTECT(ans = NEW_INTEGER(1));
	INTEGER_POINTER(ans)[0] = -1;
	if (G__getenv("LOCATION_NAME") == NULL)
		error("No LOCATION_NAME environmental variable");

        cellhd.north = NUMERIC_POINTER(VECTOR_ELT(metadata, 3))[0];
        cellhd.south = NUMERIC_POINTER(VECTOR_ELT(metadata, 4))[0];
        cellhd.west = NUMERIC_POINTER(VECTOR_ELT(metadata, 5))[0];
        cellhd.east = NUMERIC_POINTER(VECTOR_ELT(metadata, 6))[0];
        cellhd.ns_res = NUMERIC_POINTER(VECTOR_ELT(metadata, 7))[0];
        cellhd.ew_res = NUMERIC_POINTER(VECTOR_ELT(metadata, 8))[0];
        cellhd.rows = INTEGER_POINTER(VECTOR_ELT(metadata, 9))[0];
        cellhd.cols = INTEGER_POINTER(VECTOR_ELT(metadata, 10))[0];
        cellhd.proj = PROJECTION_UTM;
        cellhd.zone = 32;

	location = G_getenv("LOCATION_NAME");
	mapset = G_getenv("MAPSET");
    	sprintf( path, "%s/%s", G_gisdbase(), location);
#if defined __MINGW32_VERSION
    	if( mkdir(path) != 0 )
        	error("unable to create LOCATION");
#else
    	if( mkdir( path, 0775 ) != 0 )
        	error("unable to create LOCATION");
#endif /* defined __MINGW32_VERSION */

    /* Make the PERMANENT mapset. */
	sprintf( path, "%s/%s/%s", G_gisdbase(), location, "PERMANENT" );
#if defined __MINGW32_VERSION
    	if( mkdir(path) != 0 )
        	error("unable to create LOCATION");
#else
    	if( mkdir( path, 0775 ) != 0 )
        	error("unable to create PERMANENT in LOCATION");
#endif /* defined __MINGW32_VERSION */

    /* make these the new current and mapset */
    	G__setenv( "MAPSET", "PERMANENT" );

    /* Create the default, and current window files */
	G__put_window(&cellhd, "", "DEFAULT_WIND" );
	G__put_window(&cellhd, "", "WIND" );

    /* Create window file in working MAPSET */
    	G__setenv( "MAPSET", mapset );
	sprintf( path, "%s/%s/%s", G_gisdbase(), location, G_getenv("MAPSET") );
#if defined __MINGW32_VERSION
    	if( mkdir(path) != 0 )
        	error("unable to create LOCATION");
#else
    	if( mkdir( path, 0775 ) != 0 )
        	error("unable to create RGRASS in LOCATION");
#endif /* defined __MINGW32_VERSION */
	G__put_window(&cellhd, "", "WIND" );

	INTEGER_POINTER(ans)[0] = 0;
	UNPROTECT(1);
	
	return(ans);
}


SEXP R_G_get_mapsets() {
	SEXP ans;
	int i, n;
	n = G__get_nmapset();
	PROTECT(ans=NEW_CHARACTER(n));
	for (i=0; i<n; i++) {
		SET_STRING_ELT(ans, i, COPY_TO_USER_STRING(G__mapset_name(i)));
	}
      	UNPROTECT(1);
      	return(ans);
}

SEXP R_G_refresh_mapsets() {
	G_reset_mapsets();
	return(R_G_get_mapsets());
}
