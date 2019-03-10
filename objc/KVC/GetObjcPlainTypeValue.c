#include "GetObjcPlainTypeValue.h"

void * getObjcPlainTypeValue(id obj,const char *name)
{
    if (!obj || !name) 
    {
        return NULL;
    }
    
    Ivar ivar = object_getInstanceVariable(obj, name, NULL);
    if (!ivar)
    {
        return NULL;
    }
    
    return (void *)((char *)obj + ivar_getOffset(ivar));
}
