//
//  BottomBarViewController.h
//  VedabaseB
//
//  Created by Peter Kollath on 23/08/14.
//
//

#import <UIKit/UIKit.h>
#import "TGTouchArea.h"
#import "HeaderBar.h"
#import "BottomBarViewDelegate.h"
#import "VBLooseViewDelegate.h"

@class BottomBarItem;
@class BottomBarView;
@class VBUserInterfaceManager;

@interface BottomBarViewController : UIViewController<TGTabBarTouches,VBLooseViewDelegate>
{
    CGFloat barStartOffset;
    CGFloat panStartX;
    NSString * backPathTitle;
}

@property (weak,nonatomic) VBUserInterfaceManager * delegate;
@property NSMutableArray * items;
@property (weak) IBOutlet UIView * barView;
@property (weak) IBOutlet HeaderBar * bottomBarBack;
@property UIImage * backgroundImage;
@property (weak) IBOutlet TGTouchArea * gradientView;

@property (weak) IBOutlet UIView * textHeader;
@property (weak) IBOutlet UILabel * textHeaderLabel;
@property IBOutlet UIScrollView * scrollView;
@property NSString * titleBarText;

-(void)addItem:(BottomBarItem *)bbi;
-(void)setPathTitle:(NSString *)str;

@end
