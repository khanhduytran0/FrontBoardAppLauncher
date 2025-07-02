//
//  PiPManager.h
//  LiveContainer
//
//  Created by s s on 2025/6/3.
//
@import Foundation;
@import AVKit;
@import UIKit;
#import "FoundationPrivate.h"

@interface PiPManager : NSObject<AVPictureInPictureControllerDelegate>
@property (class, nonatomic, readonly) PiPManager *shared;
@property (nonatomic, readonly) bool isPiP;
- (BOOL)isPiPWithView:(UIView*)view;
- (void)stopPiP;
- (void)startPiPWithView:(UIView*)view contentView:(UIView*)contentView;

@end
