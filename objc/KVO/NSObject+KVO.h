#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVO)

@property (nonatomic,readonly)NSMapTable<NSString *,NSObject *> *KVOStorage;

///observe key at old value and new value
- (void)addObserver:(NSObject *)observer KeyPath:(NSString *)keyPath;

///use NSMapTable to delete observer automatically
- (void)removeObserver:(NSObject *)observer KeyPath:(NSString *)keyPath;

///a callback of own KVO
- (void)observedValue:(NSDictionary<NSKeyValueChangeKey,id> *)pair KeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
