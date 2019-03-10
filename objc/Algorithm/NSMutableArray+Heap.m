#import "NSMutableArray+Heap.h" 

@implementation NSMutableArray (Heap)

- (void)heapifyWithIndex:(NSUInteger)idx Cmp:(BOOL (^)(id,id))cmp
{
    NSUInteger left = idx * 2 + 1;
    NSUInteger right = 2 * (idx + 1);
    NSUInteger pivot = idx;
    
    if (left < self.count && cmp(self[left],self[pivot]))
    {
        pivot = left;
    }
    
    if (right < self.count && cmp(self[right],self[pivot]))
    {
        pivot = right;
    }
    
    if (pivot != idx)
    {
        [self exchangeObjectAtIndex:pivot withObjectAtIndex:idx];
        [self heapifyWithIndex:pivot Cmp:cmp];
    }
}

- (void)makeHeapWithCmp:(BOOL (^)(id,id))cmp
{
    if (!cmp || self.count < 2)
    {
        return;
    }
    
    for (NSInteger i = (self.count >> 1) - 1;i >= 0;--i)
    {
        [self heapifyWithIndex:i Cmp:cmp];
    }
}

- (id)heapPop
{
    id head = nil;
    
    if (self.count > 0)
    {
        head = self[0];
        [self removeObjectAtIndex:0];
    }
    
    return head;
}

@end
