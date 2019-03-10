#import "NSObject+KVC.h"
#import <objc/runtime.h>
#import "GetObjcPlainTypeValue.h"

@implementation NSObject (KVC)

- (void)setVal:(nullable id)val Key:(NSString *)key
{
    if (!key || key.length == 0)
    {
        return;
    }
    
    NSMutableArray<NSString *> *keys = [NSMutableArray arrayWithObject:key];
    if ([key characterAtIndex:0] != '_')
    {
        [keys addObject:[NSString stringWithFormat:@"_%@",key]];
    }
    else
    {
        [keys addObject:[key substringFromIndex:1]];
    }
    
    Class cls = [self class];
    for (NSString *obj in keys)
    {
        Ivar ivar = class_getInstanceVariable(cls, obj.UTF8String);
        if (ivar)
        {
            object_setIvar(self, ivar, val);
            break;
        }
    }
}

- (nullable id)objectValueForKey:(NSString *)key
{
    id val = nil;
    
    if (!key || key.length == 0)
    {
        return val;
    }
    
    NSMutableArray<NSString *> *keys = [NSMutableArray arrayWithObject:key];
    if ([key characterAtIndex:0] != '_')
    {
        [keys addObject:[NSString stringWithFormat:@"_%@",key]];
    }
    else
    {
        [keys addObject:[key substringFromIndex:1]];
    }
    
    Class cls = [self class];
    for (NSString *obj in keys)
    {
        Ivar ivar = class_getInstanceVariable(cls, obj.UTF8String);
        if (!ivar)
        {
            continue;
        }
        
        const char *encode = ivar_getTypeEncoding(ivar);
        if (!encode || strlen(encode) == 0)
        {
            continue;
        }
        
        if (encode[0] == '@')
        {
            val = object_getIvar(self, ivar);
        }
        else
        {
            //https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100
            if (strcmp(encode, "f") == 0)
            {
                float *fPtr = getObjcPlainTypeValue(self, obj.UTF8String);
                if (fPtr)
                {
                    val = [NSNumber numberWithFloat:*fPtr];
                }
            }
            else if (strcmp(encode, "d") == 0)
            {
                double *dPtr = getObjcPlainTypeValue(self, obj.UTF8String);
                if (dPtr)
                {
                    val = [NSNumber numberWithDouble:*dPtr];
                }
            }
            else if (strcmp(encode, "B") == 0)
            {
                bool *bPtr = getObjcPlainTypeValue(self, obj.UTF8String);
                if (bPtr)
                {
                    val = [NSNumber numberWithBool:*bPtr];
                }
            }
            else if (strcmp(encode, "c") == 0)
            {
                char *cPtr = getObjcPlainTypeValue(self, obj.UTF8String);
                if (cPtr)
                {
                    val = [NSNumber numberWithChar:*cPtr];
                }
            }
            // else not implement yet
        }
        
        if (val)
        {
            break;
        }
    }
    
    return val;
}

@end
