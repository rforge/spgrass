#include "gis.h"
/*
 ***********************************************************
 *  G_getl(buf, n, fd)
 *     char *buf         buffer to receive read data
 *     int n             max num of bytes to read
 *     FILE *fd          file descriptor structure
 *
 *  does fgets() and removes trailing newline
 *  
 *  returns: 1 ok, 0 eof
 ************************************************************/

#include <stdio.h>
int G_getl ( char *buf, int n, FILE *fd)
{
    if (!fgets (buf, n, fd))
	return 0;

#if defined R_GRASS_INTERFACE && defined __MINGW32_VERSION
    for (; *buf && *buf != '\r' && *buf != '\n'; buf++)
          ;
#else /* __MINGW32_VERSION && R_GRASS_INTERFACE */
    for (; *buf && *buf != '\n'; buf++)
	    ;
#endif /* __MINGW32_VERSION && R_GRASS_INTERFACE */
    *buf = 0;

    return 1;
}
