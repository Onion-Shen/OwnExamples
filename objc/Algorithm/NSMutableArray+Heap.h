#import <Foundation/Foundation.h>

@interface NSMutableArray (Heap)

- (void)makeHeapWithCmp:(BOOL (^)(id,id))cmp;

- (id)heapPop;

@end
