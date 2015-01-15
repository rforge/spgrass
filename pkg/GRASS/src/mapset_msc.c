/*********************************************************
 * G__make_mapset_element (element)
 *     char *element           element to be created in mapset
 *
 * make the specified element in the current mapset
 * will check for the existence of the element and
 * do nothing if it is found so this routine
 * can be called even if the element already exists
 ********************************************************/

#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include "gis.h"

#include <sys/types.h>
#include <sys/stat.h>

int G__make_mapset_element (char *p_element)
{
    char command[1024];
    char *path;
    char *p;
    char *G_mapset();
    char *element;

    element = p_element;
    if (*element == 0)
	    return 0;
    strcpy (path = command, "mkdir ");
    while (*path)
	path++;

    G__file_name (p = path, "", "", G_mapset());
    while (*p)
	p++;
/* add trailing slash if missing */
    --p;
    if (*p++ != '/')
    {
	*p++ = '/' ;
	*p = 0;
    }

/* now append element, one directory at a time, to path */
    while (1)
    {
	if (*element == '/' || *element == 0)
	{
	    *p = 0;
/* MOD shapiro 16apr91 */
	    if (access (path, 0) != 0)
	    {
#if defined R_GRASS_INTERFACE && defined __MINGW32_VERSION
        mkdir(path);
#else /* __MINGW32_VERSION && R_GRASS_INTERFACE */
        mkdir(path,0777);
#endif /* __MINGW32_VERSION && R_GRASS_INTERFACE */
	    }
/* end MOD */
	    if (access (path, 0) != 0)
	    {
		system (command);
	    }
	    if (access (path, 0) != 0)
	    {
		char err[1024];
		sprintf (err, "can't make mapset element %s (%s)", p_element, path);
		G_fatal_error (err);
		/* exit(1); */
	    }
	    if (*element == 0)
		return 1;
	}
	*p++ = *element++;
    }
}

/****************************************************************
* G__mapset_permissions (mapset)
*
* returns: 1 mapset exists, and user has permission
*          0 mapset exists, BUT user denied permission
*         -1 mapset does not exist
****************************************************************/
int G__mapset_permissions (char *mapset)
{
    char path[256];
#if defined __MINGW32_VERSION && defined R_GRASS_INTERFACE
    char path1[256];
    FILE *fd;
#endif /* R_GRASS_INTERFACE && __MINGW32_VERSION */
    struct stat info;

    G__file_name (path,"","",mapset);
#if defined __MINGW32_VERSION && defined R_GRASS_INTERFACE
    G__file_name (path1,"","TODO",mapset);
#endif /* R_GRASS_INTERFACE && __MINGW32_VERSION */

    if (stat (path, &info) != 0)
	    return -1;

#if defined __MINGW32_VERSION && defined R_GRASS_INTERFACE
	if ((fd = fopen(path1, "w")) == NULL) return 0;
	if ((fprintf(fd, "TODO\n")) != 5) return 0;
	if (fclose(fd) != 0)  return 0;
	if (unlink(path1) != 0) return 0;
#else /* R_GRASS_INTERFACE && __MINGW32_VERSION */
    if (info.st_uid != getuid())
	    return 0;
    if (info.st_uid != geteuid())
	    return 0;
#endif /* R_GRASS_INTERFACE && __MINGW32_VERSION */

    return 1;
}
