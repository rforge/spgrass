/* Copyright 2003 by Roger S. Bivand. 
*
* Changes 27 March 2003 - moved k++ inside loop (bug)
*                       - permitted attributes for old-style
*                       sites lists with kk used to create integer
*                       id values (checks on cattype)
**/

#include <string.h>
#include <unistd.h>
#include "grassR.h"

SEXP sitesget(SEXP G, SEXP sitefile, SEXP all) {

   struct Cell_head cellhd;
   FILE *fd;
   char *mapset;
   Site *site;
   Site_head site_info;
   SEXP ans;
   SEXP nncols, names, name, desc, labels, stime;

   int dims, str_att, dbl_att, counter;
   RASTER_MAP_TYPE cattype=-1;
   char msg[255];
   long fpos;
   int i, k, kk, prot=0;
   double val;
   char *errs;
   char sitefile1[255];

   char *pname="sitesget()";
   R_G_init(pname);
   
   if (!LOGICAL_POINTER(all)[0]) {
   
    /* G_get_window(&cellhd); calls G_fatal_error internally */
      if((errs = (G__get_window (&cellhd,"","WIND",G_mapset())))) {
        G_free (errs);
        G_fatal_error ("Bad or no region for current mapset");
      }

      if (NUMERIC_POINTER(VECTOR_ELT(G, 3))[0] != cellhd.north)
         G_fatal_error("Current GRASS region changed: north");
      if (NUMERIC_POINTER(VECTOR_ELT(G, 4))[0] != cellhd.south)
         G_fatal_error("Current GRASS region changed: south");
      if (NUMERIC_POINTER(VECTOR_ELT(G, 5))[0] != cellhd.west)
         G_fatal_error("Current GRASS region changed: west");
      if (NUMERIC_POINTER(VECTOR_ELT(G, 6))[0] != cellhd.east)
         G_fatal_error("Current GRASS region changed: east");
   }

   strcpy(sitefile1, CHAR(STRING_ELT(sitefile, 0)));

   mapset = G_find_file("site_lists", sitefile1, "");  
   if (mapset == NULL) {
      sprintf(msg, "sites file: %s not found", sitefile1);
      G_fatal_error(msg);
   }
   fd = G_fopen_sites_old (sitefile1, mapset);
   if (fd == NULL) {
      sprintf (msg, "can't open sites file [%s]", sitefile1);
      G_fatal_error(msg);
   }

   if (G_site_get_head (fd, &site_info) != 0)
      G_fatal_error ("failed to read site header");

   if (G_site_describe (fd, &dims, &cattype, &str_att, &dbl_att)!=0)
      G_fatal_error("failed to guess format");
   if (cattype < 0) /*{*/
      G_warning("Old style sites file");
/*      PROTECT(ans = NEW_LIST(1));
      SET_VECTOR_ELT(ans, 0, NEW_LIST(dims));
   } else { */
      PROTECT(ans = NEW_LIST(4));
      SET_VECTOR_ELT(ans, 0, NEW_LIST(dims));
      SET_VECTOR_ELT(ans, 1, NEW_LIST(1));
      SET_VECTOR_ELT(ans, 2, NEW_LIST(dbl_att));
      SET_VECTOR_ELT(ans, 3, NEW_LIST(str_att));
/*   }*/
   prot++;

   PROTECT(nncols = NEW_INTEGER(4));
   prot++;
   INTEGER_POINTER(nncols)[0] = dims;
   INTEGER_POINTER(nncols)[1] = cattype;
   INTEGER_POINTER(nncols)[2] = dbl_att;
   INTEGER_POINTER(nncols)[3] = str_att;
   PROTECT(names = NEW_CHARACTER(4));
   prot++;
   SET_STRING_ELT(names, 0, COPY_TO_USER_STRING("dims"));
   SET_STRING_ELT(names, 1, COPY_TO_USER_STRING("cattype"));
   SET_STRING_ELT(names, 2, COPY_TO_USER_STRING("dbl.att"));
   SET_STRING_ELT(names, 3, COPY_TO_USER_STRING("str.att"));
   setAttrib(nncols, R_NamesSymbol, names);

   setAttrib(ans, install("nncols"), nncols);
   
   if (!(site_info.name == (char *) NULL)) {
      PROTECT(name = NEW_CHARACTER(1));
      SET_STRING_ELT(name, 0, COPY_TO_USER_STRING(site_info.name));
      setAttrib(ans, install("name"), name);
      prot++;
   }
   if (!(site_info.desc == (char *) NULL)) {
      PROTECT(desc = NEW_CHARACTER(1));
      SET_STRING_ELT(desc, 0, COPY_TO_USER_STRING(site_info.desc));
      setAttrib(ans, install("desc"), desc);
      prot++;
   }
   if (!(site_info.labels == (char *) NULL)) {
      PROTECT(labels = NEW_CHARACTER(1));
      SET_STRING_ELT(labels, 0, COPY_TO_USER_STRING(site_info.labels));
      setAttrib(ans, install("labels"), labels);
      prot++;
   }
   if (!(site_info.stime == (char *) NULL)) {
      PROTECT(stime = NEW_CHARACTER(1));
      SET_STRING_ELT(stime, 0, COPY_TO_USER_STRING(site_info.stime));
      setAttrib(ans, install("stime"), stime);
      prot++;
   }
   
   site = G_site_new_struct (cattype, dims, str_att, dbl_att);

   counter = 0;
   fpos = ftell(fd);
   
   while (G_site_get (fd, site) == 0) {
      if ((!LOGICAL_POINTER(all)[0])) {
         if ((G_site_in_region (site, &cellhd) == 1)) {
            counter++;
         }
      } else counter++;
   }
   
   if (counter == 0) {
       UNPROTECT(prot);
     G_fatal_error ("no sites in current window");
   }
   for (i=0; i < dims; i++) {
      SET_VECTOR_ELT(VECTOR_ELT(ans, 0), i, NEW_NUMERIC(counter));
   }
   /*if (cattype >= 0) {*/
      if (cattype <= 0) {
         SET_VECTOR_ELT(VECTOR_ELT(ans, 1), 0, NEW_INTEGER(counter));
      } else {
         SET_VECTOR_ELT(VECTOR_ELT(ans, 1), 0, NEW_NUMERIC(counter));
      }
      for (i=0; i < dbl_att; i++) {
         SET_VECTOR_ELT(VECTOR_ELT(ans, 2), i, NEW_NUMERIC(counter));
      }     
      for (i=0; i < str_att; i++) {
         SET_VECTOR_ELT(VECTOR_ELT(ans, 3), i, NEW_CHARACTER(counter));
      }
   /*}*/
   
   if (fseek(fd, fpos, SEEK_SET) != 0)
      G_fatal_error("File rewind failed");
   
   k=0;
   kk=1;
   while (G_site_get (fd, site) == 0) {
      if ((LOGICAL_POINTER(all)[0]) || 
		      (G_site_in_region (site, &cellhd) == 1)) {
	    NUMERIC_POINTER(VECTOR_ELT(VECTOR_ELT(ans, 0), 0))[k] = site->east;
	    NUMERIC_POINTER(VECTOR_ELT(VECTOR_ELT(ans, 0), 1))[k] = site->north;
	    if (dims != site->dim_alloc+2) {
	       G_site_free_struct(site);
	       G_fatal_error("Error reading sites file");
	    }
	    for (i=0; i < site->dim_alloc; i++) {
	       NUMERIC_POINTER(VECTOR_ELT(VECTOR_ELT(ans, 0), (i+2)))[k] = 
	       site->dim[i];
	    }
/*	    if (cattype >= 0) { */
	       if (cattype == 0) {
	          INTEGER_POINTER(VECTOR_ELT(VECTOR_ELT(ans, 1), 0))[k] = 
	             site->ccat;
	       }
	       else if (cattype < 0) {
		   INTEGER_POINTER(VECTOR_ELT(VECTOR_ELT(ans, 1), 0))[k] = kk;
	       }
	       else {
	          if (cattype == 1) val = (double) site->fcat;
	          else val = site->dcat;
	          NUMERIC_POINTER(VECTOR_ELT(VECTOR_ELT(ans, 1), 0))[k] = val;
	       }
	       if (dbl_att != site->dbl_alloc) {
	          G_site_free_struct(site);
	          G_fatal_error("Error reading sites file");
	       }
	       for (i=0; i < site->dbl_alloc; i++) {
	          NUMERIC_POINTER(VECTOR_ELT(VECTOR_ELT(ans, 2), i))[k] = 
	             site->dbl_att[i];
	       }
	       if (str_att != site->str_alloc) {
	          G_site_free_struct(site);
	          G_fatal_error("Error reading sites file");
	       }
	       for (i=0; i < site->str_alloc; i++) {
	          SET_STRING_ELT(VECTOR_ELT(VECTOR_ELT(ans, 3), i), k, 
		         COPY_TO_USER_STRING(site->str_att[i]));
	       }
	 /*  } */
           k++;
      }
      kk++;
   }


   G_site_free_struct(site);
   fclose (fd);

   UNPROTECT(prot);
   return (ans); 

}

