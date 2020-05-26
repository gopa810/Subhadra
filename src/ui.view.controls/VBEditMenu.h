//
//  VBEditMenu.h
//  VedabaseB
//
//  Created by Peter Kollath on 19/01/15.
//
//

#import <UIKit/UIKit.h>

@interface VBEditMenuItem : NSObject

@property CGRect area;
@property CGPoint textOrigin;
@property NSString * text;
@property SEL selector;
@property id target;
@property BOOL selected;
@end


@interface VBEditMenu : UIView

@property UIFont * font;
@property id actionTarget;
@property CGRect menuRect;
@property NSArray * menuItems;
@property NSMutableArray * drawItems;
@property CGPoint anchorPoint;
@property CGFloat dim;
@property BOOL atLeft;

-(void)showForRect:(CGRect)hotRect;
+(void)hide;

@end
