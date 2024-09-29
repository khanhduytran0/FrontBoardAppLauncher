#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include <dlfcn.h>

@interface UIStatusBarServer : NSObject
@end
@implementation UIStatusBarServer(hook)
+ (void)runServer {
    // FIXME: PreBoard doesn't call this
}
@end

@implementation UIApplication(hook)
- (BOOL)_supportedOnLockScreen {
    return YES;
}
@end

@implementation UIViewController(hook)
- (BOOL)_canShowWhileLocked {
    return YES;
}
@end

@implementation UIWindow(hook)
- (BOOL)_shouldCreateContextAsSecure {
    return YES;
}
@end

void FBSystemShellInitialize(id block);

int main(int argc, char **argv) {
    @autoreleasepool {
        FBSystemShellInitialize(nil);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
