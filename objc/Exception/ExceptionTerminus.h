#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern void handleExceptions(NSException *exception);
extern void signalHandler(int sig);

///捕获信号量和objc异常
#define Set_Exception_Collection \
({\
struct sigaction newSignalAction;\
memset(&newSignalAction, 0,sizeof(newSignalAction));\
newSignalAction.sa_handler = &signalHandler;\
sigaction(SIGABRT, &newSignalAction, NULL);\
sigaction(SIGILL, &newSignalAction, NULL);\
sigaction(SIGSEGV, &newSignalAction, NULL);\
sigaction(SIGFPE, &newSignalAction, NULL);\
sigaction(SIGBUS, &newSignalAction, NULL);\
sigaction(SIGPIPE, &newSignalAction, NULL);\
\
NSSetUncaughtExceptionHandler(&handleExceptions);\
});

NS_ASSUME_NONNULL_END
