#import <Foundation/Foundation.h>

@interface WeakTimer : NSObject

@property (nonatomic,weak)id target;
@property (nonatomic,assign)SEL selector;
@property (nonatomic,weak)NSTimer *timer;

+ (NSTimer *)startTimerWithInterval:(NSTimeInterval)interval Target:(id)target Selector:(SEL)selector Userinfo:(id)userinfo Repeat:(BOOL)repeat;

@end
