#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationObserver : NSObject

@property (nonatomic,assign)SEL selector;
@property (nonatomic,weak)id observer;

@end

@interface NotificationCenter : NSObject

@property (class,readonly,strong)NotificationCenter *defaultCenter;

- (void)addObserver:(id)observer withSelector:(SEL)selector andName:(NSString *)name;

- (void)removeObserver:(id)observer forName:(NSString *)name;

- (void)postNotificationByName:(NSString *)name andArgs:(NSArray *)args;

@end

NS_ASSUME_NONNULL_END
