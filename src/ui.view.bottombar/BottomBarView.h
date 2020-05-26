//
//  BottomBarView.h
//  VedabaseB
//
//  Created by Peter Kollath on 23/08/14.
//
//

#import <UIKit/UIKit.h>
#import "BottomBarViewController.h"
#import "HeaderBar.h"

@interface BottomBarView : HeaderBar

@property (weak) BottomBarViewController * delegate;

@property CGFloat currentOffset;
@property NSMutableArray * items;
@property CGFloat itemWidth;
@property CGFloat iconHeight;
@property CGFloat textHeight;
@property NSDictionary * arrowAttrs;
@property NSString * leftExtremeArrow;
@property NSString * rightExtremeArrow;

@property NSMutableDictionary * textProperties;

@property BOOL autocorrectOffset;
@property int touchedItemIndex;
@property UIColor * touchedBackColor;
@property UIImage * backgroundImage;
@property CGFloat prevDimensionValue;


-(int)determineItem:(CGPoint)cp;
-(CGFloat)calculateHeight:(CGRect)parentFrame;

@end
