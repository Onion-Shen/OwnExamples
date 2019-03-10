#import <Foundation/Foundation.h>

typedef void (^Functor)(id val);
typedef void (^Executor)(Functor resolve,Functor reject);

@class Promise;
typedef Promise * (^Functor_r)(id val);

typedef NS_ENUM(NSUInteger,PromiseState)
{
    PENDING = 0,
    FULFILLED,
    REJECTED
};

@interface Promise : NSObject

@property (nonatomic,assign)PromiseState state;

+ (instancetype)promiseWithExecutor:(Executor)executor;

- (instancetype)thenWithOnFulfill:(Functor_r)fulfill andOnReject:(Functor_r)reject;
@property (nonatomic,copy,readonly)Promise * (^then)(Functor_r fulfill,Functor_r reject);

- (instancetype)catchWithOnReject:(Functor_r)reject;
@property (nonatomic,copy,readonly)Promise * (^Catch)(Functor_r reject);

@end
