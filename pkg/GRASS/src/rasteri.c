/* Copyright 2000 by Roger S. Bivand. 
*
**/

#include "grassR.h"
#define NO_DATA (G_set_c_null_value (&tmp, 1), (CELL) tmp)

int G_get_raster_cat_i(void *rast, struct Categories *pcats , RASTER_MAP_TYPE data_type)
{
    CELL i;
    CELL tmp;
    DCELL val;

    val = G_get_raster_value_d(rast, data_type);
    i = G_quant_get_cell_value(&pcats->q, val);
    if(i == NO_DATA) G_fatal_error("category code lookup failure");
    return (int) i+1;
}
