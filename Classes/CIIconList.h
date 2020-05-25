//
//  ContentItemIconList.h
//  VedabaseB
//
//  Created by Peter Kollath on 21/07/16.
//
//

#import "CIBase.h"

@interface CIIconList : CIBase

@property NSMutableArray * items;

// 1-big, 3-medium, 5-small
// default 3
@property int fontSizeIndex;

// 1-big 64px, 3-medium 48px, 5-small 32px
// default 3
@property int iconSizeIndex;

// 1-left, 2-center, 3-right, 4-justify
// default 2
@property int iconAlign;

// default: 12px
@property float iconSpacing;

// private
@property NSDictionary * paraFormat;

-(void)addImage:(NSString *)imageName itemName:(NSString *)text action:(NSString *)actionText;

@end
