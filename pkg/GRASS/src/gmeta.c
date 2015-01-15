/* Copyright 2000-2001 by Roger S. Bivand. 
*
**/

#include "grassR.h"

SEXP gmeta() {
	SEXP ans, elnames, class;
	int i, proj;
	char chbuf[256];
	struct Cell_head cellhd;
	double start;
	char *errs;

	char *name="gmeta()";
	R_G_init(name);

	PROTECT(ans = NEW_LIST(17));
	SET_VECTOR_ELT(ans, 0, NEW_CHARACTER(1));
	SET_VECTOR_ELT(ans, 1, NEW_CHARACTER(1));
	SET_VECTOR_ELT(ans, 2, NEW_CHARACTER(1));
	SET_VECTOR_ELT(ans, 3, NEW_NUMERIC(1));
	SET_VECTOR_ELT(ans, 4, NEW_NUMERIC(1));
	SET_VECTOR_ELT(ans, 5, NEW_NUMERIC(1));
	SET_VECTOR_ELT(ans, 6, NEW_NUMERIC(1));
	SET_VECTOR_ELT(ans, 7, NEW_NUMERIC(1));
	SET_VECTOR_ELT(ans, 8, NEW_NUMERIC(1));
	SET_VECTOR_ELT(ans, 9, NEW_INTEGER(1));
	SET_VECTOR_ELT(ans, 10, NEW_INTEGER(1));
	SET_VECTOR_ELT(ans, 11, NEW_INTEGER(1));
	SET_VECTOR_ELT(ans, 12, NEW_NUMERIC(2));
	SET_VECTOR_ELT(ans, 13, NEW_NUMERIC(2));
	
	SET_STRING_ELT(VECTOR_ELT(ans, 0), 0,
		COPY_TO_USER_STRING(G_location()));
	SET_STRING_ELT(VECTOR_ELT(ans, 1), 0, 
		COPY_TO_USER_STRING(G_mapset()));
	proj = G_projection();
	if (proj != 1) SET_STRING_ELT(VECTOR_ELT(ans, 2), 0, 
		COPY_TO_USER_STRING(G_database_projection_name()));
	else {
		sprintf(chbuf, "%s, zone: %d", G_database_projection_name(),
			G_zone());
		SET_STRING_ELT(VECTOR_ELT(ans, 2), 0, 
		COPY_TO_USER_STRING(chbuf));
	}

/*	G_get_window(&cellhd); */
	if((errs = (G__get_window (&cellhd,"","WIND",G_mapset())))) {
	    G_free (errs);
	    G_fatal_error ("Bad or no region for current mapset");
	}

	NUMERIC_POINTER(VECTOR_ELT(ans, 3))[0] = cellhd.north;
	NUMERIC_POINTER(VECTOR_ELT(ans, 4))[0] = cellhd.south;
	NUMERIC_POINTER(VECTOR_ELT(ans, 5))[0] = cellhd.west;
	NUMERIC_POINTER(VECTOR_ELT(ans, 6))[0] = cellhd.east;
	NUMERIC_POINTER(VECTOR_ELT(ans, 7))[0] = cellhd.ns_res;
	NUMERIC_POINTER(VECTOR_ELT(ans, 8))[0] = cellhd.ew_res;
	INTEGER_POINTER(VECTOR_ELT(ans, 9))[0] = cellhd.rows;
	INTEGER_POINTER(VECTOR_ELT(ans, 10))[0] = cellhd.cols;
	INTEGER_POINTER(VECTOR_ELT(ans, 11))[0] = cellhd.rows*cellhd.cols;

	NUMERIC_POINTER(VECTOR_ELT(ans, 12))[0] = cellhd.west;
	NUMERIC_POINTER(VECTOR_ELT(ans, 12))[1] = cellhd.east;
	NUMERIC_POINTER(VECTOR_ELT(ans, 13))[0] = cellhd.south;
	NUMERIC_POINTER(VECTOR_ELT(ans, 13))[1] = cellhd.north;
	
	SET_VECTOR_ELT(ans, 14, NEW_NUMERIC(cellhd.cols));
	start = cellhd.west + (cellhd.ew_res / 2);
	for (i = 0; i < cellhd.cols; i++) {
		NUMERIC_POINTER(VECTOR_ELT(ans, 14))[i] = start;
		start += cellhd.ew_res;
	}

	SET_VECTOR_ELT(ans, 15, NEW_NUMERIC(cellhd.rows));
	start = cellhd.south + (cellhd.ns_res / 2);
	for (i = 0; i < cellhd.rows; i++) {
		NUMERIC_POINTER(VECTOR_ELT(ans, 15))[i] = start;
		start += cellhd.ns_res;
	}
	SET_VECTOR_ELT(ans, 16, NEW_NUMERIC(cellhd.rows));
	start = cellhd.north - (cellhd.ns_res / 2);
	for (i = 0; i < cellhd.rows; i++) {
		NUMERIC_POINTER(VECTOR_ELT(ans, 16))[i] = start;
		start -= cellhd.ns_res;
	}

	PROTECT(elnames = NEW_CHARACTER(17));
	SET_STRING_ELT(elnames, 0, COPY_TO_USER_STRING("LOCATION"));
	SET_STRING_ELT(elnames, 1, COPY_TO_USER_STRING("MAPSET"));
	SET_STRING_ELT(elnames, 2, COPY_TO_USER_STRING("proj"));
	SET_STRING_ELT(elnames, 3, COPY_TO_USER_STRING("n"));
	SET_STRING_ELT(elnames, 4, COPY_TO_USER_STRING("s"));
	SET_STRING_ELT(elnames, 5, COPY_TO_USER_STRING("w"));
	SET_STRING_ELT(elnames, 6, COPY_TO_USER_STRING("e"));
	SET_STRING_ELT(elnames, 7, COPY_TO_USER_STRING("nsres"));
	SET_STRING_ELT(elnames, 8, COPY_TO_USER_STRING("ewres"));
	SET_STRING_ELT(elnames, 9, COPY_TO_USER_STRING("Nrow"));
	SET_STRING_ELT(elnames, 10, COPY_TO_USER_STRING("Ncol"));
	SET_STRING_ELT(elnames, 11, COPY_TO_USER_STRING("Ncells"));
	SET_STRING_ELT(elnames, 12, COPY_TO_USER_STRING("xlims"));
	SET_STRING_ELT(elnames, 13, COPY_TO_USER_STRING("ylims"));
	SET_STRING_ELT(elnames, 14, COPY_TO_USER_STRING("xseq"));
	SET_STRING_ELT(elnames, 15, COPY_TO_USER_STRING("yseq"));
	SET_STRING_ELT(elnames, 16, COPY_TO_USER_STRING("ryseq"));
	setAttrib(ans, R_NamesSymbol, elnames);
	
	PROTECT(class = NEW_CHARACTER(1));
	SET_STRING_ELT(class, 0, COPY_TO_USER_STRING("grassmeta"));
	setAttrib(ans, R_ClassSymbol, class);

	UNPROTECT(3);
	return(ans);
}

