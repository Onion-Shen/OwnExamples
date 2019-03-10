#import "NSCodingApplyModel.h"
#import <objc/runtime.h>

@implementation NSCodingApplyModel

#pragma mark -- NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (NSUInteger i = 0;i < count;++i)
    {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        id propertyValue = [self valueForKey:propertyName];
        [aCoder encodeObject:propertyValue forKey:propertyName];
    }
    
    free(properties);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        
        for (NSInteger i = 0;i < count;++i)
        {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:name];
            id propertyValue = [aDecoder decodeObjectForKey:propertyName];
            [self setValue:propertyValue forKey:propertyName];
        }
        
        free(properties);
    }
    return self;
}

@end
