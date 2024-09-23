#import <UIKit/UIKit.h>

@interface DecoratedFloatingView : UIView

@property(nonatomic) UINavigationBar *navigationBar;
@property(nonatomic) UINavigationItem *navigationItem;
@property(nonatomic) UIView *resizeHandle;

- (instancetype)initWithFrame:(CGRect)frame navigationBar:(UINavigationBar *)navigationBar;

- (void)moveWindow:(UIPanGestureRecognizer*)sender;
- (void)resizeWindow:(UIPanGestureRecognizer*)sender;

@end
