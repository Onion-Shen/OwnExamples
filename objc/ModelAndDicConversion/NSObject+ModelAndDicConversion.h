#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ModelAndDicConversion)

///model -> dictionary
- (nullable NSDictionary<NSString *,id> *)model2Dic;

- (NSDictionary<NSString *,NSString *> *)clsInArray;

- (NSDictionary<NSString *,NSDictionary<NSString *,NSString *> *> *)clsInDic;

@end

NS_ASSUME_NONNULL_END
