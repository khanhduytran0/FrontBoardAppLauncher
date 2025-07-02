//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>
#import "UIKitPrivate+MultitaskSupport.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic) UIRootWindowScenePresentationBinder *binder;
@property(strong, nonatomic) UIWindow *window;

@end
