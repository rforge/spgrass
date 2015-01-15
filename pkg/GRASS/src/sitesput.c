/* Copyright 2003 by Roger S. Bivand. 
*
**/

#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include "grassR.h"

int G_site_put_new_R(FILE *, Site *);
int format_double (double , char *);

/*
 * 	
 * 	n.args:
 * 	0:cattype, 
 * 	1:n, 
 * 	2:ndims, 
 * 	3:ndbls, 
 * 	4:nstrs
 * 	
 * 	res:
 * 	0:G, 
 * 	1:lname, 
 * 	2:n.args, 
 * 	3:all.sites, 
 * 	4:labs, 
 * 	5:ids, 
 * 	6:dims.mat, 
 * 	7:dbl.matt, 
 * 	8:str.mat
 * 	9:call
 * 	10:check
 */

SEXP sitesput(SEXP outlist) {

   Site *site;
   Site_head shead;
   int i, j, n;
   int dims, str_att, dbl_att;
   RASTER_MAP_TYPE cattype=-1;
   FILE *out_fd;
   struct Cell_head cellhd;
   char *mapset;
   SEXP ans;
   char *errs;
   char buff[255];

   char *name="sitesput()";
   R_G_init(name);

   cattype = (int) INTEGER_POINTER(VECTOR_ELT(outlist, 2))[0];
   n = (int) INTEGER_POINTER(VECTOR_ELT(outlist, 2))[1];
   dims = (int) INTEGER_POINTER(VECTOR_ELT(outlist, 2))[2];
   dbl_att = (int) INTEGER_POINTER(VECTOR_ELT(outlist, 2))[3];
   str_att = (int) INTEGER_POINTER(VECTOR_ELT(outlist, 2))[4];

   if (!LOGICAL_POINTER(VECTOR_ELT(outlist, 3))[0]) {

    /* G_get_window(&cellhd); calls G_fatal_error internally */
      if((errs = (G__get_window (&cellhd,"","WIND",G_mapset())))) {
        G_free (errs);
        G_fatal_error ("Bad or no region for current mapset");
      }


      if (NUMERIC_POINTER(VECTOR_ELT(VECTOR_ELT(outlist, 0), 3))[0] 
	!= cellhd.north) error("Current GRASS region changed: north");
      if (NUMERIC_POINTER(VECTOR_ELT(VECTOR_ELT(outlist, 0), 4))[0] 
	!= cellhd.south) error("Current GRASS region changed: south");
      if (NUMERIC_POINTER(VECTOR_ELT(VECTOR_ELT(outlist, 0), 5))[0] 
	!= cellhd.west) error("Current GRASS region changed: west");
      if (NUMERIC_POINTER(VECTOR_ELT(VECTOR_ELT(outlist, 0), 6))[0] 
	!= cellhd.east) error("Current GRASS region changed: east");
   }


   strcpy(buff, CHAR(STRING_ELT(VECTOR_ELT(outlist, 1), 0)));
   if (LOGICAL_POINTER(VECTOR_ELT(outlist, 10))[0]) {
/*      if((mapset = G_find_file("site_lists", 
         CHAR(STRING_ELT(VECTOR_ELT(outlist, 1), 0)), G_mapset())) != NULL)  ?? */
      if((mapset = G_find_file("site_lists", buff, G_mapset())) != NULL)
	 G_fatal_error("Output file already exists");
   }

/*   if (G_legal_filename(CHAR(STRING_ELT(VECTOR_ELT(outlist, 1), 0))) < 0) ?? */
   if (G_legal_filename(buff) < 0)
      G_fatal_error("illegal output file name");

/*   if ((out_fd = G_fopen_sites_new (CHAR(STRING_ELT(VECTOR_ELT(outlist, 
      1), 0)))) == NULL) G_fatal_error("can't create sites file");?? */
      
   if ((out_fd = G_fopen_sites_new (buff)) == NULL) 
      G_fatal_error("can't create sites file");
/*   shead.name = G_store(CHAR(STRING_ELT(VECTOR_ELT(outlist, 1), 0))); ?? */
   shead.name = G_store(buff);
/*   shead.desc = G_store(CHAR(STRING_ELT(VECTOR_ELT(outlist, 9), 0))); ?? */
   strcpy(buff, CHAR(STRING_ELT(VECTOR_ELT(outlist, 9), 0)));
   shead.desc = G_store(buff);
   shead.form = shead.stime = (char *) NULL;
   shead.time = (struct TimeStamp*) NULL;
/*   shead.labels = G_store(CHAR(STRING_ELT(VECTOR_ELT(outlist, 4), 0))); ?? */
   strcpy(buff, CHAR(STRING_ELT(VECTOR_ELT(outlist, 4), 0)));
   shead.labels = G_store(buff);

   G_site_put_head (out_fd, &shead);
   
   site = G_site_new_struct (cattype, dims, str_att, dbl_att);

   for (i = 0; i < n; i++) {
      site->dim_alloc = dims - 2;
      site->east = (double) NUMERIC_POINTER(VECTOR_ELT(outlist, 
         6))[i + (0*n)];
      site->north = (double) NUMERIC_POINTER(VECTOR_ELT(outlist, 
         6))[i + (1*n)];
      for (j = 0; j < site->dim_alloc; j++) 
	 site->dim[j] = NUMERIC_POINTER(VECTOR_ELT(outlist, 
	    6))[i + (j+2)*n];
      
      site->cattype = cattype;
      if (site->cattype == 0) site->ccat = 
         (int) INTEGER_POINTER(VECTOR_ELT(outlist, 5))[i];
      else site->dcat = (double) NUMERIC_POINTER(VECTOR_ELT(outlist, 5))[i];
            
      site->dbl_alloc = dbl_att;
      site->str_alloc = str_att;

      for (j = 0; j < site->dbl_alloc; j++) 
	 site->dbl_att[j] = NUMERIC_POINTER(VECTOR_ELT(outlist,
	    7))[i + (j*n)];
      
      for (j = 0; j < site->str_alloc; j++) {
/*	 site->str_att[j] = G_store(CHAR(STRING_ELT(VECTOR_ELT(outlist,
	    8), (i + (j*n))))); ?? */
         strcpy(buff, CHAR(STRING_ELT(VECTOR_ELT(outlist, 8), (i + (j*n)))));
	 site->str_att[j] = G_store(buff);
      }
      if (G_site_put_new_R(out_fd, site) != 0) {
	 G_site_free_struct(site);
	 fclose (out_fd);
         G_fatal_error("Failure writing data");
      }
   }
    
   G_site_free_struct(site);
   fclose (out_fd);


   PROTECT(ans = NEW_INTEGER(1));
   INTEGER_POINTER(ans)[0] = 0;
   UNPROTECT(1);
   
    return(ans);
}


/* The following two functions are taken from GRASS source code in
 * file grass5.0.1/src/sites/s.in.ascii/main.c, which is 
 * COPYRIGHT:    (C) 2000 by the GRASS Development Team
 * under the GNU General Public License (>=v2). Some minor modifications 
 * have been made.
 */


int format_double (double value, char *buf)
{
  int G_trim_decimal ();
  sprintf (buf, "%.8f", value);
  G_trim_decimal (buf);
  return 0;
}

#define DQUOTE '"'
#define SPACE ' '
#define BSLASH 92
#define PIPE '|'

#define ispipe(c) (c==PIPE)
/* #define isnull(c) (c==(char) NULL) */
#define isnull(c) (c=='\0')
#define isquote(c) (c==DQUOTE)
#define isbslash(c) (c==BSLASH)

int G_site_put_new_R (FILE *fptr, Site *s)

/* Writes a site to file open on fptr. */
{
  char ebuf[MAX_SITE_STRING], nbuf[MAX_SITE_STRING];
  char xbuf[MAX_SITE_STRING], buf[MAX_SITE_LEN];
  int fmt, i, j, k;
  int G_format_northing(), G_format_easting(), G_projection();

  fmt = G_projection ();

  G_format_northing (s->north, nbuf, fmt);
  G_format_easting (s->east, ebuf, fmt);
  sprintf (buf, "%s|%s|", ebuf, nbuf);
  for (i = 0; i < s->dim_alloc; ++i)
  {
    format_double (s->dim[i], nbuf);
    sprintf (xbuf, "%s|", nbuf);
    G_strcat (buf, xbuf);
  }

    switch(s->cattype)
    {
     case CELL_TYPE:
      sprintf (xbuf, "#%d ", s->ccat);
      G_strcat (buf, xbuf);
      break;
     case FCELL_TYPE:
      sprintf (xbuf, "#%g ", s->fcat);
      G_strcat (buf, xbuf);
      break;
     case DCELL_TYPE:
      sprintf (xbuf, "#%g ", s->dcat);
      G_strcat (buf, xbuf);
      break;
    }
                                                      

 /* now import attributes */
  for (i = 0; i < s->dbl_alloc; ++i)
  {
    format_double (s->dbl_att[i], nbuf);
    sprintf (xbuf, "%%%s ", nbuf);
    G_strcat (buf, xbuf);
  }
  
  for (i = 0; i < s->str_alloc; ++i)
  {
    if (strlen (s->str_att[i]) != 0)
    {
      /* escape double quotes */
      j = k = 0;
      if (G_index (s->str_att[i], DQUOTE) != (char *) NULL)
      {
	while (!isnull(s->str_att[i][j]))
	{
	  if (isquote(s->str_att[i][j]))
	  {
	    xbuf[k++] = BSLASH;
	    xbuf[k++] = DQUOTE;
	  }
	  else
	  if (isbslash(s->str_att[i][j]))
	  {
	    xbuf[k++] = BSLASH;
	    xbuf[k++] = BSLASH;
	  }
	  else
	    xbuf[k++] = s->str_att[i][j];
	  j++;
	}
	xbuf[k] = '\0' /*(char) NULL*/;
      }
      else
	G_strcpy (xbuf, s->str_att[i]);

      G_strcpy (s->str_att[i], xbuf);

      if (G_index (s->str_att[i], SPACE) != (char *) NULL)
	  sprintf (xbuf, "@\"%s\" ", s->str_att[i]);
        else
	  sprintf (xbuf, "@%s ", s->str_att[i]);

      G_strcat (buf, xbuf);
    }
  }
  fprintf (fptr, "%s\n", buf);
  return 0;
}

