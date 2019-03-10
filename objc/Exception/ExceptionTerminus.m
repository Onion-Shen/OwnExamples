#import "ExceptionTerminus.h"

void handleExceptions(NSException *exception)
{
    NSLog(@"exception = %@",exception);
    NSLog(@"callStackSymbols = %@",[exception callStackSymbols]);
}

void signalHandler(int sig)
{
    //所有的信号量状态在/sys/signal.h中
    NSLog(@"signal = %d", sig);
}
