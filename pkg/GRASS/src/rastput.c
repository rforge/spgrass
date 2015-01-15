/* Copyright 2000-2001 by Roger S. Bivand. 
*
**/

#include <string.h>
#include <unistd.h>
#include "grassR.h"

SEXP rastput(SEXP G, SEXP layer, SEXP isfactor, SEXP dcell, SEXP check,
	SEXP levels, SEXP output, SEXP title, SEXP breaks,
       	SEXP color, SEXP nullcolor, SEXP defcolor, SEXP range)

{
   SEXP ans;
   int GR_nrows;
   int GR_ncols;
   struct Cell_head cellhd;
   int ncells, icell;
   int cf;
   void *rast, *rast_ptr;
   int row, col;
   int i, i1;
   char *mapset;
   struct Categories *labels=NULL;
   struct FPRange *fpr=NULL;
   struct Range *r=NULL;
   struct Colors *colors=NULL;
   struct Quant *q=NULL;
   RASTER_MAP_TYPE data_type=CELL_TYPE;
   DCELL x, b1, b2;
   char *errs;
   char buff[255], buff1[255];

   char *name="rastput()";
   R_G_init(name);


/* assign data_type one of CELL, FCELL, DCELL */
    if (LOGICAL_POINTER(isfactor)[0]) data_type = CELL_TYPE;
    else if(IS_NUMERIC(layer)) {
       if(LOGICAL_POINTER(dcell)[0] || getenv("GRASS_FP_DOUBLE"))
	      data_type = DCELL_TYPE;
      /* respect GRASS environment variable */
      else data_type = FCELL_TYPE;
    }
    else error("Invalid data type");
   
    /* G_get_window(&cellhd); calls G_fatal_error internally */
    if((errs = (G__get_window (&cellhd,"","WIND",G_mapset())))) {
        G_free (errs);
        G_fatal_error ("Bad or no region for current mapset");
    }


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

    strcpy(buff, CHAR(STRING_ELT(output, 0)));
    if (LOGICAL_POINTER(check)[0]) {
/*       if((mapset = G_find_cell(CHAR(STRING_ELT(output, 0)),  ?? */
       if((mapset = G_find_cell(buff, G_mapset())) != NULL) 
         G_fatal_error("Output file already exists");
    }

    GR_nrows = cellhd.rows; GR_ncols = cellhd.cols;
    ncells = GR_nrows * GR_ncols;
    if (ncells != GET_LENGTH(layer))
	G_fatal_error("Input layer of wrong length");
    rast_ptr = G_allocate_raster_buf(data_type);
    rast = rast_ptr;
/*    if (G_legal_filename(CHAR(STRING_ELT(output, 0))) < 0)   ?? */
    if (G_legal_filename(buff) < 0)  
	G_fatal_error("illegal output file name");
/*    if((cf = G_open_raster_new(CHAR(STRING_ELT(output, 0)), data_type)) < 0)
	G_fatal_error ("unable to create raster map");   ?? */
    if((cf = G_open_raster_new(buff, data_type)) < 0)
	G_fatal_error ("unable to create raster map");
/* transfer data respecting NAs */
    icell = 0;

    for (row = 0; row < GR_nrows; row++) {
       for (col = 0; col < GR_ncols; col++) {
	   if (data_type == CELL_TYPE) {
	       if (INTEGER_POINTER(layer)[icell] == NA_INTEGER)
		   G_set_null_value(rast_ptr, 1, data_type);
	       else G_set_raster_value_c(rast_ptr, 
		   (CELL)(INTEGER_POINTER(layer)[icell]), data_type);
	   }
	   else {
	       if (ISNA(NUMERIC_POINTER(layer)[icell]))
		   G_set_null_value(rast_ptr, 1, data_type);
	       else {
		   x = (DCELL)(NUMERIC_POINTER(layer)[icell]);
		   G_set_raster_value_d(rast_ptr, x, data_type);
	       }
	   }
	   icell++;
	   rast_ptr = G_incr_void_ptr(rast_ptr, G_raster_size(data_type));
       }
       if(G_put_raster_row (cf, rast, data_type) < 0)
	       G_fatal_error ("failure putting raster row");
       rast_ptr = rast;
    }
    if(G_close_cell (cf) != 1) G_fatal_error ("failure closing cell file");
/*    if(G_put_cell_title (CHAR(STRING_ELT(output, 0)),  
	 CHAR(STRING_ELT(title, 0))) != 1)   ?? */
    strcpy(buff1, CHAR(STRING_ELT(title, 0)));
    if(G_put_cell_title (buff, buff1) != 1) 
	    G_fatal_error ("error writing cell title");
/* create and write ranges */
    if (LOGICAL_POINTER(isfactor)[0]) {
        r = (struct Range *) R_alloc ((long) 1, sizeof(struct Range));
	G_init_range(&r[0]); 
        G_update_range((CELL) (INTEGER_POINTER(range)[0]), &r[0]);
	G_update_range((CELL) (INTEGER_POINTER(range)[1]), &r[0]);
/* 	if(G_write_range(CHAR(STRING_ELT(output, 0)), &r[0]) != 0)  ?? */
	if(G_write_range(buff, &r[0]) != 0)  
		G_fatal_error ("error writing range");
    } else {
        fpr = (struct FPRange *) R_alloc ((long) 1, sizeof(struct FPRange));
        G_init_fp_range(&fpr[0]); 
        G_update_fp_range(NUMERIC_POINTER(range)[0], &fpr[0]);
	G_update_fp_range(NUMERIC_POINTER(range)[1], &fpr[0]);
/*      if(G_write_fp_range(CHAR(STRING_ELT(output, 0)), &fpr[0]) != 0)  ?? */
        if(G_write_fp_range(buff, &fpr[0]) != 0)
		G_fatal_error ("error writing range");
    }
/* create and write labels, colours */ 
    labels = (struct Categories *) R_alloc ((long) 1,
	sizeof(struct Categories));
    colors = (struct Colors *) R_alloc ((long) 1,
	sizeof(struct Colors));
    
/*    G_init_cats((CELL) 1, CHAR(STRING_ELT(title, 0)), &labels[0]); ?? */
    G_init_cats((CELL) 1, buff1, &labels[0]);
    G_init_colors(&colors[0]);
  
    if (LOGICAL_POINTER(isfactor)[0]) {
        for (i=0; i<GET_LENGTH(levels); i++) {
	    i1 = i+1;
            strcpy(buff1, CHAR(STRING_ELT(levels, i)));
/*            if(G_set_c_raster_cat((CELL *) &i1, (CELL *) &i1,
		CHAR(STRING_ELT(levels, i)), &labels[0]) < 0) {  ?? */
            if(G_set_c_raster_cat((CELL *) &i1, (CELL *) &i1,
		buff1, &labels[0]) < 0) {
		    G_free_cats(&labels[0]);
		    G_free_colors(&colors[0]);
		    G_fatal_error ("error setting category label");
	    }
	    G_add_c_raster_color_rule((CELL *) &i1,
	       	(int) (INTEGER_POINTER(color)[(3*i)+0]),
		(int) (INTEGER_POINTER(color)[(3*i)+1]),
		(int) (INTEGER_POINTER(color)[(3*i)+2]),
		(CELL *) &i1,
	       	(int) (INTEGER_POINTER(color)[(3*i)+0]),
		(int) (INTEGER_POINTER(color)[(3*i)+1]),
		(int) (INTEGER_POINTER(color)[(3*i)+2]),
		&colors[0]);
        }
    } else { /* and quantization for non-factors */
	q = (struct Quant *) R_alloc ((long) 1, sizeof(struct Quant));
	G_quant_init(&q[0]);
	G_mark_colors_as_fp(&colors[0]);
        for (i=0; i<GET_LENGTH(levels); i++) {
	    i1 = i+1;
	    b1 = (DCELL) NUMERIC_POINTER(breaks)[i];
	    b2 = (DCELL) NUMERIC_POINTER(breaks)[i1];
            strcpy(buff1, CHAR(STRING_ELT(levels, i)));
/*            if(G_set_d_raster_cat((DCELL *) &b1,
	       	(DCELL *) &b2,
	       	CHAR(STRING_ELT(levels, i)), &labels[0]) < 0) {  ?? */
            if(G_set_d_raster_cat((DCELL *) &b1,
	       	(DCELL *) &b2,
	       	buff1, &labels[0]) < 0) {
		    G_quant_free(&q[0]);
		    G_free_cats(&labels[0]);
		    G_free_colors(&colors[0]);
		    G_fatal_error ("error setting category label");
	    }
	    G_add_d_raster_color_rule((DCELL *) &b1,
	       	(int) (INTEGER_POINTER(color)[(3*i)+0]),
		(int) (INTEGER_POINTER(color)[(3*i)+1]),
		(int) (INTEGER_POINTER(color)[(3*i)+2]),
		(DCELL *) &b2,
		(int) (INTEGER_POINTER(color)[(3*i)+0]),
		(int) (INTEGER_POINTER(color)[(3*i)+1]),
		(int) (INTEGER_POINTER(color)[(3*i)+2]),
		&colors[0]);
	    G_quant_add_rule(&q[0], (DCELL) b1, (DCELL) b2,
		(CELL) i1, (CELL) i1);
	}
	G__quant_organize_fp_lookup(&q[0]);
/*	if (G_write_quant(CHAR(STRING_ELT(output, 0)), G_mapset(),
	    &q[0]) != 1) {  ?? */
	if (G_write_quant(buff, G_mapset(), &q[0]) != 1) { 
		G_quant_free(&q[0]);
		G_fatal_error ("error writing quants");
	}
        G_quant_free(&q[0]);
    }
    G_set_null_value_color((int) (INTEGER_POINTER(nullcolor)[0]),
		(int) (INTEGER_POINTER(nullcolor)[1]),
		(int) (INTEGER_POINTER(nullcolor)[2]), &colors[0]);
    G_set_default_color((int) (INTEGER_POINTER(defcolor)[0]),
		(int) (INTEGER_POINTER(defcolor)[1]),
		(int) (INTEGER_POINTER(defcolor)[2]), &colors[0]);
    
/*    if(G_write_cats(CHAR(STRING_ELT(output, 0)), &labels[0]) != 1) {  ?? */
      if(G_write_cats(buff, &labels[0]) != 1) {
	G_free_cats(&labels[0]);
	G_free_colors(&colors[0]);
        G_fatal_error ("error writing categories");
    }
    G_free_cats(&labels[0]);
/*    if(G_write_colors(CHAR(STRING_ELT(output, 0)), G_mapset(),  ?? */
    if(G_write_colors(buff, G_mapset(),	&colors[0]) != 1) {
	    G_free_colors(&colors[0]);
            G_fatal_error ("error writing colours");
    }
    G_free_colors(&colors[0]);
    
    PROTECT(ans = NEW_INTEGER(1));
    INTEGER_POINTER(ans)[0] = 0;
    UNPROTECT(1);
   
    return(ans);
}
