#import "FPSDetector.h"

@interface FPSDetector ()

@property (nonatomic,assign)NSUInteger count;

@property (nonatomic,assign)CGFloat interval;

@end

@implementation FPSDetector

- (instancetype)init
{
    if (self = [super init])
    {
        self.count = 0;
        self.interval = 0.0f;
    }
    return self;
}

+ (FPSDetector *)detector
{
    static FPSDetector *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        singleton = [[FPSDetector alloc] init];
        [singleton log];
    });
    return singleton;
}

- (void)log
{
    CADisplayLink *timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(loop:)];
    [timer addToRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
}

- (void)loop:(CADisplayLink *)timer
{
    ++_count;

    if (_interval == 0.0f)
    {
        _interval = timer.timestamp;
    }

    CGFloat cost = timer.timestamp - _interval;
    if (cost >= 1.0f)
    {
        NSLog(@"FPS = %ld",_count);
        _interval = timer.timestamp;
        _count = 0;
    }
}

@end
