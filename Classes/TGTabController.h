//
//  TGTabController.h
//  MyTabController
//
//  Created by Peter Kollath on 1/12/13.
//  Copyright (c) 2013 Peter Kollath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGTouchArea.h"


#define TGTabControllerHighlightStyleAlpha      0
#define TGTabControllerHighlightStyleBackground 1

#define TGTabItemTransitionDefault     0
#define TGTabItemTransitionLeftToRight 1
#define TGTabItemTransitionRightToLeft 2

@interface TGTabBarItem : TGTouchArea

@property (strong, nonatomic) UIViewController * subViewController;
@property (strong) UIImageView * backgroundImageView;
@property (assign) NSInteger noteNumber;
@property (strong, nonatomic) UILabel * titleLabel;

@end

@interface TGTabController : UIViewController<TGTabBarTouches>
{
    NSUInteger m_heightOfBar;
    NSUInteger m_barItemCounter;
    BOOL isFullScreen;

}

@property (assign) NSInteger highlightStyle;
@property (strong, nonatomic) UIView * layerAbovePresentation;
@property (strong, nonatomic) UIView * layerPresentation;
@property (strong, nonatomic) UIView * layerUnderPresentation;

//@property (strong, nonatomic) UIView * view;
@property (strong, nonatomic) UIImageView * barBackgroundImageView;
@property (strong, nonatomic) UIImageView * headerImageView;
@property (strong, nonatomic) UIImage * barBackgroundImage;
@property (strong, nonatomic) UIButton * btnFullScreen;
@property (assign) NSUInteger barHeight;
@property (assign) NSUInteger barItemWidth;
@property (assign) NSUInteger barImageHeight;
@property (assign) NSUInteger barTextHeight;
@property (strong, nonatomic) UIView * tabBarItems;
@property (strong, nonatomic) UIFont * barTextFont;
@property (strong, nonatomic) UIColor * barTextColor;
@property (strong, nonatomic) UIImage * barSeparatorImage;
@property (strong, nonatomic) TGTabBarItem * selectedTab;
@property (assign) CGFloat barInactiveAlpha;
@property (retain, nonatomic) NSMutableArray * subControllers;

@property (nonatomic, retain) TGTabBarItem * transOldTab;
@property (nonatomic, retain) TGTabBarItem * transNewTab;
@property (nonatomic, retain) UIViewController * transOldController;
@property (nonatomic, retain) UIViewController * transNewController;

-(NSInteger)addTabBarButtonWithText:(NSString *)aTitle withImage:(UIImage *)anImage controller:(UIViewController *)aViewController;
-(void)selectBarItemWithTag:(NSInteger)tag direction:(NSInteger)dir;
-(TGTabBarItem *)tabBarItem:(NSUInteger)tag;
-(BOOL)setTabBarBackgroundImage:(NSUInteger)tag image:(UIImage *)image;
-(void)setNoteNumber:(NSInteger)noteNum forItem:(NSInteger)itemTag;

@end


