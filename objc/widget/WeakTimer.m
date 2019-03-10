#import "WeakTimer.h"

@implementation WeakTimer

- (instancetype)init
{
    if (self = [super init])
    {
        self.timer = nil;
        self.selector = nil;
        self.target = nil;
    }
    return self;
}

- (void)dealloc
{
    self.target = nil;
    self.timer = nil;
}

- (void)fire:(NSTimer *)timer
{
    if (self.target && [self.target respondsToSelector:self.selector])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:timer.userInfo];
#pragma clang diagnostic pop
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

+ (NSTimer *)startTimerWithInterval:(NSTimeInterval)interval Target:(id)target Selector:(SEL)selector Userinfo:(id)userinfo Repeat:(BOOL)repeat 
{
    WeakTimer *timer = [[WeakTimer alloc] init];
    timer.target = target;
    timer.selector = selector;
    timer.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:timer selector:@selector(fire:) userInfo:userinfo repeats:repeat];
    return timer.timer;
}

@end
