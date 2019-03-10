#import "NSObject+MethodDispatch.h"

@implementation NSObject (MethodDispatch)

- (id)performSelector:(SEL)selector withArgs:(NSArray *)args
{
    if (!selector || ![self respondsToSelector:selector])
    {
        return nil;
    }

    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = selector;
    if (args && args.count > 0)
    {
        for (NSUInteger i = 0;i < args.count && (i + 2) < signature.numberOfArguments;++i)
        {
            id arg = args[i];
            NSInteger index = 2 + i;
            const char *argType = [signature getArgumentTypeAtIndex:index];

            if (strcmp(argType, "i") == 0)
            {
                NSNumber *number = arg;
                int intVal = number.intValue;
                [invocation setArgument:&intVal atIndex:index];
            }
            else if (strcmp(argType, "f") == 0)
            {
                NSNumber *number = arg;
                float floatVal = number.floatValue;
                [invocation setArgument:&floatVal atIndex:index];
            }
            else if (strcmp(argType, "B") == 0)
            {
                NSNumber *number = arg;
                BOOL boolVal = number.boolValue;
                [invocation setArgument:&boolVal atIndex:index];
            }
            else if (strcmp(argType, "@") == 0)
            {
                [invocation setArgument:&arg atIndex:index];
            }
            else
            {
                //copy and paste
            }
        }
    }

    [invocation invoke];

    __unsafe_unretained id obj = nil;
    if (strcmp(signature.methodReturnType, "@") == 0)
    {
        [invocation getReturnValue:&obj];
    }

    return obj;
}

- (void)performSelector:(SEL)selector withArgs:(NSArray *)args afterDelay:(NSTimeInterval)seconds
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:seconds repeats:NO block:^(NSTimer * _Nonnull timer)
    {
        [self performSelector:selector withArgs:args];
    }];
    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

@end
