//
//  HeaderBar.h
//  VedabaseB
//
//  Created by Peter Kollath on 11/12/14.
//
//

#import <UIKit/UIKit.h>

@interface HeaderBar : UIView


@property UIColor * mainColor;
@property UIColor * subColor;
@property UIColor * mainBottomColor;

@property UIRectEdge sides;
@property CGFloat sideWidth;


-(void)myInit;

@end
