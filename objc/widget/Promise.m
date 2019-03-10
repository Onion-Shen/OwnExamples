#import "Promise.h"

@interface Promise ()

@property (nonatomic,strong)Functor resolve;
@property (nonatomic,strong)Functor reject;
@property (nonatomic,strong)NSMutableArray<NSDictionary<NSString *,Functor_r> *> *list;

@end

@implementation Promise

- (void)doResolve:(id)value
{
    for (NSUInteger i = 0;i < self.list.count;++i)
    {
        Functor_r resolve = self.list[i][@"resolve"];

        id tmp = nil;
        if (resolve)
        {
            @try
            {
                tmp = resolve(value);
            }
            @catch (NSException *exception)
            {
                self.reject(exception);
            }
        }

        if ([tmp isKindOfClass:Promise.class])
        {
            Promise *p = tmp;
            for (i++;i < self.list.count;++i)
            {
                [p thenWithOnFulfill:self.list[i][@"resolve"] andOnReject:self.list[i][@"reject"]];
            }
        }
        else
        {
            value = tmp;
        }
    }
}

- (void)doReject:(id)value
{
    if (self.list.count < 1)
    {
        return;
    }

    Functor_r reject = self.list[0][@"reject"];

    id tmp = nil;
    if (reject)
    {
        @try
        {
            tmp = reject(value);
        }
        @catch (NSException *exception)
        {
            self.reject(exception);
        }
    }

    if ([tmp isKindOfClass:Promise.class])
    {
        Promise *p = tmp;
        for (NSUInteger i = 1;i < self.list.count;++i)
        {
            [p thenWithOnFulfill:self.list[i][@"resolve"] andOnReject:self.list[i][@"reject"]];
        }
    }
    else
    {
        [self.list removeObjectAtIndex:0];
        self.resolve(tmp);
    }
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.state = PENDING;
        self.list = [[NSMutableArray alloc] init];

        __weak typeof(self) weakSelf = self;
        self.resolve = ^(id val)
        {
            if (weakSelf)
            {
                weakSelf.state = FULFILLED;
                [weakSelf doResolve:val];
            }
        };

        self.reject = ^(id val)
        {
            if (weakSelf)
            {
                weakSelf.state = REJECTED;
                [weakSelf doReject:val];
            }
        };
    }
    return self;
}

+ (instancetype)promiseWithExecutor:(Executor)executor
{
    Promise *p = [[Promise alloc] init];
    [p performSelector:@selector(doExecutor:) withObject:executor afterDelay:0];
    return p;
}

- (void)doExecutor:(Executor)executor
{
    @try
    {
        executor(self.resolve,self.reject);
    }
    @catch (id error)
    {
        self.reject(error);
    }
}

- (Promise * (^)(Functor_r fulfill,Functor_r reject))then
{
    return ^(Functor_r fulfill,Functor_r reject)
    {
        return [self thenWithOnFulfill:fulfill andOnReject:reject];
    };
}

- (instancetype)thenWithOnFulfill:(Functor_r)fulfill andOnReject:(Functor_r)reject
{
    if (self.state == PENDING)
    {
        NSMutableDictionary<NSString *,Functor_r> *dic = [NSMutableDictionary dictionaryWithCapacity:2];
        if (fulfill)
        {
            dic[@"resolve"] = fulfill;
        }
        if (reject)
        {
            dic[@"reject"] = reject;
        }
        [self.list addObject:dic];
    }
    else if (self.state == FULFILLED)
    {
        fulfill(nil);
    }
    else if (self.state == REJECTED)
    {
        reject(nil);
    }
    return self;
}

- (instancetype)catchWithOnReject:(Functor_r)reject
{
    return [self thenWithOnFulfill:nil andOnReject:reject];
}

- (Promise * (^)(Functor_r reject))Catch
{
    return ^(Functor_r reject)
    {
        return [self catchWithOnReject:reject];
    };
}

@end
