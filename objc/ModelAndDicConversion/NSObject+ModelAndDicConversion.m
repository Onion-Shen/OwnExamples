#import "NSObject+ModelAndDicConversion.h"
#import <objc/runtime.h>

typedef void (^IvarIterator)(Ivar ivar,NSUInteger i);

@implementation NSObject (ModelAndDicConversion)

- (nullable NSDictionary<NSString *,id> *)model2Dic
{
    NSMutableDictionary<NSString *,id> *dic = [[NSMutableDictionary alloc] init];
    Class cls = self.class;
    Class superCls = class_getSuperclass(cls);
    while (cls && superCls)
    {
        [NSObject iterateIvarsByCls:cls andIterator:^(Ivar ivar, NSUInteger i)
        {
            if (!ivar)
            {
                return;
            }

            NSString *key = @(ivar_getName(ivar));
            if (!key || key.length == 0)
            {
                return;
            }

            id value = [self getPropertyValueByKey:key andIvar:ivar];

            if (value)
            {
                [dic setObject:value forKey:key];
            }
        }];

        cls = superCls;
        superCls = nil;
        if (cls)
        {
            superCls = class_getSuperclass(cls);
        }
    }
    return dic;
}

- (id)getPropertyValueByKey:(NSString *)key andIvar:(Ivar)ivar
{
    id value = [self valueForKey:key];
    if (value == nil)
    {
        return value;
    }

    const char *encoding = ivar_getTypeEncoding(ivar);
    if (encoding == NULL || strlen(encoding) == 0)
    {
        return value;
    }

    if (strstr(encoding, "NSArray") != NULL ||
        strstr(encoding, "NSMutableArray") != NULL)
    {
        value = [self getArrayValue:value byKey:key];
    }
    else if (strstr(encoding, "NSDictionary") != NULL ||
             strstr(encoding, "NSMutableDictionary") != NULL)
    {
        value = [self getDictionaryValue:value byKey:key];
    }

    return value;
}

- (id)getDictionaryValue:(id)dicValue byKey:(NSString *)key
{
    NSDictionary *dicCls = [self clsInDic];
    if (!dicCls || dicCls.count == 0)
    {
        return dicValue;
    }

    NSArray<NSString *> *names = [NSObject getPropertyNamesByName:key];
    NSUInteger index = [names indexOfObjectPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        return dicCls[obj] != nil;
    }];
    if (index == NSNotFound)
    {
        return dicValue;
    }
    NSDictionary *subDicCls = dicCls[names[index]];

    NSDictionary *dicRef = dicValue;
    NSMutableDictionary *copyDic = [[NSMutableDictionary alloc] init];
    for (NSString *subDicKey in dicRef.allKeys)
    {
        id subDicValue = dicRef[subDicKey];
        if (subDicCls[subDicKey])
        {
            subDicValue = [subDicValue model2Dic];
        }
        if (subDicValue)
        {
            [copyDic setObject:subDicValue forKey:subDicKey];
        }
    }

    return copyDic;
}

- (id)getArrayValue:(id)arrayValue byKey:(NSString *)key
{
    NSDictionary *arrayCls = [self clsInArray];
    if (!arrayCls || arrayCls.count == 0)
    {
        return arrayValue;
    }

    NSArray<NSString *> *names = [NSObject getPropertyNamesByName:key];
    NSUInteger index = [names indexOfObjectPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        return arrayCls[obj] != nil;
    }];
    if (index == NSNotFound)
    {
        return arrayValue;
    }

    NSArray *arrayRef = arrayValue;
    NSMutableArray *copyArray = [[NSMutableArray alloc] initWithCapacity:arrayRef.count];
    for (id item in arrayRef)
    {
        NSDictionary *dicItem = [item model2Dic];
        if (dicItem)
        {
            [copyArray addObject:dicItem];
        }
    }

    return copyArray;
}

+ (NSArray<NSString *> *)getPropertyNamesByName:(NSString *)name
{
    //_key,_isKey,key,isKey
    NSMutableArray<NSString *> *names = [[NSMutableArray alloc] init];

    NSString *value = nil;
    if ([name hasPrefix:@"_is"])
    {

    }
    else if ([name hasPrefix:@"_"])
    {
        value = [name substringFromIndex:1];
    }
    else if ([name hasPrefix:@"is"])
    {

    }
    else
    {
        value = name;
    }

    [names addObject:name];
    [names addObject:[NSString stringWithFormat:@"_is%@",value.capitalizedString]];
    [names addObject:value];
    [names addObject:[NSString stringWithFormat:@"is%@",value.capitalizedString]];

    return names;
}

+ (void)iterateIvarsByCls:(Class)cls andIterator:(IvarIterator)iterator
{
    if (!cls || !iterator)
    {
        return;
    }

    uint size = 0;
    Ivar *ivars = class_copyIvarList(cls, &size);
    if (size == 0 || !ivars)
    {
        if (ivars)
        {
            free(ivars);
            ivars = NULL;
        }
        return;
    }

    for (NSUInteger i = 0;i < size;++i)
    {
        iterator(ivars[i],i);
    }

    if (ivars)
    {
        free(ivars);
        ivars = NULL;
    }
}

- (NSDictionary<NSString *,NSString *> *)clsInArray
{
    return nil;
}

- (NSDictionary<NSString *,NSDictionary<NSString *,NSString *> *> *)clsInDic
{
    return nil;
}

@end
