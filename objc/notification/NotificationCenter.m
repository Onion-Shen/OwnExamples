#import "NotificationCenter.h"
#import "../methodDispatch/NSObject+MethodDispatch.h"

static NotificationCenter *Singleton = nil;

@interface NotificationCenter ()

@property (nonatomic,strong)NSMutableDictionary<NSString *,NotificationObserver *> *store;
@property (nonatomic,strong)dispatch_queue_t defaultQueue;

@end

@implementation NotificationCenter
@dynamic defaultCenter;

- (NSMutableDictionary<NSString *,NotificationObserver *> *)store
{
    if (!_store)
    {
        _store = [[NSMutableDictionary alloc] init];
    }
    return _store;
}

- (dispatch_queue_t)defaultQueue
{
    if (!_defaultQueue)
    {
        _defaultQueue = dispatch_queue_create("com.NotificationCenter.serialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _defaultQueue;
}

+ (NotificationCenter *)defaultCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Singleton = [[NotificationCenter alloc] init];
    });
    return Singleton;
}

- (void)addObserver:(id)observer withSelector:(SEL)selector andName:(NSString *)name
{
    if (!name || name.length == 0 || !observer || !selector)
    {
        return;
    }

    NotificationObserver *notiObserver = [[NotificationObserver alloc] init];
    notiObserver.observer = observer;
    notiObserver.selector = selector;

    self.store[name] = notiObserver;
}

- (void)removeObserver:(id)observer forName:(NSString *)name
{
    if (!observer || !name || name.length == 0)
    {
        return;
    }

    NotificationObserver *notiObserver = self.store[name];
    if (!notiObserver)
    {
        return;
    }

    if (notiObserver.observer == observer)
    {
        [self.store removeObjectForKey:name];
    }
}

- (void)postNotificationByName:(NSString *)name andArgs:(NSArray *)args
{
    [self postNotificationByName:name andArgs:args inQueue:self.defaultQueue];
}

- (void)postNotificationByName:(NSString *)name andArgs:(NSArray *)args inQueue:(dispatch_queue_t)queue
{
    if (!queue)
    {
        return;
    }

    dispatch_async(queue, ^{
        if (!name || name.length == 0)
        {
            return;
        }

        NotificationObserver *notiObserver = self.store[name];
        if (!notiObserver)
        {
            return;
        }

        [notiObserver.observer performSelector:notiObserver.selector withArgs:args];
        [self removeObserver:notiObserver.observer forName:name];
    });
}

@end

@implementation NotificationObserver

@end
