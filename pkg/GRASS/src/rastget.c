/* Copyright 2000 by Roger S. Bivand. 
*
**/

#include <string.h>
#include <unistd.h>
#include "grassR.h"

int G_get_raster_cat_i(void *, struct Categories *, RASTER_MAP_TYPE);



SEXP rastget(SEXP G, SEXP layers, SEXP flayers) {
   int GR_nrows;
   int GR_ncols;
   int *ncats=NULL;

   struct Categories *labels=NULL;

   SEXP ans;
   SEXP ansnames;
   SEXP anslevels;
   SEXP class;
   SEXP mname;
   int nlayers = GET_LENGTH(layers);
   int i, j;
   int *fd;
   int ncells, icell;
   int row, col;
   char *mapset;
   char msg[255], tmp[255], mname1[255], mname0[255];
   void **rast, **rastp;
   void *rast1, *rast2;
   struct Cell_head cellhd;
   CELL null_cell;
   RASTER_MAP_TYPE *map_type;

   int ival;
   double val;
   char *errs;


   char *name="rastget()";
   R_G_init(name);
   
    /* G_get_window(&cellhd); calls G_fatal_error internally */
    if((errs = (G__get_window (&cellhd,"","WIND",G_mapset())))) {
        G_free (errs);
        G_fatal_error ("Bad or no region for current mapset");
    }
   /* G_get_window(&cellhd); */


   if (NUMERIC_POINTER(VECTOR_ELT(G, 3))[0] != cellhd.north)
      error("Current GRASS region changed: north");
   if (NUMERIC_POINTER(VECTOR_ELT(G, 4))[0] != cellhd.south)
      error("Current GRASS region changed: south");
   if (NUMERIC_POINTER(VECTOR_ELT(G, 5))[0] != cellhd.west)
      error("Current GRASS region changed: west");
   if (NUMERIC_POINTER(VECTOR_ELT(G, 6))[0] != cellhd.east)
      error("Current GRASS region changed: east");
   if (NUMERIC_POINTER(VECTOR_ELT(G, 7))[0] != cellhd.ns_res)
      error("Current GRASS region changed: ns_res");
   if (NUMERIC_POINTER(VECTOR_ELT(G, 8))[0] != cellhd.ew_res)
      error("Current GRASS region changed: ew_res");
   if (INTEGER_POINTER(VECTOR_ELT(G, 9))[0] != cellhd.rows)
      error("Current GRASS region changed: rows");
   if (INTEGER_POINTER(VECTOR_ELT(G, 10))[0] != cellhd.cols)
      error("Current GRASS region changed: cols");

   PROTECT(mname = NEW_CHARACTER(1));

   for (i = 0; i < nlayers; i++) {
/*      SET_STRING_ELT(mname, 0, STRING_ELT(layers, i)); 
      mapset = G_find_cell2(CHAR(STRING_ELT(mname, 0)), "");  75 */
      strcpy(mname0, CHAR(STRING_ELT(layers, i)));
      mapset = G_find_cell2(mname0, "");
      if(( mapset ) == NULL) { 
	 sprintf(msg, "raster map: %s not found", CHAR(STRING_ELT(layers, i)));
         error(msg);
      }
   } 

   GR_nrows = cellhd.rows; GR_ncols = cellhd.cols;
   ncells = GR_nrows * GR_ncols;
   fd = (int *) R_alloc ((long) nlayers, sizeof(int));
   ncats = (int *) R_alloc ((long) nlayers, sizeof(int));
   labels = (struct Categories *) R_alloc ((long) nlayers, 
      sizeof(struct Categories));
   rast = (void **) R_alloc ((long) 1, sizeof (void *));
   rastp = (void **) R_alloc ((long) 1, sizeof (void *));
   map_type = (RASTER_MAP_TYPE *) R_alloc ((long) nlayers, 
      sizeof( RASTER_MAP_TYPE));


   for (i = 0; i < nlayers; i++) {

/*      SET_STRING_ELT(mname, 0, 
         COPY_TO_USER_STRING(CHAR(STRING_ELT(layers, i))));
      mapset = G_find_cell(CHAR(STRING_ELT(mname, 0)), "");  98 */
      strcpy(mname0, CHAR(STRING_ELT(layers, i)));
      mapset = G_find_cell(mname0, "");
	
/*      map_type[i] = G_raster_map_type(CHAR(STRING_ELT(mname, 0)), mapset);*/
      map_type[i] = G_raster_map_type(mname0, mapset);
      if (map_type[i] < 0) {
         for (j=0; j==i; j++) G_close_cell(fd[j]);
         sprintf(msg, "layer %s of unknown type",
           CHAR(STRING_ELT(layers, i)));
	 G_fatal_error(msg);
      }
      
        if (LOGICAL_POINTER(flayers)[i]) {
/*           if (G_read_raster_cats(CHAR(STRING_ELT(mname, 0)),*/
           if (G_read_raster_cats(mname0,
		mapset, &labels[i]) < 0) {
            for (j=0; j==i; j++) G_close_cell(fd[j]);
	    sprintf(msg, "category support for layer %s missing or invalid",
	       CHAR(STRING_ELT(layers, i)));
	    G_fatal_error(msg);
	 }
	 else ncats[i] = G_number_of_raster_cats(&labels[i]);
      }

/*      fd[i] = G_open_cell_old(CHAR(STRING_ELT(mname, 0)), mapset);*/
      fd[i] = G_open_cell_old(mname0, mapset);
      if (fd[i] < 0) {
            for (j=0; j<i; j++) G_close_cell(fd[j]);
	    sprintf(msg, "unable to open %s", 
		CHAR(STRING_ELT(layers, i)));
            G_fatal_error(msg);
      }
   }

   

   PROTECT(ans = NEW_LIST(nlayers));
   PROTECT(anslevels = NEW_LIST(nlayers));
   PROTECT(ansnames = NEW_CHARACTER(nlayers));
   PROTECT(class = NEW_CHARACTER(2));
   SET_STRING_ELT(class, 0, COPY_TO_USER_STRING("ordered"));
   SET_STRING_ELT(class, 1, COPY_TO_USER_STRING("factor"));

   G_set_c_null_value(&null_cell, 1);

   for (i = 0; i < nlayers; i++) {
      
      rast[0] = (void *) malloc ((cellhd.cols + 1) *
		      G_raster_size(map_type[i]));
      if (rast[0] == NULL) {
	      for (j=0; j<i; j++) G_close_cell(fd[j]);
	      error("memory allocation error");
      }

      icell = 0;

      SET_STRING_ELT(mname, 0, 
         COPY_TO_USER_STRING(CHAR(STRING_ELT(layers, i))));
      sprintf(tmp, "%s", CHAR(STRING_ELT(mname, 0)));
      for (j=0; j<strlen(tmp); j++)
         if (tmp[j] == '@') mname1[j] = '_';
         else mname1[j] = tmp[j];
      mname1[strlen(tmp)] = '\0';

      if(LOGICAL_POINTER(flayers)[i]) {
	 SET_VECTOR_ELT(ans, i, NEW_INTEGER(ncells));
	 SET_VECTOR_ELT(anslevels, i, NEW_CHARACTER(ncats[i]));
	 sprintf(tmp, "%s.f", mname1);
	 SET_STRING_ELT(ansnames, i, COPY_TO_USER_STRING(tmp));
	 for (j=0; j<ncats[i]; j++) {
	   SET_STRING_ELT(VECTOR_ELT(anslevels, i), j, 
	      COPY_TO_USER_STRING(G_get_ith_raster_cat(&labels[i], j, 
		&rast1, &rast2, map_type[i])));
	 }
      }
      else {
	 SET_VECTOR_ELT(ans, i, NEW_NUMERIC(ncells));
	 SET_STRING_ELT(ansnames, i, COPY_TO_USER_STRING(mname1));
      }

      for (row = 0; row < GR_nrows; row++) {

         if(G_get_raster_row(fd[i], rast[0], row, map_type[i]) < 0) {
            for (j=0; j<nlayers; j++) G_close_cell(fd[j]);
            sprintf(msg, "read failure at row %d for layer %s", 
               row, CHAR(STRING_ELT(layers, i)));
            error(msg);
         }
         rastp[0] = rast[0];

         for (col = 0; col < GR_ncols; col++) {

            if (G_is_null_value(rastp[0], map_type[i])) {
               if (LOGICAL_POINTER(flayers)[i]) {
                  INTEGER_POINTER(VECTOR_ELT(ans, i))[icell] =
                     NA_INTEGER;
               } else {
                  NUMERIC_POINTER(VECTOR_ELT(ans, i))[icell] = NA_REAL;
               }
            }
            else {
               if (LOGICAL_POINTER(flayers)[i]) {
                  ival = G_get_raster_cat_i(rastp[0], &labels[i], map_type[i]);
                  INTEGER_POINTER(VECTOR_ELT(ans, i))[icell] =  ival;
               } else {
                  val = G_get_raster_value_d(rastp[0], map_type[i]);
                  NUMERIC_POINTER(VECTOR_ELT(ans, i))[icell] =  val;
               }
            }
            rastp[0] = G_incr_void_ptr(rastp[0], G_raster_size(map_type[i]));
            icell++;
         }
      }
      free(rast[0]);
      if(LOGICAL_POINTER(flayers)[i]) {
	 setAttrib(VECTOR_ELT(ans, i), R_LevelsSymbol, 
	    VECTOR_ELT(anslevels, i));
	 setAttrib(VECTOR_ELT(ans, i), R_ClassSymbol, class);
      }
   }
   for (i=0; i<nlayers; i++) G_close_cell(fd[i]);
   for (i=0; i<nlayers; i++)  
      if (LOGICAL_POINTER(flayers)[i])
         G_free_raster_cats(&labels[i]);
   setAttrib(ans, R_NamesSymbol, ansnames);
   
   UNPROTECT(5);
   return (ans); 
}

