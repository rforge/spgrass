AC_INIT([GRASS], 0.3-2)

CPPFLAGS=

: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
    echo "could not determine R_HOME"
    exit 1
fi
CC=`"${R_HOME}/bin/R" CMD config CC`
CFLAGS=`"${R_HOME}/bin/R" CMD config CFLAGS`

AC_ARG_WITH([xdr-include],
            AC_HELP_STRING([--with-xdr-include=INCLUDE_PATH],
                           [the location of xdr header files]),
            [xdr_include_path=$withval])
if test [ -n "$xdr_include_path" ] ; then
    AC_SUBST([CPPFLAGS],["-I${xdr_include_path} ${CPPFLAGS}"])
else
    if test [ -n "${XDR_INCLUDE}" ] ; then
        AC_SUBST([CPPFLAGS],["-I${XDR_INCLUDE} ${CPPFLAGS}"])
    fi
fi

AC_CHECK_HEADERS(rpc/xdr.h rpc/types.h)
if test "${ac_cv_header_rpc/xdr_h}" = no ||
    test "${ac_cv_header_rpc/types_h}" = no; then
    AC_MSG_ERROR("xdr headers rpc/xdr.h and rpc/types.h not found")
fi
AC_SEARCH_LIBS(xdrmem_create, [nsl])

AC_ARG_WITH([zlib-include],
            AC_HELP_STRING([--with-zlib-include=INCLUDE_PATH],
                           [the location of zlib header files]),
            [zlib_include_path=$withval])
if test [ -n "$zlib_include_path" ] ; then
    AC_SUBST([CPPFLAGS],["-I${zlib_include_path} ${CPPFLAGS}"])
else
    if test [ -n "${ZLIB_INCLUDE}" ] ; then
        AC_SUBST([CPPFLAGS],["-I${ZLIB_INCLUDE} ${CPPFLAGS}"])
    fi
fi

AC_CHECK_HEADERS(zconf.h zlib.h)
if test "${ac_cv_header_zconf_h}" = no ||
    test "${ac_cv_header_zlib_h}" = no; then
    AC_MSG_ERROR("zlib headers zlib.h and zconf.h not found")
fi

AC_SEARCH_LIBS(deflate, z, AC_SUBST([LIBS],["-lz"]),
                AC_MSG_ERROR("no deflate function found"))


AC_SUBST(LIBS)
AC_SUBST(CPPFLAGS)
AC_OUTPUT(src/Makevars)

