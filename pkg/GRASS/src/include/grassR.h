/* Copyright 2000-2003 by Roger S. Bivand. 
*
**/

#include <R.h>
#include <Rdefines.h>

#include <gis.h> 
#include <site.h>

int R_handler(char *message, int fatal);
void R_G_init(char *name);
int G__get_nmapset();

#if defined R_GRASS_INTERFACE && defined __MINGW32_VERSION
char *G_get_cygwinstring();
#endif /* __MINGW32_VERSION && R_GRASS_INTERFACE */

