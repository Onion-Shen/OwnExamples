#import <Foundation/Foundation.h>

@interface NSObject (MethodDispatch)

- (id)performSelector:(SEL)selector withArgs:(NSArray *)args;

- (void)performSelector:(SEL)selector withArgs:(NSArray *)args afterDelay:(NSTimeInterval)seconds;

@end
