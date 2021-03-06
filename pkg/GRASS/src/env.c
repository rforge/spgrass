/*
 ****************************************************************
 * GIS environment routines
 *
 ***************************************************************
 * char *
 * G_getenv (name)
 *
 *   returns char pointer to value for name
 *   dies if name not set
 *
 ***************************************************************
 * G_setenv (name, value)
 *
 *   sets environment name to value
 *     if value is NULL, becomes an G_unsetenv (name)
 *   updates .gisrc
 *
 ***************************************************************
 * G_unsetenv (name)
 *
 *   remove name from environment
 *   updates .gisrc
 *
 ***************************************************************
 * char *
 * G__getenv (name)
 *
 *   returns char pointer to value for name
 *   returns NULL if name not set
 *
 ***************************************************************
 * G__setenv (name, value)
 *
 *   sets environment name to value
 *   does NOT update .gisrc
 *
 ***************************************************************
 * G__write_env()
 *
 *   writes current environment to .gisrc
 ***************************************************************
 * char *
 * G__env_name (n)
 *
 *   returns environment variable name n
 *   for eample:
 *     for (n = 0; ; n++)
 *       if ((name = G__env_name(n)) == NULL)
 *          break;
 ***************************************************************/

#include <unistd.h>
#if defined R_GRASS_INTERFACE && defined __MINGW32_VERSION
#include "psignal.h"
#else /* __MINGW32_VERSION && R_GRASS_INTERFACE */
#include <signal.h>
#endif /* __MINGW32_VERSION && R_GRASS_INTERFACE */

#include <stdlib.h>
#include <unistd.h>   /* for sleep() */
#include <string.h>
#include "gis.h"
#if defined R_GRASS_INTERFACE && defined __MINGW32_VERSION
#include "grassR.h"
#endif /* __MINGW32_VERSION && R_GRASS_INTERFACE */

#define ENV struct env
ENV
{
    char *name;
    char *value;
} ;

static ENV *env = NULL;
static ENV *env2 = NULL;
static int count = 0;
static int count2 = 0;
static int init = 0;
static char *gisrc = NULL;

static int read_env(void);
static int set_env ( char *, char *);
static int unset_env ( char *);
static char *get_env( char *);
static int write_env (void);
static FILE *open_env ( char *);

#if defined R_GRASS_INTERFACE
int G__set_init(int value)
{
    if (value < 0 || value > 1) {
	G_fatal_error("G__set_init: invalid value");
    }
    init = value;
    return(G__get_init());
}

int G__get_init()
{
    return(init);
}

#endif /* R_GRASS_INTERFACE */


static int 
read_env (void)
{
    char buf[200];
    char *name;
    char *value;
#if defined R_GRASS_INTERFACE && defined __MINGW32_VERSION
    char tmpbuf[255];
#endif /* __MINGW32_VERSION && R_GRASS_INTERFACE */

    FILE *fd;

    if (init)
	return 1;

    init = 1;
    count = 0;

    if ((fd = open_env ("r")))
    {
	while (G_getl (buf, sizeof buf, fd))
	{
	    for (name = value = buf; *value; value++)
		if (*value == ':')
		    break;
	    if (*value == 0)
		continue;

	    *value++ = 0;
	    G_strip (name);
	    G_strip (value);
#if defined R_GRASS_INTERFACE && defined __MINGW32_VERSION
	    if (strcmp(name, "GISDBASE") == 0) {
		sprintf(tmpbuf, "%s%s", G_get_cygwinstring(), value);
		strcpy(value, tmpbuf);
	    }
#endif /* __MINGW32_VERSION && R_GRASS_INTERFACE */
	    if (*name && *value)
		set_env (name, value);
	}
	fclose (fd);
    }

    return 0;
}

static int set_env ( char *name, char *value)
{
    int n;
    int empty;
    char *tv;

/* if value is NULL or empty string, convert into an unsetenv() */
    if(!value || !strlen(value))
    {
	unset_env (name);
	return 0;
    }

    tv = G_store (value);
    G_strip (tv);
    if (*tv == 0)
    {
	free (tv);
	unset_env (name);
	return 1;
    }

/*
* search the array
*   keep track of first empty slot
*   and look for name in the environment
*/
    empty = -1;
    for (n = 0; n < count; n++)
	if (!env[n].name)	/* mark empty slot found */
	    empty = n;
	else if (strcmp (env[n].name, name) == 0)
	{
	    env[n].value = tv;
	    return 1;
	}

/* add name to env: to empty slot if any */
    if (empty >= 0)
    {
	env[empty].name = G_store (name);
	env[empty].value = tv;
	return 0;
    }

/* must increase the env list and add in */
    if ((n = count++))
	env = (ENV *) G_realloc ((char *) env, count * sizeof (ENV));
    else
	env = (ENV *) G_malloc (sizeof (ENV));
    env[n].name = G_store (name);
    env[n].value = tv;

    return 0;
}

static int unset_env (char *name)
{
    int n;

    for (n = 0; n < count; n++)
	if (env[n].name && (strcmp(env[n].name, name)==0))
	{
	    free (env[n].name);
	    env[n].name = 0;
	    return 1;
	}

    return 0;
}

static char *get_env( char *name)
{
    int n;

    for (n = 0; n < count; n++) {
	if (env[n].name && (strcmp(env[n].name, name)==0))
	    return env[n].value;
    }

    return NULL;
}

static int write_env (void)
{
    FILE *fd;
    int n;
    char dummy[2];
    void (*sigint)(), (*sigquit)() ;


/*
 * THIS CODE NEEDS TO BE PROTECTED FROM INTERRUPTS
 * If interrupted, it can wipe out the GISRC file
 */
    sigint  = signal (SIGINT,  SIG_IGN);
    sigquit = signal (SIGQUIT, SIG_IGN);

    if((fd = open_env ("w")))
    {
	for (n = 0; n < count; n++)
	    if (env[n].name && env[n].value
	    && (sscanf (env[n].value,"%1s", dummy) == 1))
		fprintf(fd,"%s: %s\n", env[n].name, env[n].value);
	fclose (fd);
    }

    signal (SIGINT,  sigint);
    signal (SIGQUIT, sigquit);

    return 0;
}

static FILE *open_env ( char *mode)
{
    FILE *fd;
    char *tmpbuf=NULL;
#if defined R_GRASS_INTERFACE && defined __MINGW32_VERSION
    char tmpbuf1[255];
#endif /* __MINGW32_VERSION && R_GRASS_INTERFACE */

    if (!gisrc) {
       tmpbuf = getenv ("GISRC");
    
        if (!tmpbuf)
        {
    		G_fatal_error("GISRC - variable not set");
	    	return(NULL);
	}

#if defined R_GRASS_INTERFACE && defined __MINGW32_VERSION
        sprintf(tmpbuf1, "%s%s", G_get_cygwinstring(), tmpbuf);
        if (G__set_gisrc_file(tmpbuf1) != 0)
            G_fatal_error("GISRC - unable to set");
#else /* __MINGW32_VERSION && R_GRASS_INTERFACE */
        if (G__set_gisrc_file(tmpbuf) != 0)
            G_fatal_error("GISRC - unable to set");
#endif /* __MINGW32_VERSION && R_GRASS_INTERFACE */
    }
    fd = fopen (gisrc, mode);
    return fd;
}

char *G_getenv( char *name)
{
    char *value = NULL;
    char rsbbuf[40]; /* RSB 17 June 2000 */

    if ((value = G__getenv(name)))
	return value;

    /* fprintf(stderr,"ERROR: %s not set\n", name);
    sleep(3);
    exit(-1); */
    /* Roger Bivand 17 June 2000 */
    sprintf(rsbbuf, "%s not set", name);
    G_fatal_error(rsbbuf);
    return value;
}

char *G__getenv ( char *name)
{
    if (strcmp (name, "GISBASE") == 0)
	return getenv (name);

    read_env();

    return get_env (name);
}

int G_setenv (char *name, char *value)
{
    read_env();
    set_env (name, value);
    write_env();
    return 0;
}

int G__setenv ( char *name, char *value)
{
    read_env();
    set_env (name, value);
    return 0;
}

int G_unsetenv ( char *name)
{
    read_env();
    unset_env (name);
    write_env();

    return 0;
}

int 
G__write_env (void)
{
    if (init)
	write_env();

    return 0;
}

char *G__env_name (int n)
{
    int i;

    read_env();
    if (n >= 0)
	for (i = 0; i < count; i++)
	    if (env[i].name && *env[i].name && (n-- == 0))
		return env[i].name;
    return NULL;
}

int G__read_env (void)
{
    init = 0;

    return 0;
}

int G__set_gisrc_file( char *name)
{
    gisrc = NULL;
     if (name && *name)
	gisrc = G_store(name);

     return 0;
}

char *G__get_gisrc_file (void)
{
    FILE *fd;
    if (!gisrc) {
        fd = open_env("r");
        if (fd == NULL) {
		  G_warning("Failure opening GISRC file");
		  G__set_gisrc_file(NULL);
		  return gisrc;
	}
        fclose(fd);
    }

    return gisrc;
}

int G__create_alt_env (void)
{
    int i;

/* copy env to env2 */
    env2 = env;
    count2 = count;
    env = NULL;
    count = 0;

    for (i=0; i < count2; i++)
	if (env2[count].name)
	    set_env (env2[count].name, env2[count].value);

    return 0;
}

int G__switch_env (void)
{
    ENV *tmp;
    int n;

    n   = count;
    tmp = env;

    env   = env2;
    count = count2;

    env2   = tmp;
    count2 = n;

    return 0;
}
