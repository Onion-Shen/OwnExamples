#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ModelAndDicConversion)

///model -> dictionary
- (nullable NSDictionary *)model2Dic;

///dictionary -> model
- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
