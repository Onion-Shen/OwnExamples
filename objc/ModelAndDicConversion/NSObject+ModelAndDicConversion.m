#import "NSObject+ModelAndDicConversion.h"
#import <objc/runtime.h>
#import "../KVC/NSObject+KVC.h"

@implementation NSObject (ModelAndDicConversion)

- (nullable NSDictionary *)model2Dic
{
    uint count = 0;
    Ivar *ivars = class_copyIvarList(self.class, &count);
    if (!ivars || count == 0)
    {
        if (ivars)
        {
            free(ivars);
        }
        return nil;
    }
    
    NSMutableArray<NSString *> *keys = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; ++i)
    {
        Ivar var = ivars[i];
        NSString *name = @(ivar_getName(var));
        if ([name characterAtIndex:0] == '_')
        {
            name = [name substringFromIndex:1];
        }
        
        if ([self objectValueForKey:name])
        {
            [keys addObject:name];
        }
    }
    
    free(ivars);
    
    return keys.count == 0 ? nil : [self dictionaryWithValuesForKeys:keys];
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [self init])
    {
        if (dic && dic.count > 0)
        {
            unsigned int count = 0;
            Ivar *ivars = class_copyIvarList(self.class, &count);
            for (NSUInteger i = 0; i < count; ++i)
            {
                Ivar ivar = ivars[i];
                NSString *key = @(ivar_getName(ivar));
                if ([key characterAtIndex:0] == '_')
                {
                    key = [key substringFromIndex:1];
                }
                
                id value = dic[key];
                if (!value) { continue; }
                
                NSString *type = @(ivar_getTypeEncoding(ivar));
                if ([type rangeOfString:@"@"].length > 0)
                {
                    type = [type substringWithRange:NSMakeRange(2, type.length - 3)];
                    if (![type hasPrefix:@"NS"] && [value isKindOfClass:[NSDictionary class]])
                    {
                        value = [[NSClassFromString(type) alloc] initWithDictionary:value];
                    }
                }
                
                [self setValue:value forKey:key];
            }
            free(ivars);
        }
    }
    return self;
}

@end
