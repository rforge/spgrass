/* Copyright 2000-2001 by Roger S. Bivand. 
 * *
 * **/

#include "grassR.h"


SEXP eastG(SEXP G) {
	SEXP ans;
	int i, j, k;

	PROTECT(ans = NEW_NUMERIC(INTEGER_POINTER(VECTOR_ELT(G, 11))[0]));
	
	for (j = 0; j < INTEGER_POINTER(VECTOR_ELT(G, 9))[0]; j++) {
	    for (i = 0; i < INTEGER_POINTER(VECTOR_ELT(G, 10))[0]; i++) {
		k = (j * INTEGER_POINTER(VECTOR_ELT(G, 10))[0]) + i;
		NUMERIC_POINTER(ans)[k] = 
			NUMERIC_POINTER(VECTOR_ELT(G, 14))[i];
	    }
	}

	UNPROTECT(1);
	return(ans);
}


SEXP northG(SEXP G) {
	SEXP ans;
	int i, j, k;

	PROTECT(ans = NEW_NUMERIC(INTEGER_POINTER(VECTOR_ELT(G, 11))[0]));
	
	for (j = 0; j < INTEGER_POINTER(VECTOR_ELT(G, 9))[0]; j++) {
	    for (i = 0; i < INTEGER_POINTER(VECTOR_ELT(G, 10))[0]; i++) {
		k = (j * INTEGER_POINTER(VECTOR_ELT(G,10))[0]) + i;
		NUMERIC_POINTER(ans)[k] = 
			NUMERIC_POINTER(VECTOR_ELT(G, 16))[j];
	    }
	}

	UNPROTECT(1);
	return(ans);

}

SEXP obsnoG(SEXP G) {
	SEXP ans;
	int i;

	PROTECT(ans = NEW_INTEGER(INTEGER_POINTER(VECTOR_ELT(G, 11))[0]));
	
	for (i = 0; i < INTEGER_POINTER(VECTOR_ELT(G, 11))[0]; i++)
	    	INTEGER_POINTER(ans)[i] = i+1;

	UNPROTECT(1);
	return(ans);
}


SEXP reverseG(SEXP G) {
	SEXP ans, obs;
	int i, j, k, ii;

	PROTECT(obs = obsnoG(G));

	PROTECT(ans = NEW_INTEGER(INTEGER_POINTER(VECTOR_ELT(G, 11))[0]));
	
	for (j = INTEGER_POINTER(VECTOR_ELT(G, 9))[0]-1, ii = 0;
	    j > -1; j--) {
	    for (i = 0; i < INTEGER_POINTER(VECTOR_ELT(G, 10))[0]; i++) {
		k = (j * INTEGER_POINTER(VECTOR_ELT(G, 10))[0]) + i;
		INTEGER_POINTER(ans)[ii++] = INTEGER_POINTER(obs)[k];
	    }
	}

	UNPROTECT(2);
	return(ans);
}



