//
//  AppSceneView.h
//  LiveContainer
//
//  Created by s s on 2025/5/17.
//
#import "UIKitPrivate+MultitaskSupport.h"
#import "FoundationPrivate.h"
@import UIKit;
@import Foundation;

@protocol AppSceneViewDelegate <NSObject>
- (void)appDidExit;
@end

@interface AppSceneViewController : UIViewController<_UISceneSettingsDiffAction>
@property(nonatomic) UIWindowScene *hostScene;
@property(nonatomic) _UIScenePresenter *presenter;
@property(nonatomic) UIMutableApplicationSceneSettings *settings;
@property(nonatomic) NSString *sceneID;
@property(nonatomic) int pid;
@property(nonatomic) id<AppSceneViewDelegate> delegate;
- (BOOL)isAppRunning;

- (instancetype)initWithApp:(LSApplicationProxy *)app frame:(CGRect)frame delegate:(id<AppSceneViewDelegate>)delegate;

- (void)resizeWindowWithFrame:(CGRect)frame;
- (void)closeWindow;
@end

