#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVC)

///aka valueForKey:
- (nullable id)objectValueForKey:(NSString *)key;

///aka setValue:forKey:
- (void)setVal:(nullable id)val Key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
