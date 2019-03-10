#import "NSObject+KVO.h"
#import <objc/runtime.h>

#if !OBJC_OLD_DISPATCH_PROTOTYPES
typedef id _Nullable (*OLD_DISPATCH_IMP)(id _Nonnull, SEL _Nonnull, ...);
#endif

static void replacedSetter(id this,SEL funcName,id arg)
{
    if (!this || !funcName)
    {
        return;
    }
    
    const char *name = sel_getName(funcName);
    NSString *methodName = name ? [NSString stringWithUTF8String:name] : @"";
    if (!methodName || methodName.length == 0)
    {
        return;
    }
    
    methodName = [methodName substringFromIndex:3];
    methodName = [methodName substringToIndex:methodName.length - 1];
    
    if (methodName.length == 0)
    {
        return;
    }
    
    NSString *key = [methodName lowercaseString];
    NSMapTable<NSString *,NSObject *> *storage = [this KVOStorage];
    NSObject *observer = [storage objectForKey:key];
    
    id delegate =
    ({
        SEL callback = @selector(observedValue:KeyPath:);
        observer && [observer respondsToSelector:callback] ? observer : nil;
    });
    
    if (delegate)
    {
        id val = [this valueForKey:key];
        [delegate observedValue:@{NSKeyValueChangeOldKey:val ? val : NSNull.null} KeyPath:key];
    }
    
    Class cls = object_getClass(this);
    Class superCls = class_getSuperclass(cls);
    IMP imp = class_getMethodImplementation(superCls, funcName);
    
#if !OBJC_OLD_DISPATCH_PROTOTYPES
    OLD_DISPATCH_IMP old_dispatch_imp = (OLD_DISPATCH_IMP)imp;
    old_dispatch_imp(this,funcName,arg);
#else
    imp(this,funcName,arg);
#endif
    
    if (delegate)
    {
        id val = [this valueForKey:key];
        [delegate observedValue:@{NSKeyValueChangeNewKey:val ? val : NSNull.null} KeyPath:key];
    }
}

@implementation NSObject (KVO)

- (void)addObserver:(NSObject *)observer KeyPath:(NSString *)keyPath
{
    if (!observer || !keyPath || keyPath.length == 0)
    {
        return;
    }
    
    Class invisibleCls = nil;
    if ([NSStringFromClass(self.class) isEqualToString:@"invisibleCls"])
    {
        invisibleCls = self.class;
    }
    else
    {
        invisibleCls = objc_allocateClassPair(NSObject.class, "invisibleCls", 0);
    }
    
    NSString *setterName = [NSString stringWithFormat:@"set%@:",keyPath.capitalizedString];
    SEL setterSel = NSSelectorFromString(setterName);
    if (!setterSel)
    {
        return;
    }
    
    if (!class_addMethod(invisibleCls, setterSel, (IMP)replacedSetter, "v@:@"))
    {
        return;
    }
    
    if (![NSStringFromClass(self.class) isEqualToString:@"invisibleCls"])
    {
        Class prevCls = object_setClass(self, invisibleCls);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        class_setSuperclass(invisibleCls, prevCls);
#pragma clang diagnostic pop
    }
    
    NSMapTable<NSString *,NSObject *> *storage = [self KVOStorage];
    [storage setObject:observer forKey:keyPath];
}

- (void)removeObserver:(NSObject *)observer KeyPath:(NSString *)keyPath
{
    if (!observer           || !keyPath            ||
        keyPath.length == 0 || ![NSStringFromClass(self.class) isEqualToString:@"invisibleCls"])
    {
        return;
    }
    
    NSMapTable<NSString *,NSObject *> *storage = [self KVOStorage];
    
    NSObject *target = [storage objectForKey:keyPath];
    if (target && [target isEqual:observer])
    {
        [storage removeObjectForKey:keyPath];
    }
    
    if (storage.dictionaryRepresentation.count == 0)
    {
        object_setClass(self, self.superclass);
    }
}

- (void)observedValue:(NSDictionary<NSKeyValueChangeKey,id> *)pair KeyPath:(NSString *)keyPath
{
    
}

- (NSMapTable<NSString *,NSObject *> *)KVOStorage
{
    NSMapTable<NSString *,NSObject *> *storage = objc_getAssociatedObject(self, "KVOStorage");
    
    if (!storage)
    {
        storage = [NSMapTable strongToWeakObjectsMapTable];
        objc_setAssociatedObject(self, "KVOStorage", storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return storage;
}

@end
